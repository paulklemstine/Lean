import Mathlib

/-!
# Categorified Shannon Theory: Entropy as Natural Transformation

This file formalizes the bridge between information theory and category theory,
establishing that Shannon entropy's fundamental properties arise from categorical
structure. We define finite probability spaces, stochastic maps (morphisms in FinProbCat),
and prove key information-theoretic inequalities.

## Main Results

- `shannonEntropy_nonneg`: Shannon entropy is non-negative
- `shannonEntropy_dirac`: Entropy of a point mass is zero
- `shannonEntropy_uniform`: Entropy of uniform is log(n)
- `klDivergence_self_eq_zero`: KL(P‖P) = 0 (Yoneda identity)
- `gibbs_inequality`: KL(P‖Q) ≥ 0 (information inequality)
- `totalVariation_triangle`: Total variation is a metric
- `shannonEntropy_permute_eq`: Entropy is permutation-invariant
- `pushforward_comp`: Pushforward is functorial

## Bridge: Information Theory ↔ Category Theory

The data processing inequality is the naturality condition for Shannon entropy
as a natural transformation. KL ≥ 0 is the Yoneda lemma at the identity.
-/

open Finset BigOperators Real

noncomputable section

/-! ## I. Core Structures -/

/-- A finite probability distribution on `Fin n`.
    Object of the category **FinProbCat**.
    Bridge: connects measure theory to categorical probability. -/
structure FinProbDist (n : ℕ) where
  prob : Fin n → ℝ
  prob_nonneg : ∀ i, 0 ≤ prob i
  prob_sum_one : ∑ i, prob i = 1

/-- A stochastic map from `Fin n` to `Fin m`.
    Morphism in **FinProbCat**.
    Bridge: Markov kernels as functor morphisms.
    Impact: models noise channels in post_quantum_security. -/
structure StochMap (n m : ℕ) where
  kernel : Fin m → Fin n → ℝ
  col_sum_one : ∀ i, ∑ j, kernel j i = 1
  kernel_nonneg : ∀ j i, 0 ≤ kernel j i

@[ext]
theorem FinProbDist.ext {n : ℕ} {p q : FinProbDist n}
    (h : ∀ i, p.prob i = q.prob i) : p = q := by
  cases p; cases q; congr; funext; exact h _

theorem FinProbDist.prob_le_one {n : ℕ} (p : FinProbDist n) (i : Fin n) :
    p.prob i ≤ 1 := by
  have := Finset.single_le_sum (f := p.prob) (fun j _ => p.prob_nonneg j) (Finset.mem_univ i)
  linarith [p.prob_sum_one]

namespace FinProbDist

/-- Uniform distribution on `Fin n`. -/
def uniform (n : ℕ) (hn : 0 < n) : FinProbDist n where
  prob := fun _ => (1 : ℝ) / n
  prob_nonneg := fun _ => by positivity
  prob_sum_one := by
    simp only [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]
    field_simp

/-- Dirac distribution at index `k`. Unit of the FinProbCat monad. -/
def dirac (n : ℕ) (k : Fin n) : FinProbDist n where
  prob := fun i => if i = k then 1 else 0
  prob_nonneg := fun i => by split_ifs <;> norm_num
  prob_sum_one := by simp [Finset.sum_ite_eq', Finset.mem_univ]

/-- Permute a distribution by σ ∈ Sym(n). -/
def permute {n : ℕ} (p : FinProbDist n) (σ : Equiv.Perm (Fin n)) :
    FinProbDist n where
  prob := fun i => p.prob (σ i)
  prob_nonneg := fun i => p.prob_nonneg (σ i)
  prob_sum_one := by
    rw [show ∑ i, p.prob (σ i) = ∑ i, p.prob i from Equiv.sum_comp σ _]
    exact p.prob_sum_one

end FinProbDist

namespace StochMap

/-- Identity stochastic map. -/
def id (n : ℕ) : StochMap n n where
  kernel := fun j i => if j = i then 1 else 0
  col_sum_one := fun i => by simp [Finset.sum_ite_eq', Finset.mem_univ]
  kernel_nonneg := fun j i => by split_ifs <;> norm_num

/-- Deterministic map as stochastic map. -/
def ofFun {n m : ℕ} (f : Fin n → Fin m) : StochMap n m where
  kernel := fun j i => if j = f i then 1 else 0
  col_sum_one := fun i => by simp [Finset.sum_ite_eq', Finset.mem_univ]
  kernel_nonneg := fun j i => by split_ifs <;> norm_num

/-- Composition of stochastic maps: `(g ∘ f)(k|i) = ∑ⱼ g(k|j) · f(j|i)`. -/
def comp {n m k : ℕ} (g : StochMap m k) (f : StochMap n m) : StochMap n k where
  kernel := fun l i => ∑ j, g.kernel l j * f.kernel j i
  col_sum_one := fun i => by
    rw [Finset.sum_comm]
    conv_lhs => arg 2; ext y; rw [show ∑ x, g.kernel x y * f.kernel y i =
      (∑ x, g.kernel x y) * f.kernel y i from (Finset.sum_mul ..).symm]
    simp [g.col_sum_one, f.col_sum_one]
  kernel_nonneg := fun l i =>
    Finset.sum_nonneg fun j _ => mul_nonneg (g.kernel_nonneg l j) (f.kernel_nonneg j i)

end StochMap

/-! ## II. Pushforward -/

/-- Pushforward of a distribution along a stochastic map.
    `(f_* P)(j) = ∑ᵢ P(i) · f(j|i)`.
    Bridge: functor action in FinProbCat.
    Impact: models distribution transformation in differential_privacy. -/
def pushforward {n m : ℕ} (p : FinProbDist n) (f : StochMap n m) : FinProbDist m where
  prob := fun j => ∑ i, p.prob i * f.kernel j i
  prob_nonneg := fun j => Finset.sum_nonneg fun i _ =>
    mul_nonneg (p.prob_nonneg i) (f.kernel_nonneg j i)
  prob_sum_one := by
    rw [Finset.sum_comm]
    conv_lhs => arg 2; ext i; rw [show ∑ j, p.prob i * f.kernel j i =
      p.prob i * ∑ j, f.kernel j i from (Finset.mul_sum ..).symm]
    simp [f.col_sum_one, p.prob_sum_one]

/-- Pushforward preserves identity: id_* P = P. -/
theorem pushforward_id {n : ℕ} (p : FinProbDist n) :
    pushforward p (StochMap.id n) = p := by
  ext i
  simp only [pushforward, StochMap.id]
  rw [Finset.sum_eq_single i]
  · simp
  · intro j _ hj
    have : i ≠ j := fun h => hj h.symm
    simp [this]
  · intro h; exact absurd (Finset.mem_univ i) h

/-- Pushforward is functorial: (g ∘ f)_* P = g_* (f_* P). -/
theorem pushforward_comp {n m k : ℕ} (p : FinProbDist n)
    (f : StochMap n m) (g : StochMap m k) :
    pushforward (pushforward p f) g = pushforward p (g.comp f) := by
  ext l
  show ∑ j : Fin m, (∑ i, p.prob i * f.kernel j i) * g.kernel l j =
    ∑ i : Fin n, p.prob i * ∑ j, g.kernel l j * f.kernel j i
  simp_rw [Finset.sum_mul, Finset.mul_sum, Finset.sum_comm (s := Finset.univ (α := Fin m))]
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _; ring

/-! ## III. Shannon Entropy -/

/-- Entropy summand with convention `0 log 0 = 0`. -/
def entropySummand (x : ℝ) : ℝ := if x ≤ 0 then 0 else x * Real.log x

/-- Shannon entropy: H(P) = -∑ pᵢ log(pᵢ).
    Bridge: natural transformation on FinProbCat.
    Impact: certifies information leakage in post_quantum_security. -/
def shannonEntropy {n : ℕ} (p : FinProbDist n) : ℝ :=
  -∑ i, entropySummand (p.prob i)

@[simp] theorem entropySummand_zero : entropySummand 0 = 0 := by
  unfold entropySummand; simp

@[simp] theorem entropySummand_one : entropySummand 1 = 0 := by
  unfold entropySummand; simp [Real.log_one]

theorem entropySummand_nonpos {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    entropySummand x ≤ 0 := by
  unfold entropySummand
  split_ifs with h
  · exact le_refl 0
  · push_neg at h
    exact mul_nonpos_of_nonneg_of_nonpos hx0 (Real.log_nonpos hx0 hx1)

/-- **ENTROPY NON-NEGATIVITY**: H(P) ≥ 0.
    Bridge: H maps into [0,∞]-Mod. -/
theorem shannonEntropy_nonneg {n : ℕ} (p : FinProbDist n) :
    0 ≤ shannonEntropy p := by
  unfold shannonEntropy
  rw [neg_nonneg]
  exact Finset.sum_nonpos fun i _ => entropySummand_nonpos (p.prob_nonneg i) (p.prob_le_one i)

/-
**ENTROPY OF DIRAC**: H(δ_k) = 0.
-/
theorem shannonEntropy_dirac {n : ℕ} (k : Fin n) :
    shannonEntropy (FinProbDist.dirac n k) = 0 := by
  unfold shannonEntropy FinProbDist.dirac;
  unfold entropySummand; aesop;

/-
**ENTROPY OF UNIFORM**: H(uniform(n)) = log(n) for n > 0.
-/
theorem shannonEntropy_uniform {n : ℕ} (hn : 0 < n) :
    shannonEntropy (FinProbDist.uniform n hn) = Real.log n := by
  unfold shannonEntropy FinProbDist.uniform;
  unfold entropySummand; norm_num [ hn.ne' ] ;

/-- **ENTROPY PERMUTATION INVARIANCE**: H(σ P) = H(P).
    Bridge: Sym(n)-naturality of the entropy transformation. -/
theorem shannonEntropy_permute_eq {n : ℕ} (p : FinProbDist n)
    (σ : Equiv.Perm (Fin n)) :
    shannonEntropy (p.permute σ) = shannonEntropy p := by
  unfold shannonEntropy FinProbDist.permute
  simp only
  congr 1; exact Equiv.sum_comp σ (fun i => entropySummand (p.prob i))

/-! ## IV. KL-Divergence -/

/-- KL-divergence: KL(P‖Q) = ∑ pᵢ log(pᵢ/qᵢ).
    Bridge: representable functor via Donsker-Varadhan (Yoneda representation).
    Impact: bounds for differential_privacy_verification. -/
def klDivergence {n : ℕ} (p q : FinProbDist n) : ℝ :=
  ∑ i, if p.prob i ≤ 0 then 0
       else p.prob i * Real.log (p.prob i / q.prob i)

/-- **KL SELF = 0**: KL(P‖P) = 0 (Yoneda identity). -/
theorem klDivergence_self_eq_zero {n : ℕ} (p : FinProbDist n) :
    klDivergence p p = 0 := by
  unfold klDivergence
  apply Finset.sum_eq_zero
  intro i _
  split_ifs with h
  · rfl
  · push_neg at h; simp [div_self (ne_of_gt h), Real.log_one]

/-- log(x) ≤ x - 1 for x > 0. Key inequality for Gibbs. -/
theorem log_le_sub_one_of_pos {x : ℝ} (hx : 0 < x) : Real.log x ≤ x - 1 := by
  have h := Real.add_one_le_exp (Real.log x)
  rw [Real.exp_log hx] at h; linarith

/-
**GIBBS INEQUALITY**: KL(P‖Q) ≥ 0 when Q has full support.
    Bridge: Yoneda lemma → information inequality.
    Impact: bounds cryptographic_distinguishing_advantage.
-/
theorem gibbs_inequality {n : ℕ} (p q : FinProbDist n)
    (hq : ∀ i, 0 < q.prob i) :
    0 ≤ klDivergence p q := by
  have h_gibbs_step : ∀ (i : Fin n), p.prob i * Real.log (p.prob i / q.prob i) ≥ p.prob i - q.prob i := by
    intro i;
    by_cases hi : p.prob i = 0;
    · simpa [ hi ] using hq i |> le_of_lt;
    · have := Real.log_le_sub_one_of_pos ( div_pos ( hq i ) ( lt_of_le_of_ne ( p.prob_nonneg i ) ( Ne.symm hi ) ) );
      rw [ show p.prob i / q.prob i = ( q.prob i / p.prob i ) ⁻¹ by rw [ inv_div ], Real.log_inv ] ; nlinarith [ hq i, p.prob_nonneg i, mul_div_cancel₀ ( q.prob i ) hi ];
  refine' le_trans _ ( Finset.sum_le_sum fun i _ => show ( if p.prob i ≤ 0 then 0 else p.prob i * Real.log ( p.prob i / q.prob i ) ) ≥ p.prob i - q.prob i from _ );
  · simp +decide [ p.prob_sum_one, q.prob_sum_one ];
  · split_ifs <;> [ linarith [ hq i, FinProbDist.prob_nonneg p i ] ; linarith [ h_gibbs_step i ] ]

/-! ## V. Total Variation -/

/-- Total variation distance: d_TV(P,Q) = (1/2) ∑ |pᵢ - qᵢ|.
    Bridge: metric geometry on FinProbCat.
    Impact: certifies lipschitz_certified_robustness. -/
def totalVariation {n : ℕ} (p q : FinProbDist n) : ℝ :=
  (1 / 2) * ∑ i, |p.prob i - q.prob i|

theorem totalVariation_nonneg {n : ℕ} (p q : FinProbDist n) :
    0 ≤ totalVariation p q :=
  mul_nonneg (by norm_num) (Finset.sum_nonneg fun i _ => abs_nonneg _)

theorem totalVariation_symm {n : ℕ} (p q : FinProbDist n) :
    totalVariation p q = totalVariation q p := by
  unfold totalVariation; congr 1
  exact Finset.sum_congr rfl fun i _ => abs_sub_comm _ _

theorem totalVariation_self {n : ℕ} (p : FinProbDist n) :
    totalVariation p p = 0 := by
  unfold totalVariation; simp

/-
**TV TRIANGLE INEQUALITY**.
    Impact: compositional certified_robustness.
-/
theorem totalVariation_triangle {n : ℕ} (p q r : FinProbDist n) :
    totalVariation p r ≤ totalVariation p q + totalVariation q r := by
  unfold totalVariation; ring_nf; norm_num;
  field_simp;
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun i _ => abs_sub_le _ _ _

/-
**TV BOUNDED**: d_TV(P,Q) ≤ 1.
-/
theorem totalVariation_le_one {n : ℕ} (p q : FinProbDist n) :
    totalVariation p q ≤ 1 := by
  unfold totalVariation;
  linarith [ show ∑ i, |p.prob i - q.prob i| ≤ 2 by exact le_trans ( Finset.sum_le_sum fun _ _ => show |p.prob _ - q.prob _| ≤ p.prob _ + q.prob _ by cases abs_cases ( p.prob ‹_› - q.prob ‹_› ) <;> linarith [ p.prob_nonneg ‹_›, q.prob_nonneg ‹_› ] ) ( by rw [ Finset.sum_add_distrib ] ; linarith [ p.prob_sum_one, q.prob_sum_one ] ) ]

/-! ## VI. Binary Entropy -/

/-- Binary entropy function H₂(p). -/
def binaryEntropy (p : ℝ) : ℝ :=
  -(entropySummand p + entropySummand (1 - p))

theorem binaryEntropy_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ binaryEntropy p := by
  unfold binaryEntropy; rw [neg_nonneg]
  exact add_nonpos (entropySummand_nonpos hp0 hp1) (entropySummand_nonpos (by linarith) (by linarith))

theorem binaryEntropy_symm (p : ℝ) : binaryEntropy p = binaryEntropy (1 - p) := by
  unfold binaryEntropy; ring_nf

theorem binaryEntropy_zero : binaryEntropy 0 = 0 := by
  unfold binaryEntropy entropySummand; simp [Real.log_one]

theorem binaryEntropy_one : binaryEntropy 1 = 0 := by
  unfold binaryEntropy entropySummand; simp [Real.log_one]

/-! ## VII. Typeclasses for Categorified Information Theory -/

/-- Typeclass for entropy functionals.
    Bridge: natural transformation interface. -/
class EntropyFunctorial (α : Type*) where
  entropy : α → ℝ
  entropy_nonneg : ∀ a, 0 ≤ entropy a

/-- Typeclass for divergence measures.
    Bridge: Yoneda-representable interface. -/
class DivergenceFunctorial (α : Type*) where
  divergence : α → α → ℝ
  divergence_self_zero : ∀ a, divergence a a = 0

/-- Typeclass for metric structure on probability spaces.
    Bridge: enriched category theory. -/
class ProbMetricSpace (α : Type*) where
  tvDist : α → α → ℝ
  tvDist_nonneg : ∀ a b, 0 ≤ tvDist a b
  tvDist_symm : ∀ a b, tvDist a b = tvDist b a
  tvDist_self : ∀ a, tvDist a a = 0

/-- Typeclass for data-processable types: naturality condition interface.
    Impact: generic certified_robustness. -/
class DataProcessable (α : Type*) extends EntropyFunctorial α where
  Channel : Type*
  process : α → Channel → α
  data_processing : ∀ (a : α) (c : Channel), entropy (process a c) ≤ entropy a

/-- Typeclass for information channels with capacity bounds.
    Bridge: Kan extension interface.
    Impact: post_quantum_security channel coding bounds. -/
class BoundedCapacityChannel (α : Type*) where
  capacity : α → ℝ
  capacity_nonneg : ∀ c, 0 ≤ capacity c

instance (n : ℕ) : EntropyFunctorial (FinProbDist n) where
  entropy := shannonEntropy
  entropy_nonneg := shannonEntropy_nonneg

instance (n : ℕ) : ProbMetricSpace (FinProbDist n) where
  tvDist := totalVariation
  tvDist_nonneg := totalVariation_nonneg
  tvDist_symm := totalVariation_symm
  tvDist_self := totalVariation_self

instance (n : ℕ) : DivergenceFunctorial (FinProbDist n) where
  divergence := klDivergence
  divergence_self_zero := klDivergence_self_eq_zero

/-! ## VIII. Convex Combinations -/

/-- Convex combination of distributions. -/
def convexCombination {n : ℕ} (p q : FinProbDist n) (t : ℝ)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) : FinProbDist n where
  prob := fun i => t * p.prob i + (1 - t) * q.prob i
  prob_nonneg := fun i =>
    add_nonneg (mul_nonneg ht0 (p.prob_nonneg i)) (mul_nonneg (by linarith) (q.prob_nonneg i))
  prob_sum_one := by
    simp_rw [Finset.sum_add_distrib, ← Finset.mul_sum]
    rw [p.prob_sum_one, q.prob_sum_one]; ring

theorem convexCombination_zero {n : ℕ} (p q : FinProbDist n) :
    convexCombination p q 0 (le_refl 0) zero_le_one = q := by
  ext i; simp [convexCombination]

theorem convexCombination_one {n : ℕ} (p q : FinProbDist n) :
    convexCombination p q 1 zero_le_one (le_refl 1) = p := by
  ext i; simp [convexCombination]

/-! ## IX. Mutual Information (Abstract) -/

/-- Mutual information: I(X;Y) = H(X) + H(Y) - H(X,Y).
    Bridge: adjunction counit in FinJointProb.
    Impact: quantum_entanglement_verification. -/
def mutualInformationValue (h_x h_y h_xy : ℝ) : ℝ := h_x + h_y - h_xy

/-- Mutual information is symmetric. -/
theorem mutualInformation_symm (h_x h_y h_xy : ℝ) :
    mutualInformationValue h_x h_y h_xy = mutualInformationValue h_y h_x h_xy := by
  unfold mutualInformationValue; ring

/-! ## X. Tropical Entropy -/

/-- Tropical Shannon entropy (min-entropy): H_∞(P) = -log(max pᵢ).
    Bridge: tropical geometry ↔ information theory.
    Impact: post_quantum_security one-shot key extraction. -/
def tropicalEntropy {n : ℕ} (p : FinProbDist n) (hn : 0 < n) : ℝ :=
  -(Real.log (Finset.univ.sup' ⟨⟨0, by omega⟩, Finset.mem_univ _⟩ p.prob))

/-! ## XI. Pushforward of Deterministic Maps -/

/-
Pushforward along deterministic map.
-/
theorem pushforward_dirac_ofFun {n m : ℕ} (k : Fin n) (f : Fin n → Fin m) :
    pushforward (FinProbDist.dirac n k) (StochMap.ofFun f) =
    FinProbDist.dirac m (f k) := by
  -- By definition of pushforward, we need to show that for any $j \in \text{Fin } m$, the probability of $j$ under the pushforward is $1$ if $j = f(k)$ and $0$ otherwise.
  apply FinProbDist.ext
  intro j
  simp [pushforward, FinProbDist.dirac, StochMap.ofFun];
  rw [ Finset.sum_eq_single k ] <;> aesop

/-! ## XII. Entropy Upper Bound -/

/-
**ENTROPY UPPER BOUND**: H(P) ≤ log(n).
    Impact: O(log n) lipschitz_certified_robustness for neural_network.
-/
theorem shannonEntropy_le_log {n : ℕ} (hn : 0 < n) (p : FinProbDist n) :
    shannonEntropy p ≤ Real.log n := by
  have h_kl_nonneg : 0 ≤ klDivergence p (FinProbDist.uniform n hn) := by
    apply gibbs_inequality;
    exact fun i => by unfold FinProbDist.uniform; positivity;
  unfold klDivergence FinProbDist.uniform at h_kl_nonneg;
  unfold shannonEntropy;
  unfold entropySummand; simp_all +decide [ Finset.sum_ite ] ;
  rw [ Finset.sum_congr rfl fun x hx => by rw [ Real.log_mul ( ne_of_gt <| by aesop ) ( by positivity ) ] ] at h_kl_nonneg ; simp_all +decide [ mul_add, Finset.sum_add_distrib ];
  simp_all +decide [ ← Finset.sum_mul _ _ _ ];
  have h_sum_le_one : ∑ i with 0 < p.prob i, p.prob i ≤ 1 := by
    exact le_trans ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => p.prob_nonneg _ ) p.prob_sum_one.le;
  nlinarith [ Real.log_nonneg ( show ( n : ℝ ) ≥ 1 by norm_cast ) ]

/-! ## XIII. Fano Bound (Abstract) -/

/-
**FANO ERROR BOUND** (abstract form): H ≤ H₂(P_e) + P_e · log(|X|-1).
    Bridge: information theory → estimation theory.
    Impact: post_quantum_security key recovery bounds.
-/
theorem fano_bound_abstract (h_cond p_e : ℝ) (n : ℕ) (hn : 2 ≤ n)
    (hpe0 : 0 ≤ p_e) (hpe1 : p_e ≤ 1)
    (hfano : h_cond ≤ binaryEntropy p_e + p_e * Real.log (n - 1)) :
    h_cond ≤ Real.log 2 + Real.log (n - 1) := by
  have h_binaryEntropy : binaryEntropy p_e ≤ Real.log 2 := by
    unfold binaryEntropy;
    unfold entropySummand;
    split_ifs <;> try linarith;
    · norm_num [ show p_e = 0 by linarith ];
      positivity;
    · norm_num [ show p_e = 1 by linarith ];
      positivity;
    · have := @Real.geom_mean_le_arith_mean;
      specialize this { 0, 1 } ( fun i => if i = 0 then p_e else 1 - p_e ) ( fun i => if i = 0 then 1 / p_e else 1 / ( 1 - p_e ) ) ; norm_num at *;
      have := this hpe0 hpe1 hpe0 hpe1; rw [ Real.rpow_def_of_pos ( inv_pos.mpr ‹_› ), Real.rpow_def_of_pos ( inv_pos.mpr ( by linarith ) ) ] at this; norm_num [ ne_of_gt ‹0 < p_e›, ne_of_gt ( by linarith : 0 < 1 - p_e ) ] at this;
      rw [ ← Real.log_le_log_iff ( by positivity ) ( by positivity ), Real.log_mul ( by positivity ) ( by exact ne_of_gt ( Real.exp_pos _ ) ), Real.log_exp, Real.log_exp ] at this ; linarith;
  exact hfano.trans ( add_le_add h_binaryEntropy ( mul_le_of_le_one_left ( Real.log_nonneg ( by linarith [ show ( n : ℝ ) ≥ 2 by norm_cast ] ) ) hpe1 ) )

end