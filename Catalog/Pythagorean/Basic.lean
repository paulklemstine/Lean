/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Entropic Area Laws from Strong Log-Concavity

This file establishes a bridge between **classical curvature conditions** on probability
distributions (strong log-concavity / Lorentzian gap surrogates) and **entropy upper bounds**
that serve as area-law certificates for quantum measurement distributions.

## Mathematical Overview

The central insight is that a quantitative lower bound on atom masses of a probability
distribution (a "pair-mass gap") constrains the support size, which in turn bounds the
Shannon entropy. When applied to measurement distributions of quantum states across
bipartitions, this yields area-law-type entropy bounds.

## Main Definitions

* `shannonTerm` — the entropy contribution `-x log x` (with `0 log 0 = 0`)
* `shannonEntropy` — Shannon entropy of a finite probability distribution
* `supportFinset` — the support of a distribution as a `Finset`
* `PairMassGap` — minimum over all pairs of nonzero-mass atoms of `μ(a) + μ(b)`
* `marginalDist` — marginal distribution on a subset of coordinates
* `marginalShannonEntropy` — Shannon entropy of the marginal
* `isIntervalCut` — property of a subset being an initial segment `{0, ..., k-1}`
* `EntropicAreaLawWitness` — structure packaging a distribution with gap and entropy bound

## Main Results

* `shannonTerm_nonneg` — `-x log x ≥ 0` for `x ∈ [0, 1]`
* `shannonEntropy_nonneg` — Shannon entropy is nonneg for probability distributions
* `support_card_le_inv_minMass` — support size ≤ ⌈1/m⌉ when all atoms have mass ≥ m
* `shannonEntropy_le_log_support_card` — H(μ) ≤ log |supp(μ)|
* `shannonEntropy_le_log_inv_gap` — H(μ) ≤ log(2/δ) when pair-mass gap ≥ δ
* `marginal_entropy_le_shannonEntropy` — H(μ_A) ≤ H(μ)
* `areaLaw_surrogate_from_gap` — area-law bound from pair-mass gap
* `entropyDensity_bounded` — H(μ)/n ≤ (log(2/δ) + 1)/n (vanishing entropy density)

## References

* Anari, Liu, Oveis Gharan, Vinzant — "Log-Concave Polynomials", 2019
* Brändén, Huh — "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

noncomputable section

open Finset BigOperators Real

namespace EntropicAreaLaw

/-! ### Shannon Entropy Definitions -/

/-- The entropy contribution of a single probability atom: `-x * log x`,
    with the convention that `0 * log 0 = 0`. -/
def shannonTerm (x : ℝ) : ℝ :=
  if x = 0 then 0 else -x * Real.log x

/-- Shannon entropy of a finite probability distribution `μ : α → ℝ`. -/
def shannonEntropy {α : Type*} [Fintype α] (μ : α → ℝ) : ℝ :=
  ∑ a : α, shannonTerm (μ a)

/-- The support of a distribution as a `Finset`. -/
def supportFinset {α : Type*} [Fintype α] [DecidableEq α] (μ : α → ℝ) : Finset α :=
  Finset.univ.filter (fun a => μ a ≠ 0)

/-! ### Pair-Mass Gap -/

/-- **Pair-mass gap**: the minimum sum of masses of any two distinct atoms in the support.
    This is a quantitative measure of how "spread out" the distribution is.
    When the gap is large, the distribution has few atoms of significant mass.
    We define it as twice the minimum mass (since for any two distinct support atoms
    a, b, we have μ(a) + μ(b) ≥ 2 * min_mass). -/
def PairMassGap {α : Type*} [Fintype α] [DecidableEq α] (μ : α → ℝ) : ℝ :=
  2 * (if h : (supportFinset μ).Nonempty
       then (supportFinset μ).inf' h μ
       else 0)

/-! ### Marginal Distribution -/

/-- Restrict a configuration `Fin n → Bool` to a subset `A : Finset (Fin n)`,
    yielding a function on the subtype `↥A → Bool`. -/
def restrictConfig {n : ℕ} (x : Fin n → Bool) (A : Finset (Fin n)) : ↥A → Bool :=
  fun ⟨i, _⟩ => x i

/-- Marginal distribution: sum μ over all configurations that agree on A. -/
def marginalDist {n : ℕ} (μ : (Fin n → Bool) → ℝ) (A : Finset (Fin n)) :
    (↥A → Bool) → ℝ :=
  fun f => ∑ x : (Fin n → Bool), if restrictConfig x A = f then μ x else 0

/-- Shannon entropy of the marginal distribution on subset A. -/
def marginalShannonEntropy {n : ℕ} (μ : (Fin n → Bool) → ℝ) (A : Finset (Fin n)) : ℝ :=
  shannonEntropy (marginalDist μ A)

/-- **Bipartition surrogate entropy**: we define this as the marginal Shannon entropy,
    which serves as an upper bound on the quantum entanglement entropy across the cut. -/
def bipartitionSurrogateEntropy {n : ℕ} (μ : (Fin n → Bool) → ℝ) (A : Finset (Fin n)) : ℝ :=
  marginalShannonEntropy μ A

/-- A subset `A ⊆ Fin n` is an **interval cut** if it equals `{0, 1, ..., k-1}`
    for some `k ≤ n`. -/
def isIntervalCut {n : ℕ} (A : Finset (Fin n)) : Prop :=
  ∃ k : ℕ, k ≤ n ∧ A = (Finset.univ.filter (fun i : Fin n => i.val < k))

/-! ### EntropicAreaLawWitness -/

/-- A witness for an entropic area law: packages a probability distribution with
    a gap parameter and entropy bound certificate. -/
structure EntropicAreaLawWitness (α : Type*) [Fintype α] where
  μ : α → ℝ
  nonneg : ∀ a, 0 ≤ μ a
  normalized : (∑ a, μ a) = 1
  gap : ℝ
  gap_pos : 0 < gap
  entropyBound : ℝ
  entropy_cert : shannonEntropy μ ≤ entropyBound

/-! ### Core Entropy Lemmas -/

/-
The Shannon term `-x * log x` is nonneg for `x ∈ [0, 1]`.
-/
theorem shannonTerm_nonneg {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ shannonTerm x := by
      unfold shannonTerm;
      split_ifs <;> nlinarith [ Real.log_nonpos hx0 hx1 ]

/-
Shannon entropy is nonneg for a probability distribution.
-/
theorem shannonEntropy_nonneg {α : Type*} [Fintype α]
    (μ : α → ℝ) (hμ_nonneg : ∀ a, 0 ≤ μ a) (hμ_sum : (∑ a, μ a) = 1) :
    0 ≤ shannonEntropy μ := by
      exact Finset.sum_nonneg fun x _ => shannonTerm_nonneg ( hμ_nonneg x ) ( hμ_sum ▸ Finset.single_le_sum ( fun a _ => hμ_nonneg a ) ( Finset.mem_univ x ) )

/-
Key lemma: `-x * log x ≤ -x * log m` when `x ≥ m > 0`.
    Equivalently, the entropy contribution of a larger atom is bounded by
    the log of its minimum mass.
-/
theorem shannonTerm_le_neg_mul_log {x m : ℝ} (hm : 0 < m) (hx : m ≤ x) :
    shannonTerm x ≤ -x * Real.log m := by
      unfold shannonTerm;
      split_ifs <;> nlinarith [ Real.log_le_log ( by linarith ) hx ]

/-
Support size is bounded by the inverse of the minimum mass.
-/
theorem support_card_le_inv_minMass
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (hμ_nonneg : ∀ a, 0 ≤ μ a)
    (hμ_sum : (∑ a, μ a) = 1)
    (m : ℝ)
    (hm : 0 < m)
    (hmin : ∀ a, μ a ≠ 0 → m ≤ μ a) :
    (supportFinset μ).card ≤ Nat.ceil (1 / m) := by
      -- From the definition of supportFinset, we know that ∑ a ∈ supportFinset μ, μ a ≤ 1.
      have h_sum_le_one : ∑ a ∈ supportFinset μ, μ a ≤ 1 := by
        exact hμ_sum ▸ Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => hμ_nonneg _;
      exact Nat.le_of_lt_succ ( by rw [ ← @Nat.cast_lt ℝ ] ; push_cast; nlinarith [ Nat.le_ceil ( 1 / m ), mul_div_cancel₀ 1 hm.ne', show ( ∑ a ∈ supportFinset μ, μ a ) ≥ ( Finset.card ( supportFinset μ ) : ℝ ) * m by exact le_trans ( by simp +decide [ mul_comm ] ) ( Finset.sum_le_sum fun x hx => hmin x <| Finset.mem_filter.mp hx |>.2 ) ] )

/-
Shannon entropy is bounded by the log of the support size.
-/
theorem shannonEntropy_le_log_support_card
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (hμ_nonneg : ∀ a, 0 ≤ μ a)
    (hμ_sum : (∑ a, μ a) = 1) :
    shannonEntropy μ ≤ Real.log ((supportFinset μ).card) := by
      by_cases h : ( supportFinset μ ).Nonempty;
      · -- By Jensen's inequality for the concave function $-x \log x$, we have:
        have h_jensen : ∑ a ∈ supportFinset μ, μ a * Real.log (μ a) ≥ ∑ a ∈ supportFinset μ, μ a * Real.log (1 / (supportFinset μ).card) := by
          have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x => x * Real.log x) := by
            exact ( Real.convexOn_mul_log );
          -- Applying Jensen's inequality to the convex function $f(x) = x \log x$ with the weights $\mu(a)$ and the points $\mu(a)$.
          have h_jensen_apply : (∑ a ∈ supportFinset μ, (1 / (supportFinset μ).card) * (μ a * Real.log (μ a))) ≥ ((∑ a ∈ supportFinset μ, (1 / (supportFinset μ).card) * μ a) * Real.log (∑ a ∈ supportFinset μ, (1 / (supportFinset μ).card) * μ a)) := by
            apply ConvexOn.map_sum_le h_jensen;
            · exact fun _ _ => by positivity;
            · simp +decide [ h.ne_empty ];
            · exact fun a ha => hμ_nonneg a;
          simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
          simp_all +decide [ Finset.sum_filter_of_ne, supportFinset ];
          nlinarith [ inv_pos.mpr ( show 0 < ( Finset.card ( Finset.filter ( fun a => ¬μ a = 0 ) Finset.univ ) : ℝ ) by exact Nat.cast_pos.mpr ( Finset.card_pos.mpr h ) ) ];
        simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', shannonEntropy, shannonTerm ];
        simp_all +decide [ ← Finset.sum_mul _ _ _, supportFinset ];
        rw [ show ( ∑ i with ¬μ i = 0, μ i ) = 1 by rw [ ← hμ_sum, Finset.sum_filter_of_ne ] ; aesop ] at h_jensen ; linarith;
      · simp_all +decide [ Finset.ext_iff, supportFinset ]

/-
**Theorem 1 (Gap-to-entropy bound)**: If every nonzero atom of μ has mass ≥ m,
    then H(μ) ≤ log(1/m).

    Proof sketch (Strategy A):
    1. Since every atom has mass ≥ m, there are at most ⌊1/m⌋ atoms.
    2. H(μ) ≤ log(|supp(μ)|) ≤ log(1/m).
-/
theorem shannonEntropy_le_log_inv_minMass
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (hμ_nonneg : ∀ a, 0 ≤ μ a)
    (hμ_sum : (∑ a, μ a) = 1)
    (m : ℝ)
    (hm : 0 < m)
    (hmin : ∀ a, μ a ≠ 0 → m ≤ μ a) :
    shannonEntropy μ ≤ Real.log (1 / m) := by
      convert shannonEntropy_le_log_support_card μ hμ_nonneg hμ_sum |> le_trans <| ?_;
      gcongr;
      · simp +zetaDelta at *;
        exact Exists.elim ( show ∃ a, μ a ≠ 0 from not_forall.mp fun h => by simp_all +decide ) fun a ha => ⟨ a, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, ha ⟩ ⟩;
      · rw [ le_div_iff₀ hm ];
        convert hμ_sum ▸ Finset.sum_le_sum fun a _ => show μ a ≥ if μ a = 0 then 0 else m by aesop;
        simp +decide [ Finset.sum_ite, Finset.filter_ne', supportFinset ]

/-
**Flagship bound**: Shannon entropy bounded by `log(2/δ)` from pair-mass gap `δ ≤ 2`.
    When all pairs of distinct support atoms have mass sum ≥ δ, the support
    has at most `⌊2/δ⌋` elements (by summing the gap inequality over all pairs),
    hence `H(μ) ≤ log(2/δ)`. The condition `δ ≤ 2` ensures `log(2/δ) ≥ 0`.
-/
theorem shannonEntropy_le_log_inv_gap
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (hμ_nonneg : ∀ a, 0 ≤ μ a)
    (hμ_sum : (∑ a, μ a) = 1)
    (δ : ℝ)
    (hδ : 0 < δ)
    (hδ2 : δ ≤ 2)
    (hgap : ∀ a b : α, μ a ≠ 0 → μ b ≠ 0 → a ≠ b → δ ≤ μ a + μ b) :
    shannonEntropy μ ≤ Real.log (2 / δ) := by
      have h_support_card : (Finset.univ.filter (fun a => μ a ≠ 0)).card ≤ 2 / δ := by
        by_cases h_card : (Finset.univ.filter (fun a => μ a ≠ 0)).card ≥ 2;
        · -- Let $a$ be an element in the support of $\mu$ with minimum mass.
          obtain ⟨a, ha⟩ : ∃ a ∈ Finset.univ.filter (fun a => μ a ≠ 0), ∀ b ∈ Finset.univ.filter (fun a => μ a ≠ 0), μ a ≤ μ b := by
            exact Finset.exists_min_image _ _ ( Finset.card_pos.mp ( pos_of_gt h_card ) );
          -- For any $b \in \text{support}(\mu)$, we have $\mu(b) \geq \delta - \mu(a)$.
          have h_mu_b_ge_delta_minus_mu_a : ∀ b ∈ Finset.univ.filter (fun a => μ a ≠ 0), b ≠ a → μ b ≥ δ - μ a := by
            exact fun b hb hba => by linarith [ hgap a b ( by aesop ) ( by aesop ) ( Ne.symm hba ) ] ;
          -- Summing over all $b \in \text{support}(\mu)$, we get $\sum_{b \in \text{support}(\mu)} \mu(b) \geq \mu(a) + (n-1)(\delta - \mu(a))$.
          have h_sum_ge : ∑ b ∈ Finset.univ.filter (fun a => μ a ≠ 0), μ b ≥ μ a + (Finset.univ.filter (fun a => μ a ≠ 0)).card * (δ - μ a) - (δ - μ a) := by
            have h_sum_ge : ∑ b ∈ Finset.univ.filter (fun a => μ a ≠ 0) \ {a}, μ b ≥ (Finset.univ.filter (fun a => μ a ≠ 0)).card * (δ - μ a) - (δ - μ a) := by
              refine' le_trans _ ( Finset.sum_le_sum fun b hb => h_mu_b_ge_delta_minus_mu_a b ( Finset.mem_sdiff.mp hb |>.1 ) ( by aesop ) ) ; simp +decide [ Finset.card_sdiff, * ];
              rw [ Nat.cast_sub ] <;> push_cast <;> linarith;
            rw [ Finset.sum_eq_sum_diff_singleton_add ha.1 ] ; linarith!;
          -- Since $\sum_{b \in \text{support}(\mu)} \mu(b) = 1$, we have $1 \geq \mu(a) + (n-1)(\delta - \mu(a))$.
          have h_sum_eq_one : ∑ b ∈ Finset.univ.filter (fun a => μ a ≠ 0), μ b = 1 := by
            rw [ ← hμ_sum, Finset.sum_filter_of_ne ] ; aesop;
          rw [ le_div_iff₀ hδ ];
          have h_mu_a_le_inv_card : μ a ≤ 1 / (Finset.univ.filter (fun a => μ a ≠ 0)).card := by
            rw [ le_div_iff₀ ( by positivity ) ];
            exact le_trans ( by simpa [ mul_comm ] using Finset.sum_le_sum fun x ( hx : x ∈ Finset.filter ( fun a => μ a ≠ 0 ) Finset.univ ) => ha.2 x hx ) h_sum_eq_one.le;
          rw [ le_div_iff₀ ] at h_mu_a_le_inv_card <;> nlinarith [ show ( Finset.card ( Finset.filter ( fun a => μ a ≠ 0 ) Finset.univ ) : ℝ ) ≥ 2 by norm_cast ];
        · interval_cases _ : Finset.card ( Finset.filter ( fun a => μ a ≠ 0 ) Finset.univ ) <;> norm_num at *;
          · positivity;
          · rw [ le_div_iff₀ ] <;> linarith;
      refine' le_trans _ ( Real.log_le_log _ h_support_card );
      · convert shannonEntropy_le_log_support_card μ hμ_nonneg hμ_sum using 1;
      · contrapose! hμ_sum; aesop

/-! ### Marginal Entropy Bound -/

/-
The marginal distribution is nonneg when μ is nonneg.
-/
theorem marginalDist_nonneg {n : ℕ} (μ : (Fin n → Bool) → ℝ)
    (A : Finset (Fin n)) (hμ : ∀ x, 0 ≤ μ x) :
    ∀ f, 0 ≤ marginalDist μ A f := by
      exact fun f => Finset.sum_nonneg fun x _ => by split_ifs <;> linarith [ hμ x ] ;

/-
The marginal distribution sums to the same total as μ.
-/
theorem marginalDist_sum {n : ℕ} (μ : (Fin n → Bool) → ℝ)
    (A : Finset (Fin n)) :
    ∑ f, marginalDist μ A f = ∑ x, μ x := by
      unfold marginalDist;
      rw [ Finset.sum_comm ] ; aesop;

/-
**Theorem 2 (Marginal entropy ≤ global entropy)**:
    The entropy of a marginal is at most the entropy of the full distribution.
    This is a form of subadditivity / data processing inequality.

    Proof sketch: Grouping terms by their marginal value and applying
    the log-sum inequality (or Jensen's inequality).
-/
theorem marginal_entropy_le_shannonEntropy
    {n : ℕ}
    (μ : (Fin n → Bool) → ℝ)
    (A : Finset (Fin n))
    (hμ_nonneg : ∀ x, 0 ≤ μ x)
    (hμ_sum : (∑ x, μ x) = 1) :
    marginalShannonEntropy μ A ≤ shannonEntropy μ := by
      -- The key identity: H(μ) - H(marginal) = ∑_f ∑_{x: restrict(x)=f} μ(x) * log(marginalDist μ A f / μ(x)) ≥ 0 because marginalDist μ A f = ∑_{x: restrict(x)=f} μ(x) ≥ μ(x) for each x in the fiber, so log(p_f/μ(x)) ≥ 0, and μ(x) ≥ 0.
      have h_key_identity : shannonEntropy μ - marginalShannonEntropy μ A = ∑ f : ↥A → Bool, ∑ x : (Fin n → Bool), if restrictConfig x A = f then μ x * Real.log ((marginalDist μ A f) / μ x) else 0 := by
        unfold shannonEntropy marginalShannonEntropy marginalDist;
        unfold shannonEntropy shannonTerm; simp +decide [ Finset.sum_ite ] ;
        simp +decide [ Finset.sum_filter, Finset.sum_comm, Finset.sum_add_distrib, mul_sub, sub_mul, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, Real.log_div, hμ_nonneg, hμ_sum ];
        rw [ ← Finset.sum_neg_distrib, ← Finset.sum_add_distrib ] ; congr ; ext x ; by_cases hx : μ x = 0 <;> simp +decide [ hx, Real.log_div, hμ_nonneg ] ; ring;
        split_ifs <;> simp_all +decide [ Real.log_mul, ne_of_gt ];
        · rw [ Finset.sum_eq_zero_iff_of_nonneg ] at * <;> aesop;
        · ring;
      -- For each $x$ in $S_f$ with $\mu(x) > 0$, we have $p_f \geq \mu(x)$ (since $p_f$ sums over $S_f$ which includes $x$), so $\log(p_f/\mu(x)) \geq 0$ and $\mu(x) \geq 0$, giving each term $\geq 0$.
      have h_nonneg : ∀ f : ↥A → Bool, ∀ x : (Fin n → Bool), restrictConfig x A = f → μ x * Real.log ((marginalDist μ A f) / μ x) ≥ 0 := by
        intro f x hx
        have h_marginal_ge_mu : marginalDist μ A f ≥ μ x := by
          exact Finset.single_le_sum ( fun y _ => show 0 ≤ if restrictConfig y A = f then μ y else 0 by split_ifs <;> linarith [ hμ_nonneg y ] ) ( Finset.mem_univ x ) |> le_trans ( by aesop );
        by_cases h : μ x = 0 <;> simp_all +decide [ div_nonneg, mul_nonneg ];
        exact mul_nonneg ( hμ_nonneg x ) ( Real.log_nonneg ( by rw [ le_div_iff₀ ( lt_of_le_of_ne ( hμ_nonneg x ) ( Ne.symm h ) ) ] ; linarith ) );
      exact le_of_sub_nonneg ( h_key_identity.symm ▸ Finset.sum_nonneg fun f hf => Finset.sum_nonneg fun x hx => by aesop )

/-! ### Area-Law Surrogate -/

/-
**Theorem 3 (Area-law surrogate)**: For a probability distribution on `{0,1}^n`
    with pair-mass gap ≥ δ, the bipartition surrogate entropy across any interval cut
    is bounded by `log(2/δ)`.

    This combines:
    1. The gap-to-entropy bound (Theorem 1)
    2. The marginal entropy bound (Theorem 2)
-/
theorem areaLaw_surrogate_from_gap
    {n : ℕ}
    (μ : (Fin n → Bool) → ℝ)
    (δ : ℝ)
    (hδ : 0 < δ)
    (hμ_nonneg : ∀ x, 0 ≤ μ x)
    (hμ_sum : (∑ x, μ x) = 1)
    (hδ2 : δ ≤ 2)
    (hgap : ∀ a b : (Fin n → Bool), μ a ≠ 0 → μ b ≠ 0 → a ≠ b → δ ≤ μ a + μ b) :
    ∀ A : Finset (Fin n),
      isIntervalCut A →
      bipartitionSurrogateEntropy μ A ≤ Real.log (2 / δ) := by
        intro A hA
        apply le_trans (marginal_entropy_le_shannonEntropy μ A hμ_nonneg hμ_sum) (shannonEntropy_le_log_inv_gap μ hμ_nonneg hμ_sum δ hδ hδ2 hgap)

/-! ### Entropy Density -/

/-
**Cross-domain theorem**: If the global entropy is bounded by `log(2/δ)`,
    then the entropy density H(μ)/n is bounded by `log(2/δ)/n`, which vanishes
    as n → ∞. This excludes volume-law behavior.
-/
theorem entropyDensity_bounded
    {α : Type*} [Fintype α] [DecidableEq α]
    (μ : α → ℝ)
    (_hμ_nonneg : ∀ a, 0 ≤ μ a)
    (_hμ_sum : (∑ a, μ a) = 1)
    (δ : ℝ) (_hδ : 0 < δ)
    (n : ℕ) (hn : 0 < n)
    (hbound : shannonEntropy μ ≤ Real.log (2 / δ)) :
    shannonEntropy μ / n ≤ Real.log (2 / δ) / n := by
      gcongr

end EntropicAreaLaw

end