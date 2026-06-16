/-
  # Functorial Tropical Ultrametric from Pythagorean Lorentz Triples

  Bridge: **Probability / metric geometry ↔ tropical algebra ↔ Pythagorean number theory
  ↔ Gaussian arithmetic.**

  This file builds the canonical **tree ultrametric** `d` on the boundary
  `Addr = ℕ → Fin 3` of the ternary Berggren tree (whose three branches `A, B, C`
  generate all primitive Pythagorean triples from `(3,4,5)`), proves it is a genuine
  ultrametric, realizes the three Berggren branch maps `cons k` as exact `(1/2)`-similarities,
  records the tropical min-plus core of the construction, proves the two-sided
  depth↔hypotenuse growth law along the all-`B` ray, and exposes a functorial bridge into
  the catalog's valuation-reconstruction functor (`CategoricalTropicalUltrametric`) through
  the Gaussian integers `ℤ[i]`.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): the boundary of the ternary Berggren tree carries a canonical
  ultrametric of "first disagreement" type, the three branch insertions are exact half-scale
  similarities, and the resulting min-plus valuation is functorially the same data as the
  catalog's tropical valuation carrier — with the Gaussian-integer norm furnishing a
  multiplicative bridge to Pythagorean hypotenuses.
  EXPERIMENT (Experimenter): define `firstDiff` via `Nat.find`, `d := (1/2)^firstDiff`, and
  prove the six metric/ultrametric axioms; prove `firstDiff_ge_min` (the tropical core);
  prove `d_cons_same`/`d_cons_diff`; iterate `childB` from `(3,4,5)` and bound the hypotenuse
  two-sidedly by `5·3^n ≤ c ≤ 5·7^n`; assemble `gaussianSupportCarrier` and reconstruct.
  ANALYSIS (Analyst): the ultrametric inequality reduces to the *agreement-stability* lemma
  `firstDiff_ge_min`; antitonicity of `(1/2)^·` turns `min` of exponents into `max` of
  distances. The growth window survives because `a ≤ c, b ≤ c` is preserved by `childB`.
  CRITIQUE (Critic): the trivial support valuation `gval` is multiplicative *only* because
  `ℤ[i]` is a domain; we use `mul_eq_zero`. The two-sided window is sharp at the seed.
  None of the main theorems are `rfl`/`native_decide`-only: they use induction, antitone
  power bounds, `Nat.find` reasoning, and case analysis.
  SYNTHESIS (PI): the file is the canonical packaging requested; follow-ups (compactness,
  Hausdorff dimension, (1+i)-adic refinement) recorded in `FUTURE_DIRECTIONS.md`.
-/

import Mathlib
import Bridges.CategoricalTropicalUltrametric
import Algebra.BerggrenLorentz.Core

namespace FunctorialTropicalPythagorean

open CategoricalTropicalUltrametric
open Classical

/-! ## §1. The Berggren boundary and the first-disagreement index -/

/-- The boundary of the ternary Berggren tree: infinite branch addresses. -/
abbrev Addr : Type := ℕ → Fin 3

/-- Prepend a branch label: `cons k x` chooses branch `k` first, then follows `x`. -/
def cons (k : Fin 3) (x : Addr) : Addr := fun n => match n with
  | 0 => k
  | (m + 1) => x m

@[simp] theorem cons_zero (k : Fin 3) (x : Addr) : cons k x 0 = k := rfl
@[simp] theorem cons_succ (k : Fin 3) (x : Addr) (m : ℕ) : cons k x (m + 1) = x m := rfl

/-- The index of the first coordinate where two addresses disagree (`0` when equal,
    a junk value that is never used in the equal case). -/
noncomputable def firstDiff (x y : Addr) : ℕ :=
  if h : ∃ n, x n ≠ y n then Nat.find h else 0

/-- For unequal addresses, the first-disagreement index witnesses an actual disagreement. -/
theorem firstDiff_spec {x y : Addr} (h : x ≠ y) : x (firstDiff x y) ≠ y (firstDiff x y) := by
  have hex : ∃ n, x n ≠ y n := Function.ne_iff.mp h
  simp only [firstDiff, dif_pos hex]
  exact Nat.find_spec hex

/-- Below the first-disagreement index, the two addresses agree. -/
theorem firstDiff_min {x y : Addr} (h : x ≠ y) {m : ℕ} (hm : m < firstDiff x y) :
    x m = y m := by
  have hex : ∃ n, x n ≠ y n := Function.ne_iff.mp h
  simp only [firstDiff, dif_pos hex] at hm
  by_contra hne
  exact absurd (Nat.find_le hne) (not_le.mpr hm)

/-- `firstDiff` is symmetric. -/
theorem firstDiff_comm (x y : Addr) : firstDiff x y = firstDiff y x := by
  unfold firstDiff; by_cases h : ∃ n, x n ≠ y n <;> by_cases h' : ∃ n, y n ≠ x n <;> simp_all +decide [ ne_comm ] ;

/-! ## §2. The tree ultrametric -/

/-- The canonical tree ultrametric: `d x y = (1/2)^(first disagreement)`, and `0` if equal. -/
noncomputable def d (x y : Addr) : ℝ :=
  if x = y then 0 else (1 / 2 : ℝ) ^ firstDiff x y

theorem d_self (x : Addr) : d x x = 0 := by simp [d]

theorem d_nonneg (x y : Addr) : 0 ≤ d x y := by
  unfold d; split
  · exact le_refl 0
  · positivity

theorem d_comm (x y : Addr) : d x y = d y x := by
  unfold d
  by_cases h : x = y
  · simp [h]
  · rw [if_neg h, if_neg (Ne.symm h), firstDiff_comm]

theorem d_eq_zero_iff (x y : Addr) : d x y = 0 ↔ x = y := by
  unfold d
  constructor
  · intro h
    by_contra hne
    rw [if_neg hne] at h
    have : (0 : ℝ) < (1 / 2 : ℝ) ^ firstDiff x y := by positivity
    linarith
  · intro h; simp [h]

theorem d_le_one (x y : Addr) : d x y ≤ 1 := by
  unfold d; split
  · norm_num
  · apply pow_le_one₀ <;> norm_num

/-- **Tropical min-plus core.** For three pairwise-distinct addresses the first-disagreement
    index of the ends is at least the minimum of the two intermediate indices: agreement is
    transitive up to the smaller stabilization depth.
-/
theorem firstDiff_ge_min {x y z : Addr} (hxy : x ≠ y) (hyz : y ≠ z) (hxz : x ≠ z) :
    min (firstDiff x y) (firstDiff y z) ≤ firstDiff x z := by
  unfold firstDiff at *; simp_all +decide [ Function.ne_iff.mp hxy, Function.ne_iff.mp hyz ]
  grind

/-- **Strong (ultrametric) triangle inequality.** -/
theorem d_ultra (x y z : Addr) : d x z ≤ max (d x y) (d y z) := by
  by_cases hxy : x = y <;> by_cases hyz : y = z <;> by_cases hxz : x = z <;> simp_all +decide [ d ];
  have h_exp : firstDiff x z ≥ min (firstDiff x y) (firstDiff y z) :=
    firstDiff_ge_min hxy hyz hxz
  cases min_cases (firstDiff x y) (firstDiff y z) <;> simp_all +decide
  · exact Or.inl ( inv_anti₀ ( by positivity ) ( pow_le_pow_right₀ ( by norm_num ) h_exp ) );
  · exact Or.inr ( inv_anti₀ ( by positivity ) ( pow_le_pow_right₀ ( by norm_num ) h_exp ) )

/-- The ordinary triangle inequality follows from the ultrametric one. -/
theorem d_triangle (x y z : Addr) : d x z ≤ d x y + d y z := by
  have h := d_ultra x y z
  have h1 := d_nonneg x y
  have h2 := d_nonneg y z
  calc d x z ≤ max (d x y) (d y z) := h
    _ ≤ d x y + d y z := by
        rcases le_total (d x y) (d y z) with hle | hle
        · rw [max_eq_right hle]; linarith
        · rw [max_eq_left hle]; linarith

/-! ## §3. The branch maps are exact `(1/2)`-similarities -/

/-- **Tropical multiplication law.** Prepending equal labels shifts the first-disagreement
    index up by one (for distinct tails).
-/
theorem firstDiff_cons_tropical (k : Fin 3) {x y : Addr} (h : x ≠ y) :
    firstDiff (cons k x) (cons k y) = firstDiff x y + 1 := by
  unfold firstDiff;
  split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
  · exact ⟨ Nat.find_spec ‹∃ n, x n ≠ y n›, fun n hn => by cases n <;> simp_all +decide [ cons ] ⟩;
  · exact h ( funext ‹_› );
  · exact h ( funext fun n => by simpa using ‹∀ n, cons k x n = cons k y n› ( n + 1 ) )

/-- **Half-scale similarity.** Each branch insertion `cons k` contracts the ultrametric by
    exactly the factor `1/2`.
-/
theorem d_cons_same (k : Fin 3) (x y : Addr) : d (cons k x) (cons k y) = (1 / 2 : ℝ) * d x y := by
  by_cases hxy : x = y;
  · simp [hxy, d_self];
  · rw [ show d ( cons k x ) ( cons k y ) = ( 1 / 2 : ℝ ) ^ firstDiff ( cons k x ) ( cons k y ) from ?_, show d x y = ( 1 / 2 : ℝ ) ^ firstDiff x y from ?_ ];
    · rw [ firstDiff_cons_tropical k hxy, pow_succ' ];
    · exact if_neg hxy;
    · exact if_neg ( by intro h; exact hxy <| by funext n; have := congr_fun h ( n + 1 ) ; aesop )

/-- **Disjoint clopen balls.** Different first labels put the two images at distance exactly
    `1`, the maximal possible value.
-/
theorem d_cons_diff {k k' : Fin 3} (hk : k ≠ k') (x y : Addr) :
    d (cons k x) (cons k' y) = 1 := by
  unfold d;
  rw [ if_neg ];
  · rw [ show firstDiff ( cons k x ) ( cons k' y ) = 0 from _ ] ; norm_num;
    unfold firstDiff;
    split_ifs <;> simp_all +decide [ Nat.find_eq_zero ];
  · exact fun h => hk <| by simpa using congr_fun h 0;

/-- The branch insertions are non-expansive (`(1/2)`-Lipschitz) endomorphisms. -/
theorem cons_contraction (k : Fin 3) (x y : Addr) :
    d (cons k x) (cons k y) ≤ (1 / 2 : ℝ) * d x y := by
  rw [d_cons_same]

/-! ## §4. Two-sided depth ↔ hypotenuse growth along the all-`B` ray -/

/-- Iterating the Berggren `B`-branch from the seed `(3,4,5)`. -/
def bIter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | (n + 1) => BerggrenLorentz.childB (bIter n).1 (bIter n).2.1 (bIter n).2.2

/-- Along the all-`B` ray every triple stays Pythagorean with positive legs bounded by the
    hypotenuse.
-/
theorem bIter_pos_le (n : ℕ) :
    0 < (bIter n).1 ∧ 0 < (bIter n).2.1 ∧ 0 < (bIter n).2.2 ∧
    (bIter n).1 ≤ (bIter n).2.2 ∧ (bIter n).2.1 ≤ (bIter n).2.2 := by
  induction' n with n ih <;> norm_num [ bIter ] at *;
  unfold BerggrenLorentz.childB; exact ⟨ by linarith, by linarith, by linarith, by linarith, by linarith ⟩ ;

/-- **Seed strict growth.** The hypotenuse strictly increases at every step of the ray. -/
theorem seed_hyp_growth (n : ℕ) : (bIter n).2.2 < (bIter (n + 1)).2.2 := by
  obtain ⟨ ha, hb, hc, hac, hbc ⟩ := bIter_pos_le n;
  exact show ( bIter n |>.2.2 ) < 2 * ( bIter n |>.1 ) + 2 * ( bIter n |>.2.1 ) + 3 * ( bIter n |>.2.2 ) from by linarith;

/-- **Two-sided depth–size window.** Along the all-`B` ray the depth-`n` hypotenuse `c`
    satisfies `5·3^n ≤ c ≤ 5·7^n`; hence metric depth is `Θ(log c)`.
-/
theorem bchild_iter_hyp_growth (n : ℕ) :
    (5 : ℤ) * 3 ^ n ≤ (bIter n).2.2 ∧ (bIter n).2.2 ≤ (5 : ℤ) * 7 ^ n := by
  induction' n with n ih <;> norm_num [ pow_succ' ] at *;
  · exact ⟨ by decide, by decide ⟩;
  · -- By definition of `bIter`, we have `bIter (n + 1) = childB (bIter n).1 (bIter n).2.1 (bIter n).2.2`.
    have h_bIter_succ : bIter (n + 1) = BerggrenLorentz.childB (bIter n).1 (bIter n).2.1 (bIter n).2.2 := by
      rfl
    generalize_proofs at *; (
    constructor <;> push_cast [ h_bIter_succ, BerggrenLorentz.childB ] <;> linarith [ bIter_pos_le n ] ;)

/-! ## §5. Functorial Gaussian bridge -/

/-- The trivial **support valuation** on `ℤ[i]`: `0 ↦ 0`, every nonzero element `↦ 1`. -/
def gval : GaussianInt → ℕ := fun z => if z = 0 then 0 else 1

/-- The Gaussian-integer **support carrier** for the catalog valuation-reconstruction functor. -/
def gaussianSupportCarrier : TropicalValuationCarrier where
  K := GaussianInt
  add_op := (· + ·)
  neg_op := (-·)
  zero_val := 0
  sub_op := (· - ·)
  sub_def := fun x y => sub_eq_add_neg x y
  mul_op := (· * ·)
  one_val := 1
  val := gval
  val_zero := by simp [gval]
  val_neg := by intro x; simp only [gval, neg_eq_zero]
  val_mul := by
    intro x y
    simp only [gval, mul_eq_zero]
    by_cases hx : x = 0 <;> by_cases hy : y = 0 <;> simp [hx, hy]
  val_add := by
    intro x y
    by_cases hx : x = 0
    · subst hx; simp [gval]
    · by_cases hy : y = 0
      · subst hy; simp [gval]
      · have hxy : gval (x + y) ≤ 1 := by unfold gval; split <;> omega
        have hmax : max (gval x) (gval y) = 1 := by simp [gval, hx, hy]
        rw [hmax]; exact hxy

/-- **Reconstructed Gaussian ultrametric.** The reconstructed support norm on `ℤ[i]`
    satisfies the strong (ultrametric) triangle inequality. -/
theorem gaussian_reconstruct_ultrametric (x y : GaussianInt) :
    (valuationReconstruct gaussianSupportCarrier).norm
        ((valuationReconstruct gaussianSupportCarrier).add_op x y)
      ≤ max ((valuationReconstruct gaussianSupportCarrier).norm x)
            ((valuationReconstruct gaussianSupportCarrier).norm y) :=
  valuationReconstruct_obj_ultrametric gaussianSupportCarrier x y

/-- The Gaussian norm of `m + n·i` equals `m² + n²` — the squared hypotenuse of the
    Pythagorean encoding `(m²−n², 2mn, m²+n²)`. -/
theorem gaussian_norm_eq (m n : ℤ) : (⟨m, n⟩ : GaussianInt).norm = m ^ 2 + n ^ 2 := by
  simp [Zsqrtd.norm]; ring

/-- The Gaussian norm is multiplicative (the arithmetic backbone of the bridge). -/
theorem gaussian_norm_mul (z w : GaussianInt) : (z * w).norm = z.norm * w.norm :=
  Zsqrtd.norm_mul z w

end FunctorialTropicalPythagorean