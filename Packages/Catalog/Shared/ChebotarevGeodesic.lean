/-
# A Formal Framework for the Chebotarev Geodesic Theorem (non-split case)

Motivated by the paper *"Chebotarev geodesic theorem: non-split case"*, which proves the
geodesic analogue of the Chebotarev density theorem for congruence subgroups of indefinite
quaternion orders with error exponent `25/36 + ε`, and deduces from it the prime geodesic
theorem with the same exponent.

The analytic input of such papers (spectral theory of the Laplacian, Kuznetsov/Selberg trace
formulae, bounds for exponential sums) is far outside the reach of a formal library today.
What *is* formalizable — and what is the actual logical skeleton of the deduction
"Chebotarev with exponent θ ⟹ prime geodesic theorem with exponent θ" — is the calculus of
**error exponents** together with the **group-theoretic bookkeeping** of conjugacy classes and
the **linear-algebraic character/orthogonality reduction** which converts the non-split problem
into the split one.

This file develops that skeleton rigorously:

* `HasErrorExponent π M θ` : `π x = M x + O(x^{θ+ε})` for every `ε > 0`;
* the exponent calculus: monotonicity, sums, scalar multiples, finite sums, finite
  linear combinations, and perturbation by lower-order terms;
* `exponent_of_inverse_transform`: if an *invertible* linear transform (a "character table")
  of a family of counting functions satisfies the estimate, then so does every member of the
  family.  This is the abstract form of the reduction of the non-split case to the split case;
* `classDensity` for a finite group, `sum_classDensity`, and
  `prime_geodesic_of_chebotarev`: summing the Chebotarev asymptotics over all conjugacy
  classes yields the prime geodesic theorem with the same exponent;
* `tendsto_atTop_of_hasErrorExponent`: an error exponent smaller than the growth exponent of
  the main term forces the qualitative Chebotarev statement (each class is hit infinitely
  often);
* the numerical record chain `25/36 < 71/102 < 7/10 < 35/48 < 3/4` and its consequences.
-/

import Mathlib

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

/-! ## The exponent calculus -/

/-- `HasErrorExponent π M θ` says that the counting function `π` is approximated by the main
term `M` with error `O(x^{θ+ε})` for every `ε > 0`.  This is exactly the shape of the
conclusion of a prime geodesic / Chebotarev geodesic theorem "with exponent `θ + ε`". -/
def HasErrorExponent (π M : ℝ → ℝ) (θ : ℝ) : Prop :=
  ∀ ε > 0, ∃ C > 0, ∃ X ≥ (1 : ℝ), ∀ x ≥ X, |π x - M x| ≤ C * x ^ (θ + ε)

variable {π π₁ π₂ M M₁ M₂ : ℝ → ℝ} {θ θ' : ℝ}

/-- A larger exponent is a weaker statement. -/
theorem HasErrorExponent.mono (h : HasErrorExponent π M θ) (hle : θ ≤ θ') :
    HasErrorExponent π M θ' := by
  intro ε hε
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  refine ⟨C, hC, X, hX, fun x hx => (hb x hx).trans ?_⟩
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hx
  exact mul_le_mul_of_nonneg_left
    (Real.rpow_le_rpow_of_exponent_le hx1 (by linarith)) hC.le

/-- The estimate is additive. -/
theorem HasErrorExponent.add (h₁ : HasErrorExponent π₁ M₁ θ) (h₂ : HasErrorExponent π₂ M₂ θ) :
    HasErrorExponent (fun x => π₁ x + π₂ x) (fun x => M₁ x + M₂ x) θ := by
  intro ε hε
  obtain ⟨C₁, hC₁, X₁, hX₁, hb₁⟩ := h₁ ε hε
  obtain ⟨C₂, hC₂, X₂, hX₂, hb₂⟩ := h₂ ε hε
  refine ⟨C₁ + C₂, by linarith, max X₁ X₂, le_trans hX₁ (le_max_left _ _), fun x hx => ?_⟩
  have hx1 : X₁ ≤ x := le_trans (le_max_left _ _) hx
  have hx2 : X₂ ≤ x := le_trans (le_max_right _ _) hx
  have hxpos : (0 : ℝ) ≤ x ^ (θ + ε) :=
    Real.rpow_nonneg (le_trans (by linarith [le_trans hX₁ hx1]) le_rfl) _
  calc |π₁ x + π₂ x - (M₁ x + M₂ x)| = |(π₁ x - M₁ x) + (π₂ x - M₂ x)| := by ring_nf
    _ ≤ |π₁ x - M₁ x| + |π₂ x - M₂ x| := abs_add_le _ _
    _ ≤ C₁ * x ^ (θ + ε) + C₂ * x ^ (θ + ε) := add_le_add (hb₁ x hx1) (hb₂ x hx2)
    _ = (C₁ + C₂) * x ^ (θ + ε) := by ring

/-- The estimate is stable under scalar multiplication. -/
theorem HasErrorExponent.const_mul (c : ℝ) (h : HasErrorExponent π M θ) :
    HasErrorExponent (fun x => c * π x) (fun x => c * M x) θ := by
  intro ε hε
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  refine ⟨(|c| + 1) * C, by positivity, X, hX, fun x hx => ?_⟩
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hx
  have hxpos : (0 : ℝ) ≤ x ^ (θ + ε) := Real.rpow_nonneg (by linarith) _
  calc |c * π x - c * M x| = |c| * |π x - M x| := by
        rw [← abs_mul]; ring_nf
    _ ≤ |c| * (C * x ^ (θ + ε)) := by
        exact mul_le_mul_of_nonneg_left (hb x hx) (abs_nonneg c)
    _ ≤ (|c| + 1) * C * x ^ (θ + ε) := by nlinarith [abs_nonneg c, hC.le]

/-- The zero function trivially has any error exponent; the base case of finite sums. -/
theorem hasErrorExponent_zero (θ : ℝ) :
    HasErrorExponent (fun _ => (0 : ℝ)) (fun _ => (0 : ℝ)) θ := by
  intro ε hε
  refine ⟨1, one_pos, 1, le_rfl, fun x hx => ?_⟩
  have : (0 : ℝ) ≤ x ^ (θ + ε) := Real.rpow_nonneg (by linarith) _
  simpa using this

/-- Finite sums of counting functions inherit a common error exponent. -/
theorem HasErrorExponent.sum {ι : Type*} (s : Finset ι) (f g : ι → ℝ → ℝ) (θ : ℝ)
    (h : ∀ i ∈ s, HasErrorExponent (f i) (g i) θ) :
    HasErrorExponent (fun x => ∑ i ∈ s, f i x) (fun x => ∑ i ∈ s, g i x) θ := by
  classical
  induction s using Finset.induction with
  | empty => simpa using hasErrorExponent_zero θ
  | insert a s ha ih =>
      have hmem : ∀ i ∈ s, HasErrorExponent (f i) (g i) θ := fun i hi =>
        h i (Finset.mem_insert_of_mem hi)
      have := (h a (Finset.mem_insert_self a s)).add (ih hmem)
      simpa [Finset.sum_insert ha] using this

/-- Finite linear combinations of counting functions inherit a common error exponent.
This is the analytic half of the character-orthogonality reduction. -/
theorem HasErrorExponent.linear_comb {ι : Type*} (s : Finset ι) (c : ι → ℝ) (f g : ι → ℝ → ℝ)
    (θ : ℝ) (h : ∀ i ∈ s, HasErrorExponent (f i) (g i) θ) :
    HasErrorExponent (fun x => ∑ i ∈ s, c i * f i x) (fun x => ∑ i ∈ s, c i * g i x) θ :=
  HasErrorExponent.sum s (fun i x => c i * f i x) (fun i x => c i * g i x) θ
    fun i hi => (h i hi).const_mul (c i)

/-- Replacing the counting function by one that differs by an admissible error keeps the
estimate.  (Formally: perturbation by a function with the same exponent and zero main term.) -/
theorem HasErrorExponent.perturb (h : HasErrorExponent π₁ M θ)
    (hd : HasErrorExponent (fun x => π₂ x - π₁ x) (fun _ => 0) θ) :
    HasErrorExponent π₂ M θ := by
  have := hd.add h
  simpa using this

/-! ## Reduction of the non-split case to the split case:
an invertible linear transform of counting functions -/

/-- **Abstract reduction lemma.**  Suppose the "twisted" counting functions
`x ↦ ∑ i, A j i * f i x` (think: sums over geodesics weighted by a character, or by the
split-case data) all satisfy an error estimate with exponent `θ`, and the transform `A` is
invertible with inverse `B`.  Then every individual counting function `f i` satisfies the
estimate with exponent `θ`.

This is exactly the mechanism by which the non-split Chebotarev statement is deduced from a
family of split-case estimates. -/
theorem exponent_of_inverse_transform {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A B : Matrix ι ι ℝ) (hBA : B * A = 1) (f M : ι → ℝ → ℝ) (θ : ℝ)
    (h : ∀ j, HasErrorExponent (fun x => ∑ i, A j i * f i x)
                               (fun x => ∑ i, A j i * M i x) θ) (i : ι) :
    HasErrorExponent (f i) (M i) θ := by
  have hinv : ∀ k, (∑ j, B i j * A j k) = if i = k then 1 else 0 := by
    intro k
    have := congrFun (congrFun hBA i) k
    simpa [Matrix.mul_apply, Matrix.one_apply] using this
  have key : ∀ (F : ι → ℝ → ℝ) (x : ℝ), ∑ j, B i j * (∑ k, A j k * F k x) = F i x := by
    intro F x
    have hswap : ∑ j, B i j * (∑ k, A j k * F k x)
        = ∑ k, (∑ j, B i j * A j k) * F k x := by
      calc ∑ j, B i j * (∑ k, A j k * F k x)
          = ∑ j, ∑ k, B i j * (A j k * F k x) := by
            exact Finset.sum_congr rfl fun j _ => by rw [Finset.mul_sum]
        _ = ∑ k, ∑ j, B i j * (A j k * F k x) := Finset.sum_comm
        _ = ∑ k, (∑ j, B i j * A j k) * F k x := by
            refine Finset.sum_congr rfl fun k _ => ?_
            rw [Finset.sum_mul]
            exact Finset.sum_congr rfl fun j _ => by ring
    rw [hswap]
    simp [hinv]
  have hlin := HasErrorExponent.linear_comb Finset.univ (fun j => B i j)
      (fun j x => ∑ k, A j k * f k x) (fun j x => ∑ k, A j k * M k x) θ
      (fun j _ => h j)
  have e₁ : (fun x => ∑ j, B i j * (∑ k, A j k * f k x)) = f i := funext (key f)
  have e₂ : (fun x => ∑ j, B i j * (∑ k, A j k * M k x)) = M i := funext (key M)
  rw [e₁, e₂] at hlin
  exact hlin

/-- The `2 × 2` instance of the reduction: knowing the estimate for the *sum* and the
*difference* of two counting functions (the trivial and the non-trivial character of a
quadratic extension — the simplest non-split/split dichotomy) gives it for each one. -/
theorem exponent_of_sum_and_difference {f₁ f₂ M₁ M₂ : ℝ → ℝ} {θ : ℝ}
    (hs : HasErrorExponent (fun x => f₁ x + f₂ x) (fun x => M₁ x + M₂ x) θ)
    (hd : HasErrorExponent (fun x => f₁ x - f₂ x) (fun x => M₁ x - M₂ x) θ) :
    HasErrorExponent f₁ M₁ θ ∧ HasErrorExponent f₂ M₂ θ := by
  constructor
  · have := (hs.const_mul (1 / 2)).add (hd.const_mul (1 / 2))
    have e₁ : (fun x => 1 / 2 * (f₁ x + f₂ x) + 1 / 2 * (f₁ x - f₂ x)) = f₁ := by
      funext x; ring
    have e₂ : (fun x => 1 / 2 * (M₁ x + M₂ x) + 1 / 2 * (M₁ x - M₂ x)) = M₁ := by
      funext x; ring
    rwa [e₁, e₂] at this
  · have := (hs.const_mul (1 / 2)).add (hd.const_mul (-(1 / 2)))
    have e₁ : (fun x => 1 / 2 * (f₁ x + f₂ x) + -(1 / 2) * (f₁ x - f₂ x)) = f₂ := by
      funext x; ring
    have e₂ : (fun x => 1 / 2 * (M₁ x + M₂ x) + -(1 / 2) * (M₁ x - M₂ x)) = M₂ := by
      funext x; ring
    rwa [e₁, e₂] at this

/-! ## Conjugacy class densities in a finite group -/

section Densities

variable (G : Type*) [Group G] [Fintype G] [DecidableEq G]

open scoped Classical in
/-- The number of elements of `G` lying in the conjugacy class `C`. -/
noncomputable def classSize [Fintype (ConjClasses G)] (C : ConjClasses G) : ℕ :=
  (Finset.univ.filter (fun g : G => ConjClasses.mk g = C)).card

open scoped Classical in
/-- The Chebotarev density attached to a conjugacy class: `|C| / |G|`. -/
noncomputable def classDensity [Fintype (ConjClasses G)] (C : ConjClasses G) : ℝ :=
  (classSize G C : ℝ) / (Fintype.card G : ℝ)

open scoped Classical in
/-- The conjugacy classes partition the group. -/
theorem sum_classSize [Fintype (ConjClasses G)] :
    ∑ C : ConjClasses G, classSize G C = Fintype.card G := by
  classical
  have := Finset.card_eq_sum_card_fiberwise
    (f := fun g : G => ConjClasses.mk g) (s := (Finset.univ : Finset G))
    (t := (Finset.univ : Finset (ConjClasses G))) (fun g _ => Finset.mem_univ _)
  simp only [classSize]
  rw [← this, Finset.card_univ]

open scoped Classical in
/-- The Chebotarev densities sum to `1`. -/
theorem sum_classDensity [Fintype (ConjClasses G)] :
    ∑ C : ConjClasses G, classDensity G C = 1 := by
  classical
  have hcard : (Fintype.card G : ℝ) ≠ 0 := by
    have : 0 < Fintype.card G := Fintype.card_pos
    positivity
  simp only [classDensity]
  rw [← Finset.sum_div]
  rw [show ∑ C : ConjClasses G, (classSize G C : ℝ)
        = ((∑ C : ConjClasses G, classSize G C : ℕ) : ℝ) by push_cast; ring]
  rw [sum_classSize G]
  field_simp

end Densities

/-! ## From the Chebotarev geodesic theorem to the prime geodesic theorem -/

open scoped Classical in
/-- **Chebotarev ⟹ prime geodesic theorem.**  If for every conjugacy class `C` of the (finite)
Galois group `G` of the covering the class-counting function `piC C` satisfies
`piC C (x) = (|C|/|G|) · li(x) + O(x^{θ+ε})`, then the total counting function
`∑_C piC C` satisfies `π(x) = li(x) + O(x^{θ+ε})`: the prime geodesic theorem with the
same exponent.  In the paper this is the deduction of the prime geodesic theorem with
exponent `25/36 + ε` from the Chebotarev geodesic theorem with exponent `25/36 + ε`. -/
theorem prime_geodesic_of_chebotarev (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (θ : ℝ)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) θ) :
    HasErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li θ := by
  classical
  have hsum := HasErrorExponent.sum (Finset.univ : Finset (ConjClasses G)) piC
      (fun C x => classDensity G C * li x) θ (fun C _ => h C)
  have e : (fun x => ∑ C : ConjClasses G, classDensity G C * li x) = li := by
    funext x
    rw [← Finset.sum_mul, sum_classDensity G, one_mul]
  rwa [e] at hsum

/-! ## Qualitative consequence: every class is hit infinitely often -/

/-- If the main term grows like `x^β` and the error exponent `θ` is strictly smaller than `β`,
then the counting function tends to infinity.  Applied to the Chebotarev geodesic theorem
(where `M x = (|C|/|G|)·li x`, `β` slightly below `1` and `θ = 25/36`) this gives the
qualitative statement that **every** conjugacy class contains infinitely many primitive
closed geodesics. -/
theorem tendsto_atTop_of_hasErrorExponent {π M : ℝ → ℝ} {θ β c : ℝ}
    (h : HasErrorExponent π M θ) (hc : 0 < c) (hβ : 0 < β) (hθβ : θ < β)
    (hM : ∀ᶠ x in atTop, c * x ^ β ≤ M x) :
    Tendsto π atTop atTop := by
  set ε := (β - θ) / 2 with hεdef
  have hε : 0 < ε := by simp only [hεdef]; linarith
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  have hexp : θ + ε < β := by simp only [hεdef]; linarith
  -- eventually `C * x^(θ+ε) ≤ (c/2) * x^β`
  have hpos : 0 < β - (θ + ε) := by linarith
  have hlim : Tendsto (fun x : ℝ => x ^ (-(β - (θ + ε)))) atTop (𝓝 0) :=
    tendsto_rpow_neg_atTop hpos
  have hev := hlim.eventually (gt_mem_nhds (show (0:ℝ) < c / (2 * C) by positivity))
  have hsmall : ∀ᶠ x in atTop, C * x ^ (θ + ε) ≤ (c / 2) * x ^ β := by
    filter_upwards [hev, eventually_gt_atTop (0:ℝ)] with x hxlt hx0
    have hsplit : x ^ (θ + ε) = x ^ (-(β - (θ + ε))) * x ^ β := by
      rw [← Real.rpow_add hx0]; ring_nf
    have hxβ : (0:ℝ) < x ^ β := Real.rpow_pos_of_pos hx0 β
    have hkey : C * x ^ (-(β - (θ + ε))) ≤ c / 2 := by
      calc C * x ^ (-(β - (θ + ε))) ≤ C * (c / (2 * C)) :=
            mul_le_mul_of_nonneg_left hxlt.le hC.le
        _ = c / 2 := by field_simp
    rw [hsplit]
    calc C * (x ^ (-(β - (θ + ε))) * x ^ β) = (C * x ^ (-(β - (θ + ε)))) * x ^ β := by ring
      _ ≤ (c / 2) * x ^ β := mul_le_mul_of_nonneg_right hkey hxβ.le
  have hlow : ∀ᶠ x in atTop, (c / 2) * x ^ β ≤ π x := by
    filter_upwards [hM, hsmall, eventually_ge_atTop X] with x hMx hsx hxX
    have h1 : |π x - M x| ≤ C * x ^ (θ + ε) := hb x hxX
    have h2 : M x - π x ≤ C * x ^ (θ + ε) := by
      have := abs_le.mp h1
      linarith [this.1]
    linarith
  have hgrow : Tendsto (fun x : ℝ => (c / 2) * x ^ β) atTop atTop := by
    have hb : Tendsto (fun x : ℝ => x ^ β) atTop atTop :=
      tendsto_rpow_atTop hβ
    exact hb.const_mul_atTop (by positivity)
  exact tendsto_atTop_mono' atTop hlow hgrow

/-! ## The numerical record chain -/

/-- The chain of record exponents for the prime geodesic theorem:
`25/36` (Soundararajan–Young type, the exponent of the paper) improves on
`71/102`, `7/10`, `35/48` and the classical `3/4`. -/
theorem record_chain :
    (25 : ℝ) / 36 < 71 / 102 ∧ (71 : ℝ) / 102 < 7 / 10 ∧
      (7 : ℝ) / 10 < 35 / 48 ∧ (35 : ℝ) / 48 < 3 / 4 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- The exponent `25/36` of the paper implies all previously known exponents. -/
theorem exponent_25_36_implies_classical {π M : ℝ → ℝ}
    (h : HasErrorExponent π M (25 / 36)) :
    HasErrorExponent π M (71 / 102) ∧ HasErrorExponent π M (7 / 10) ∧
      HasErrorExponent π M (35 / 48) ∧ HasErrorExponent π M (3 / 4) :=
  ⟨h.mono (by norm_num), h.mono (by norm_num), h.mono (by norm_num), h.mono (by norm_num)⟩

/-- **The main synthetic statement.**  If the Chebotarev geodesic theorem holds with exponent
`25/36 + ε` for every conjugacy class of the finite group `G`, then the prime geodesic theorem
holds with exponent `25/36 + ε`, and a fortiori with the classical exponent `3/4`; moreover
each class-counting function tends to infinity as soon as its main term grows like `x^β` for
some `β > 25/36`. -/
theorem chebotarev_25_36 (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ)
    (h : ∀ C, HasErrorExponent (piC C) (fun x => classDensity G C * li x) (25 / 36)) :
    HasErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li (25 / 36) ∧
      HasErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li (3 / 4) := by
  have hpgt := prime_geodesic_of_chebotarev G piC li (25 / 36) h
  exact ⟨hpgt, hpgt.mono (by norm_num)⟩

end ChebotarevGeodesic