import Mathlib

/-!
# Hyper-Awareness I: the exact width threshold for lossless 11-dimensional ReLU perception

This file answers, *exactly*, the central question of the research mission:

> How wide must a single ReLU layer be in order to process an 11-dimensional perception
> vector **without any dimensional reduction loss** (i.e. injectively)?

The answer proved here is **22 = 2 · 11**, and both directions are established:

* `HyperAwareness11D.two_mul_le_card_of_injective` — *lower bound.*  If a ReLU layer
  `x ↦ (relu (⟪wᵢ, x⟫ + bᵢ))ᵢ` on `ℝⁿ` is injective, then the number of output units is at
  least `2n`.  Specialised: an injective ReLU perception layer on `ℝ¹¹` needs `≥ 22` units.
* `HyperAwareness11D.doubleLayer_injective` — *upper bound.*  The "positive/negative split"
  layer `x ↦ (x⁺, x⁻)` with exactly `2n` units is injective, and is even *linearly*
  invertible (`HyperAwareness11D.doubleLayer_reconstruct`).
* `HyperAwareness11D.isLeast_width_11` — combining the two: `22` is the *least* width of an
  injective ReLU layer on 11-dimensional perception vectors.

## Structure of the lower bound proof

The argument is a hybrid of linear algebra, elementary real analysis and a finite
combinatorial duality step, and it avoids any measure theory:

1. `exists_generic_direction` (algebra: one-variable polynomials over an infinite field):
   there is a direction `u` with `⟪wᵢ, u⟫ ≠ 0` for every nonzero row `wᵢ`, obtained by
   evaluating the product of the row polynomials `∑ⱼ wᵢⱼ Xʲ` off its finite root set.
2. `card_activeRows_ge` (linear algebra + a perturbation argument): at any point `x` where
   no nonzero row is exactly at its kink, the *active* rows must have rank `n`; otherwise a
   kernel vector `v` of the active rows can be added to `x` (scaled small enough that the
   inactive rows stay inactive) without changing the output, contradicting injectivity.
   Rank `n` forces at least `n` active rows.
3. `two_mul_le_card_of_injective` (duality): far out along `±u` the active sets are exactly
   the rows with `⟪wᵢ, u⟫ > 0` resp. `< 0`; these two sets are **disjoint** and each has at
   least `n` elements, so the layer has at least `2n` units.

Step 3 is where the factor `2` — and hence the sharp constant `22` in dimension `11` — comes
from: a ReLU unit can only "see" one half-space, so a full 11-dimensional percept needs a
complete positive *and* a complete negative frame.
-/

namespace HyperAwareness11D

open Finset

noncomputable section

open scoped Classical

/-! ## Basic definitions -/

/-- The rectified linear unit. -/
def relu (t : ℝ) : ℝ := max t 0

lemma relu_of_nonpos {t : ℝ} (h : t ≤ 0) : relu t = 0 := max_eq_right h

lemma relu_of_nonneg {t : ℝ} (h : 0 ≤ t) : relu t = t := max_eq_left h

/-- `relu t - relu (-t) = t`: the positive/negative split loses no information. -/
lemma relu_sub_relu_neg (t : ℝ) : relu t - relu (-t) = t := by
  rcases le_total t 0 with h | h
  · rw [relu_of_nonpos h, relu_of_nonneg (neg_nonneg.mpr h)]; ring
  · rw [relu_of_nonneg h, relu_of_nonpos (neg_nonpos.mpr h)]; ring

variable {ι ι' : Type*} {n : ℕ}

/-- Pre-activation of unit `i`: `⟪wᵢ, x⟫ + bᵢ`. -/
def preAct (W : ι → Fin n → ℝ) (b : ι → ℝ) (x : Fin n → ℝ) (i : ι) : ℝ :=
  (∑ j, W i j * x j) + b i

/-- A single ReLU layer `ℝⁿ → ℝ^ι`. -/
def reluLayer (W : ι → Fin n → ℝ) (b : ι → ℝ) (x : Fin n → ℝ) : ι → ℝ :=
  fun i => relu (preAct W b x i)

/-- The units that are strictly active at `x` **and** actually depend on the input. -/
def ActiveRows [Fintype ι] (W : ι → Fin n → ℝ) (b : ι → ℝ) (x : Fin n → ℝ) : Finset ι :=
  univ.filter (fun i => 0 < preAct W b x i ∧ ∃ j, W i j ≠ 0)

lemma preAct_add_smul (W : ι → Fin n → ℝ) (b : ι → ℝ) (x v : Fin n → ℝ) (t : ℝ) (i : ι) :
    preAct W b (x + t • v) i = preAct W b x i + t * ∑ j, W i j * v j := by
  simp only [preAct, Pi.add_apply, Pi.smul_apply, smul_eq_mul]
  have hj : ∀ j, W i j * (x j + t * v j) = W i j * x j + t * (W i j * v j) := fun j => by ring
  simp only [hj, Finset.sum_add_distrib, ← Finset.mul_sum]
  ring

lemma preAct_smul (W : ι → Fin n → ℝ) (b : ι → ℝ) (u : Fin n → ℝ) (s : ℝ) (i : ι) :
    preAct W b (s • u) i = s * (∑ j, W i j * u j) + b i := by
  have hj : ∀ j, W i j * (s * u j) = s * (W i j * u j) := fun j => by ring
  simp only [preAct, Pi.smul_apply, smul_eq_mul, hj, ← Finset.mul_sum]

/-! ## Two elementary scaling lemmas -/

/-- If `p` is strictly negative on a finite set `S`, one can move a positive amount `t` in any
direction and keep `p i + t * c i` non-positive on `S`. -/
lemma exists_pos_scale {α : Type*} (S : Finset α) (p c : α → ℝ) (h : ∀ i ∈ S, p i < 0) :
    ∃ t : ℝ, 0 < t ∧ ∀ i ∈ S, p i + t * c i ≤ 0 := by
  by_cases hS : S.Nonempty
  · have ht0 : 0 < S.inf' hS (fun i => -p i / (1 + |c i|)) := by
      rw [Finset.lt_inf'_iff]
      intro k hk
      have h1' : (0:ℝ) < 1 + |c k| := by positivity
      exact div_pos (by linarith [h k hk]) h1'
    refine ⟨S.inf' hS (fun i => -p i / (1 + |c i|)), ht0, ?_⟩
    intro i hi
    have h1 : (0:ℝ) < 1 + |c i| := by positivity
    have hle : S.inf' hS (fun i => -p i / (1 + |c i|)) ≤ -p i / (1 + |c i|) :=
      Finset.inf'_le _ hi
    have hmul : S.inf' hS (fun i => -p i / (1 + |c i|)) * (1 + |c i|) ≤ -p i := by
      rw [← le_div_iff₀ h1]
      exact hle
    have habs : c i ≤ |c i| := le_abs_self _
    nlinarith [ht0]
  · exact ⟨1, one_pos, fun i hi => absurd ⟨i, hi⟩ hS⟩

/-- One can scale far enough out that the linear part dominates every bias. -/
lemma exists_large_scale {α : Type*} [Fintype α] (d b : α → ℝ) :
    ∃ s : ℝ, 0 < s ∧ ∀ i, d i ≠ 0 → |b i| < s * |d i| := by
  classical
  set T : Finset α := univ.filter (fun i => d i ≠ 0) with hT
  by_cases hne : T.Nonempty
  · refine ⟨1 + T.sup' hne (fun i => |b i| / |d i|), ?_, ?_⟩
    · obtain ⟨i0, hi0⟩ := id hne
      have h0 : (0:ℝ) ≤ |b i0| / |d i0| := by positivity
      have hle : |b i0| / |d i0| ≤ T.sup' hne (fun i => |b i| / |d i|) :=
        Finset.le_sup' (fun i => |b i| / |d i|) hi0
      linarith
    · intro i hi
      have hiT : i ∈ T := by simp [hT, hi]
      have hle : |b i| / |d i| ≤ T.sup' hne (fun i => |b i| / |d i|) := Finset.le_sup' (fun i => |b i| / |d i|) hiT
      have hd : 0 < |d i| := abs_pos.mpr hi
      rw [← div_lt_iff₀ hd]
      linarith
  · refine ⟨1, one_pos, ?_⟩
    intro i hi
    exact absurd ⟨i, by simp [hT, hi]⟩ hne

/-! ## Genericity: a direction transverse to every nonzero row -/

/-- There is a direction `u` on which every nonzero row of `W` takes a nonzero value.
The proof evaluates the product of the row polynomials `∑ⱼ wᵢⱼ Xʲ` at a non-root. -/
lemma exists_generic_direction [Fintype ι] (W : ι → Fin n → ℝ) :
    ∃ u : Fin n → ℝ, ∀ i, (∃ j, W i j ≠ 0) → (∑ j, W i j * u j) ≠ 0 := by
  classical
  set P : Polynomial ℝ :=
    ∏ i ∈ univ.filter (fun i => ∃ j, W i j ≠ 0),
      (∑ j : Fin n, Polynomial.C (W i j) * Polynomial.X ^ (j : ℕ)) with hP
  have hfac : ∀ i ∈ univ.filter (fun i : ι => ∃ j, W i j ≠ 0),
      (∑ j : Fin n, Polynomial.C (W i j) * Polynomial.X ^ (j : ℕ)) ≠ 0 := by
    intro i hi
    simp only [Finset.mem_filter] at hi
    obtain ⟨k, hk⟩ := hi.2
    intro hzero
    apply hk
    have hcoeff : (∑ j : Fin n, Polynomial.C (W i j) * Polynomial.X ^ (j : ℕ)).coeff (k : ℕ)
        = W i k := by
      simp [Polynomial.finset_sum_coeff, Polynomial.coeff_C_mul, Polynomial.coeff_X_pow,
        Fin.val_eq_val]
    rw [hzero] at hcoeff
    simpa using hcoeff.symm
  have hPne : P ≠ 0 := Finset.prod_ne_zero_iff.mpr hfac
  obtain ⟨t, ht⟩ : ∃ t : ℝ, P.eval t ≠ 0 := by
    by_contra hcon
    push_neg at hcon
    exact hPne (Polynomial.funext (fun x => by simp [hcon x]))
  refine ⟨fun j => t ^ (j : ℕ), ?_⟩
  intro i hi
  have hiT : i ∈ univ.filter (fun i : ι => ∃ j, W i j ≠ 0) := by
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]; exact hi
  have heval : P.eval t = ∏ i ∈ univ.filter (fun i : ι => ∃ j, W i j ≠ 0),
      (∑ j : Fin n, W i j * t ^ (j:ℕ)) := by
    rw [hP, Polynomial.eval_prod]
    refine Finset.prod_congr rfl ?_
    intro k _
    simp [Polynomial.eval_finset_sum]
  rw [heval] at ht
  exact Finset.prod_ne_zero_iff.mp ht i hiT

/-! ## The local rank bound -/

/-- **Local rank bound.**  At a point `x` where no input-dependent unit sits exactly on its
kink, the active units of an injective ReLU layer must span all of `ℝⁿ`; in particular there
are at least `n` of them. -/
theorem card_activeRows_ge [Fintype ι] (W : ι → Fin n → ℝ) (b : ι → ℝ)
    (hinj : Function.Injective (reluLayer W b)) (x : Fin n → ℝ)
    (hx : ∀ i, (∀ j, W i j = 0) ∨ preAct W b x i ≠ 0) :
    n ≤ (ActiveRows W b x).card := by
  classical
  set A := ActiveRows W b x with hA
  set L : (Fin n → ℝ) →ₗ[ℝ] ({i // i ∈ A} → ℝ) :=
    { toFun := fun v i => ∑ j, W i.1 j * v j
      map_add' := by
        intro v w; funext i
        simp [Finset.sum_add_distrib, mul_add]
      map_smul' := by
        intro c v; funext i
        simp [Finset.mul_sum, mul_left_comm] } with hL
  have hker : ∀ v : Fin n → ℝ, L v = 0 → v = 0 := by
    intro v hv
    have hvA : ∀ i ∈ A, (∑ j, W i j * v j) = 0 := by
      intro i hi
      have hcong := congrFun hv ⟨i, hi⟩
      simpa [hL] using hcong
    set c : ι → ℝ := fun i => ∑ j, W i j * v j with hc
    set S : Finset ι := univ.filter (fun i => c i ≠ 0) with hS
    have hneg : ∀ i ∈ S, preAct W b x i < 0 := by
      intro i hi
      simp only [hS, Finset.mem_filter, Finset.mem_univ, true_and] at hi
      have hrow : ∃ j, W i j ≠ 0 := by
        by_contra hrow
        push_neg at hrow
        exact hi (by simp [hc, hrow])
      have hne : preAct W b x i ≠ 0 := by
        rcases hx i with h | h
        · obtain ⟨j, hj⟩ := hrow
          exact absurd (h j) hj
        · exact h
      rcases lt_or_gt_of_ne hne with h | h
      · exact h
      · refine absurd (hvA i ?_) hi
        simp [hA, ActiveRows, Finset.mem_filter, h, hrow]
    obtain ⟨t, ht0, ht⟩ := exists_pos_scale S (preAct W b x) c hneg
    have hlayer : reluLayer W b (x + t • v) = reluLayer W b x := by
      funext i
      by_cases hci : c i = 0
      · have hci' : (∑ j, W i j * v j) = 0 := hci
        simp [reluLayer, preAct_add_smul, hci']
      · have hiS : i ∈ S := by simp [hS, hci]
        have h1 : preAct W b x i < 0 := hneg i hiS
        have h2 : preAct W b x i + t * c i ≤ 0 := ht i hiS
        simp only [reluLayer, preAct_add_smul]
        rw [relu_of_nonpos h2, relu_of_nonpos h1.le]
    have hxx : x + t • v = x := hinj hlayer
    have htv : t • v = 0 := by
      nth_rewrite 2 [← add_zero x] at hxx
      exact add_left_cancel hxx
    rcases smul_eq_zero.mp htv with h | h
    · exact absurd h (ne_of_gt ht0)
    · exact h
  have hLinj : Function.Injective L := LinearMap.ker_eq_bot.mp (LinearMap.ker_eq_bot'.mpr hker)
  have h1 : Module.finrank ℝ (Fin n → ℝ) ≤ Module.finrank ℝ ({i // i ∈ A} → ℝ) :=
    LinearMap.finrank_le_finrank_of_injective hLinj
  rwa [Module.finrank_fin_fun, Module.finrank_fintype_fun_eq_card, Fintype.card_coe] at h1

/-! ## The sharp lower bound `width ≥ 2n` -/

/-- **Antipodal probes.**  For an injective ReLU layer there are two input percepts whose
active unit sets are disjoint and each of size at least `n`.  This is the structural core of
both the width lower bound and the balanced-frame theorem of `BalancedFrame.lean`. -/
theorem exists_antipodal_probes [Fintype ι] (W : ι → Fin n → ℝ) (b : ι → ℝ)
    (hinj : Function.Injective (reluLayer W b)) :
    ∃ x y : Fin n → ℝ, n ≤ (ActiveRows W b x).card ∧ n ≤ (ActiveRows W b y).card ∧
      Disjoint (ActiveRows W b x) (ActiveRows W b y) := by
  classical
  obtain ⟨u, hu⟩ := exists_generic_direction W
  set d : ι → ℝ := fun i => ∑ j, W i j * u j with hd
  obtain ⟨s, hs0, hs⟩ := exists_large_scale d b
  have hpre : ∀ (σ : ℝ) (i : ι), preAct W b (σ • u) i = σ * d i + b i := by
    intro σ i; rw [preAct_smul]
  have hgen : ∀ σ : ℝ, |σ| = s → ∀ i, (∀ j, W i j = 0) ∨ preAct W b (σ • u) i ≠ 0 := by
    intro σ hσ i
    by_cases hrow : ∀ j, W i j = 0
    · exact Or.inl hrow
    · right
      push_neg at hrow
      have hdi : d i ≠ 0 := hu i hrow
      have hbi : |b i| < s * |d i| := hs i hdi
      rw [hpre]
      intro hzero
      have habs : |σ * d i| = s * |d i| := by rw [abs_mul, hσ]
      have hb : b i = -(σ * d i) := by linarith
      rw [hb, abs_neg, habs] at hbi
      exact lt_irrefl _ hbi
  have hplus := card_activeRows_ge W b hinj (s • u) (hgen s (abs_of_pos hs0))
  have hminus := card_activeRows_ge W b hinj ((-s) • u)
    (hgen (-s) (by rw [abs_neg, abs_of_pos hs0]))
  have hdisj : Disjoint (ActiveRows W b (s • u)) (ActiveRows W b ((-s) • u)) := by
    rw [Finset.disjoint_left]
    intro i hi hi'
    simp only [ActiveRows, Finset.mem_filter, Finset.mem_univ, true_and] at hi hi'
    obtain ⟨hp, hrow⟩ := hi
    obtain ⟨hm, -⟩ := hi'
    rw [hpre] at hp hm
    have hdi : d i ≠ 0 := hu i hrow
    have hbi : |b i| < s * |d i| := hs i hdi
    have h1 : |b i| < |s * d i| := by rwa [abs_mul, abs_of_pos hs0]
    rcases abs_lt.mp h1 with ⟨hlow, hhigh⟩
    rcases le_or_gt 0 (s * d i) with h | h
    · rw [abs_of_nonneg h] at hhigh
      nlinarith
    · rw [abs_of_neg h] at hhigh
      nlinarith
  exact ⟨s • u, (-s) • u, hplus, hminus, hdisj⟩

/-- **Main lower bound.**  An injective ReLU layer on `ℝⁿ` needs at least `2n` units.
For `n = 11` this is the statement that a lossless 11-dimensional perception layer needs at
least `22` neurons. -/
theorem two_mul_le_card_of_injective [Fintype ι] (W : ι → Fin n → ℝ) (b : ι → ℝ)
    (hinj : Function.Injective (reluLayer W b)) :
    2 * n ≤ Fintype.card ι := by
  classical
  obtain ⟨x, y, hx, hy, hdisj⟩ := exists_antipodal_probes W b hinj
  have hcard : (ActiveRows W b x).card + (ActiveRows W b y).card ≤ Fintype.card ι := by
    calc (ActiveRows W b x).card + (ActiveRows W b y).card
        = (ActiveRows W b x ∪ ActiveRows W b y).card :=
          (Finset.card_union_of_disjoint hdisj).symm
      _ ≤ Fintype.card ι := Finset.card_le_univ _
  omega

/-- Specialisation to the mission's dimension: a lossless 11-dimensional ReLU perception
layer needs at least `22` units. -/
theorem width_ge_22_of_injective [Fintype ι] (W : ι → Fin 11 → ℝ) (b : ι → ℝ)
    (hinj : Function.Injective (reluLayer W b)) : 22 ≤ Fintype.card ι := by
  have := two_mul_le_card_of_injective W b hinj
  omega

/-- Contrapositive form: no ReLU layer with fewer than `22` units can process an
11-dimensional percept without loss. -/
theorem no_injective_layer_of_card_lt [Fintype ι] (W : ι → Fin 11 → ℝ) (b : ι → ℝ)
    (hcard : Fintype.card ι < 22) : ¬ Function.Injective (reluLayer W b) := by
  intro h
  exact absurd (width_ge_22_of_injective W b h) (by omega)

/-! ## The matching construction: the positive/negative split layer -/

/-- The `2n`-unit "double" layer: unit `inl i` computes `x i⁺`, unit `inr i` computes `x i⁻`. -/
def doubleW (n : ℕ) : (Fin n ⊕ Fin n) → Fin n → ℝ
  | Sum.inl i, j => if i = j then 1 else 0
  | Sum.inr i, j => if i = j then -1 else 0

lemma preAct_doubleW_inl (x : Fin n → ℝ) (i : Fin n) :
    preAct (doubleW n) 0 x (Sum.inl i) = x i := by
  simp [preAct, doubleW]

lemma preAct_doubleW_inr (x : Fin n → ℝ) (i : Fin n) :
    preAct (doubleW n) 0 x (Sum.inr i) = -x i := by
  simp [preAct, doubleW]

/-- **Exact reconstruction.**  The `2n`-unit split layer admits a *linear* left inverse:
the input is recovered as the difference of the two halves.  No information is lost. -/
theorem doubleLayer_reconstruct (x : Fin n → ℝ) (i : Fin n) :
    reluLayer (doubleW n) 0 x (Sum.inl i) - reluLayer (doubleW n) 0 x (Sum.inr i) = x i := by
  simp only [reluLayer, preAct_doubleW_inl, preAct_doubleW_inr]
  exact relu_sub_relu_neg (x i)

/-- The `2n`-unit split layer is injective. -/
theorem doubleLayer_injective : Function.Injective (reluLayer (doubleW n) 0) := by
  intro x y hxy
  funext i
  rw [← doubleLayer_reconstruct x i, ← doubleLayer_reconstruct y i, hxy]

/-- Injectivity is preserved by re-indexing the output units. -/
lemma injective_reluLayer_reindex (e : ι' ≃ ι) (W : ι → Fin n → ℝ) (b : ι → ℝ)
    (h : Function.Injective (reluLayer W b)) :
    Function.Injective (reluLayer (fun i => W (e i)) (fun i => b (e i))) := by
  intro x y hxy
  apply h
  funext i
  have hc := congrFun hxy (e.symm i)
  simpa [reluLayer, preAct] using hc

/-- **Optimal architecture in dimension 11.**  `22` is the least number of ReLU units of a
layer on `ℝ¹¹` that processes every percept without dimensional reduction loss. -/
theorem isLeast_width_11 :
    IsLeast {m : ℕ | ∃ (W : Fin m → Fin 11 → ℝ) (b : Fin m → ℝ),
      Function.Injective (reluLayer W b)} 22 := by
  constructor
  · refine ⟨fun i => doubleW 11 (finSumFinEquiv.symm i), fun _ => 0, ?_⟩
    have h := injective_reluLayer_reindex (finSumFinEquiv.symm : Fin (11 + 11) ≃ Fin 11 ⊕ Fin 11)
      (doubleW 11) 0 doubleLayer_injective
    simpa using h
  · rintro m ⟨W, b, hinj⟩
    have h := width_ge_22_of_injective W b hinj
    simpa using h

end

end HyperAwareness11D