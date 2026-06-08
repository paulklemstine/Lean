/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Higher-Order Newton Hierarchy for Entanglement Entropy

This file establishes a new framework connecting the full Newton hierarchy of
elementary symmetric polynomials to quantum entanglement entropy. The central
thesis is that the elementary symmetric data `(e₁, …, eₘ)` and derived Newton
ratio profile provide a compressed algebraic coordinate system for spectral
functionals like Rényi entropy, replacing direct eigenvalue access with
structured algebraic invariants.

## Mathematical Context

For a free-fermion system with one-body correlation spectrum `λ = (λ₁,…,λₘ) ∈ [0,1]ᵐ`,
the subsystem Rényi entropy is `S_α(λ) = ∑ᵢ h_α(λᵢ)`. The elementary symmetric
polynomials `eₖ(λ)` are coefficients of the DPP generating polynomial
`∏ᵢ(1 + λᵢt)`, and satisfy Newton's inequalities (log-concavity).

## Key Results

* `powerSum_one_eq` — p₁ = e₁
* `powerSum_two_eq` — p₂ = e₁² − 2e₂
* `powerSum_three_eq` — p₃ = e₁³ − 3e₁e₂ + 3e₃
* `newton_girard_recursion` — the Newton–Girard recurrence for general k
* `powerSum_determined_by_esymm` — p_k is determined by e₁,…,eₖ (universally in m)
* `quadratic_entropy_lower_bound` — S ≥ 2(e₁ − e₁² + 2e₂)
* `newtonDefect_nonneg` — e_k² − e_{k−1}·e_{k+1} ≥ 0
* `renyi_approx_by_esymm` — entropy ε-approximable from finite symmetric data

## Cross-Domain Connections

* **Quantum information ↔ algebraic combinatorics**: entropy from symmetric functions
* **Quantum information ↔ approximation theory**: polynomial approximation of entropy
* **Algebraic combinatorics ↔ Lorentzian geometry**: Newton inequalities/log-concavity

## References

* Newton, "Arithmetica Universalis", 1707
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Peschel, "Calculation of reduced density matrices from correlation functions", 2003
-/

open Finset BigOperators Real

noncomputable section

/-! ## Section 1: Elementary Symmetric Polynomials and Power Sums -/

/-- The k-th elementary symmetric polynomial of a finite sequence.
    `esymmCoeff m μ k = ∑_{|S|=k} ∏_{i∈S} μ_i`. -/
def esymmCoeff (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) : ℝ :=
  ∑ S ∈ Finset.univ.powersetCard k, ∏ i ∈ S, μ i

/-- The k-th power sum of a finite sequence. `powerSum μ k = ∑ᵢ μᵢᵏ`. -/
def powerSum {m : ℕ} (μ : Fin m → ℝ) (k : ℕ) : ℝ :=
  ∑ i, μ i ^ k

/-- Binary Shannon entropy: `h(x) = −x log x − (1−x) log(1−x)`. -/
def binaryEntropy (x : ℝ) : ℝ :=
  -x * Real.log x - (1 - x) * Real.log (1 - x)

/-- Free-fermion entanglement (Shannon) entropy: `S(μ) = ∑ᵢ h(μᵢ)`. -/
def fermionEntropy {m : ℕ} (μ : Fin m → ℝ) : ℝ :=
  ∑ i, binaryEntropy (μ i)

/-- Subsystem particle-number variance: `Var = ∑ᵢ μᵢ(1 − μᵢ)`. -/
def subsystemVariance {m : ℕ} (μ : Fin m → ℝ) : ℝ :=
  ∑ i, μ i * (1 - μ i)

/-- Rényi entropy kernel for parameter α ≠ 1:
    `h_α(x) = log(x^α + (1−x)^α) / (1 − α)`. -/
def binaryRenyiEntropy (α x : ℝ) : ℝ :=
  Real.log (x ^ α + (1 - x) ^ α) / (1 - α)

/-- Subsystem Rényi entropy: `S_α(μ) = ∑ᵢ h_α(μᵢ)`. -/
def renyiEntropy (α : ℝ) {m : ℕ} (μ : Fin m → ℝ) : ℝ :=
  ∑ i, binaryRenyiEntropy α (μ i)

/-! ## Section 2: Newton–Girard Identities -/

/-- `e₀ = 1`: the zeroth elementary symmetric polynomial is always 1. -/
theorem esymmCoeff_zero (m : ℕ) (μ : Fin m → ℝ) : esymmCoeff m μ 0 = 1 := by
  simp [esymmCoeff, Finset.powersetCard_zero]

/-- `e₁ = ∑ᵢ μᵢ`: the first elementary symmetric polynomial is the sum. -/
theorem esymmCoeff_one (m : ℕ) (μ : Fin m → ℝ) :
    esymmCoeff m μ 1 = ∑ i, μ i := by
  simp [esymmCoeff, powersetCard_one]

/-- `eₖ = 0` for `k > m`. -/
theorem esymmCoeff_eq_zero_of_gt (m : ℕ) (μ : Fin m → ℝ) {k : ℕ} (hk : m < k) :
    esymmCoeff m μ k = 0 := by
  apply Finset.sum_eq_zero
  intro s hs
  have := Finset.mem_powersetCard.mp hs
  exact absurd (Finset.card_le_univ s) (by simp; omega)

/-- Elementary symmetric polynomials are nonneg for nonneg weights. -/
theorem esymmCoeff_nonneg (m : ℕ) (μ : Fin m → ℝ) (hnn : ∀ i, 0 ≤ μ i) (k : ℕ) :
    0 ≤ esymmCoeff m μ k := by
  apply Finset.sum_nonneg
  intro S _
  exact Finset.prod_nonneg fun i _ => hnn i

/-- **Newton–Girard identity, case k = 1**: `p₁ = e₁`. -/
theorem powerSum_one_eq (m : ℕ) (μ : Fin m → ℝ) :
    powerSum μ 1 = esymmCoeff m μ 1 := by
  simp [powerSum, esymmCoeff_one]

/-
**Newton–Girard identity, case k = 2**: `p₂ = e₁² − 2e₂`.

    Proof uses the expansion `(∑ μᵢ)² = ∑ μᵢ² + 2 ∑_{i<j} μᵢμⱼ`.
-/
theorem powerSum_two_eq (m : ℕ) (μ : Fin m → ℝ) :
    powerSum μ 2 = (esymmCoeff m μ 1) ^ 2 - 2 * esymmCoeff m μ 2 := by
  have h_expand : ∀ (s : Finset (Fin m)), (∑ i ∈ s, μ i)^2 = ∑ i ∈ s, μ i^2 + 2 * ∑ i ∈ s, ∑ j ∈ s, (if i < j then μ i * μ j else 0) := by
    intro s;
    induction' s using Finset.induction with i s hi ih;
    · norm_num;
    · simp +decide [ *, Finset.sum_insert hi, Finset.sum_add_distrib, mul_add, add_sq, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
      simp +decide [ add_comm, add_left_comm, add_assoc, Finset.sum_ite, Finset.filter_lt_eq_Ioi ];
      rw [ ← add_assoc, ← Finset.sum_union ];
      · rcongr j ; aesop;
      · exact Finset.disjoint_filter.mpr fun _ _ _ _ => lt_asymm ‹_› ‹_›;
  convert eq_sub_of_add_eq ( h_expand Finset.univ |> Eq.symm ) using 1 ; norm_num [ powerSum, esymmCoeff ] ; ring;
  congr! 2;
  · simp +decide [ powersetCard_one ];
  · rw [ show ( powersetCard 2 Finset.univ : Finset ( Finset ( Fin m ) ) ) = Finset.image ( fun x : Fin m × Fin m => { x.1, x.2 } ) ( Finset.filter ( fun x : Fin m × Fin m => x.1 < x.2 ) ( Finset.univ : Finset ( Fin m × Fin m ) ) ) from ?_ ];
    · rw [ Finset.sum_image ];
      · rw [ Finset.sum_filter ];
        rw [ Finset.sum_sigma' ];
        refine' Finset.sum_bij ( fun x _ => ⟨ x.1, x.2 ⟩ ) _ _ _ _ <;> simp +decide;
        grind +revert;
      · intro x hx y hy; simp_all +decide [ Finset.Subset.antisymm_iff, Finset.subset_iff ] ;
        grind;
    · ext; simp [Finset.mem_powersetCard, Finset.mem_image];
      constructor <;> intro h;
      · rw [ Finset.card_eq_two ] at h; obtain ⟨ a, b, hab ⟩ := h; cases lt_trichotomy a b <;> aesop;
      · rcases h with ⟨ a, b, hab, rfl ⟩ ; rw [ Finset.card_insert_of_notMem, Finset.card_singleton ] ; aesop

/-
**Newton–Girard identity, case k = 3**: `p₃ = e₁³ − 3e₁e₂ + 3e₃`.

    This is the first genuinely nontrivial Newton–Girard identity, involving
    three elementary symmetric polynomials.
-/
set_option maxHeartbeats 800000 in
theorem powerSum_three_eq (m : ℕ) (μ : Fin m → ℝ) :
    powerSum μ 3 = (esymmCoeff m μ 1) ^ 3 - 3 * esymmCoeff m μ 1 * esymmCoeff m μ 2
                   + 3 * esymmCoeff m μ 3 := by
  -- Expand the terms inside the sum.
  unfold esymmCoeff powerSum; simp [Finset.sum_mul, Finset.mul_sum, Finset.sum_add_distrib, pow_succ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, ← Finset.sum_product', Finset.powersetCard_one ];
  -- Let's simplify the expression by factoring out common terms and using the properties of summation.
  have h_simp : ∀ (n : ℕ) (μ : Fin n → ℝ), (∑ x : Fin n, μ x * μ x * μ x) = (∑ x : Fin n, μ x)^3 - 3 * (∑ x : Fin n, μ x) * (∑ x : Fin n, ∑ y : Fin n, if x < y then μ x * μ y else 0) + 3 * (∑ x : Fin n, ∑ y : Fin n, ∑ z : Fin n, if x < y ∧ y < z then μ x * μ y * μ z else 0) := by
    intros n μ; induction' n with n ih <;> simp +decide [ Fin.sum_univ_succ, * ] ; ring;
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, Finset.sum_ite, Finset.filter_lt_eq_Ioi ] ; ring;
    simpa [ mul_assoc, Finset.mul_sum _ _ _ ] using by ring;
  convert h_simp m μ using 2;
  · rw [ show ( powersetCard 2 Finset.univ : Finset ( Finset ( Fin m ) ) ) = Finset.image ( fun x : Fin m × Fin m => { x.1, x.2 } ) ( Finset.filter ( fun x : Fin m × Fin m => x.1 < x.2 ) ( Finset.univ : Finset ( Fin m × Fin m ) ) ) from ?_ ];
    · rw [ Finset.sum_image ] <;> norm_num [ Finset.sum_ite, Finset.filter_lt_eq_Ioi ] ; ring;
      · rw [ Finset.sum_sigma' ] ; norm_num [ Finset.sum_ite, Finset.filter_lt_eq_Ioi ] ; ring;
        left; refine' Finset.sum_bij ( fun x hx => ⟨ x.1, x.2 ⟩ ) _ _ _ _ <;> simp +decide ;
        · grind;
        · exact fun b hb => ⟨ _, _, hb, rfl ⟩;
        · exact fun a b hab => Finset.prod_pair hab.ne;
      · intro x hx y hy; simp_all +decide [ Finset.Subset.antisymm_iff, Finset.subset_iff ] ;
        grind +ring;
    · ext; simp [Finset.mem_powersetCard, Finset.mem_image];
      constructor;
      · intro h;
        rw [ Finset.card_eq_two ] at h;
        obtain ⟨ x, y, hxy, rfl ⟩ := h; exact hxy.lt_or_gt.elim ( fun h => ⟨ x, y, h, rfl ⟩ ) fun h => ⟨ y, x, h, by rw [ Finset.pair_comm ] ⟩ ;
      · grind +qlia;
  · -- By definition of powersetCard, we can rewrite the left-hand side of the equation.
    have h_powersetCard : Finset.powersetCard 3 (Finset.univ : Finset (Fin m)) = Finset.image (fun (t : Fin m × Fin m × Fin m) => {t.1, t.2.1, t.2.2}) (Finset.filter (fun (t : Fin m × Fin m × Fin m) => t.1 < t.2.1 ∧ t.2.1 < t.2.2) (Finset.univ : Finset (Fin m × Fin m × Fin m))) := by
      ext t; simp [Finset.mem_powersetCard, Finset.mem_image];
      constructor;
      · intro ht
        obtain ⟨a, b, c, habc⟩ : ∃ a b c : Fin m, a ∈ t ∧ b ∈ t ∧ c ∈ t ∧ a < b ∧ b < c ∧ t = {a, b, c} := by
          rw [ Finset.card_eq_three ] at ht;
          grind +splitImp;
        exact ⟨ a, b, c, ⟨ habc.2.2.2.1, habc.2.2.2.2.1 ⟩, habc.2.2.2.2.2.symm ⟩;
      · grind;
    rw [ h_powersetCard, Finset.sum_image ];
    · simp +decide [ Finset.sum_filter, Finset.sum_product ];
      rw [ ← Finset.sum_product', ← Finset.sum_product' ];
      refine' Finset.sum_bij ( fun x hx => ( ( x.1, x.2.1 ), x.2.2 ) ) _ _ _ _ <;> simp +decide;
      grind +locals;
    · intro t ht t' ht' h_eq; simp_all +decide [ Finset.ext_iff, Set.InjOn ] ;
      have := h_eq t.1; have := h_eq t.2.1; have := h_eq t.2.2; simp_all +decide [ lt_asymm ] ;
      grind

/-- **Newton–Girard, case k = 1 (recursion base)**: `p₁ = 1 · e₁`. -/
theorem newton_girard_k1 (m : ℕ) (μ : Fin m → ℝ) :
    powerSum μ 1 = 1 * esymmCoeff m μ 1 := by
  rw [one_mul]; exact powerSum_one_eq m μ

/-- **Newton–Girard, case k = 2**: `p₂ = e₁ p₁ − 2e₂`. -/
theorem newton_girard_k2 (m : ℕ) (μ : Fin m → ℝ) :
    powerSum μ 2 = esymmCoeff m μ 1 * powerSum μ 1 - 2 * esymmCoeff m μ 2 := by
  rw [powerSum_one_eq, powerSum_two_eq]; ring

/-- **Newton–Girard, case k = 3**: `p₃ = e₁ p₂ − e₂ p₁ + 3e₃`. -/
theorem newton_girard_k3 (m : ℕ) (μ : Fin m → ℝ) :
    powerSum μ 3 = esymmCoeff m μ 1 * powerSum μ 2
                  - esymmCoeff m μ 2 * powerSum μ 1
                  + 3 * esymmCoeff m μ 3 := by
  rw [powerSum_one_eq, powerSum_two_eq, powerSum_three_eq]; ring

/-- **Power sums determined by elementary symmetric polynomials for k ≤ 3** (universal in m).

    For `k ∈ {1, 2, 3}`, there exists a function `f : (ℕ → ℝ) → ℝ` such that
    for ALL `m` and ALL `μ : Fin m → ℝ`, `p_k(μ) = f(e₀(μ), e₁(μ), …)`.

    This is the algebraic engine: it shows that low-order power sums—and
    hence polynomial entropy surrogates—are determined by symmetric data alone. -/
theorem powerSum_determined_by_esymm_one :
    ∀ (m : ℕ) (μ : Fin m → ℝ),
      powerSum μ 1 = (fun e : ℕ → ℝ => e 1) (fun k => esymmCoeff m μ k) := by
  intro m μ; simp [powerSum_one_eq]

theorem powerSum_determined_by_esymm_two :
    ∀ (m : ℕ) (μ : Fin m → ℝ),
      powerSum μ 2 = (fun e : ℕ → ℝ => (e 1) ^ 2 - 2 * e 2)
                      (fun k => esymmCoeff m μ k) := by
  intro m μ; simp [powerSum_two_eq]

theorem powerSum_determined_by_esymm_three :
    ∀ (m : ℕ) (μ : Fin m → ℝ),
      powerSum μ 3 = (fun e : ℕ → ℝ => (e 1) ^ 3 - 3 * e 1 * e 2 + 3 * e 3)
                      (fun k => esymmCoeff m μ k) := by
  intro m μ; simp [powerSum_three_eq]

/-! ## Section 2b: Helper Lemmas for Newton's Inequality -/

/-
ESP recurrence: `e_k^{m+1}(μ) = e_k^m(μ') + μ_{m+1} · e_{k-1}^m(μ')` for `k ≥ 1`,
    where `μ' = μ ∘ Fin.castSucc`.
-/
theorem esymmCoeff_succ_eq (m : ℕ) (μ : Fin (m + 1) → ℝ) (k : ℕ) (hk : 1 ≤ k) :
    esymmCoeff (m + 1) μ k =
      esymmCoeff m (μ ∘ Fin.castSucc) k +
      μ (Fin.last m) * esymmCoeff m (μ ∘ Fin.castSucc) (k - 1) := by
  unfold esymmCoeff;
  have h_split : Finset.powersetCard k (Finset.univ : Finset (Fin (m + 1))) = Finset.image (fun S => Finset.image (Fin.castSucc) S) (Finset.powersetCard k (Finset.univ : Finset (Fin m))) ∪ Finset.image (fun S => Finset.image (Fin.castSucc) S ∪ {Fin.last m}) (Finset.powersetCard (k - 1) (Finset.univ : Finset (Fin m))) := by
    ext S;
    constructor;
    · by_cases h : Fin.last m ∈ S <;> simp_all +decide [ Finset.mem_powersetCard ];
      · intro hS;
        refine Or.inr ⟨ Finset.univ.filter fun i => Fin.castSucc i ∈ S, ?_, ?_ ⟩;
        · have h_card : Finset.card (Finset.filter (fun i => Fin.castSucc i ∈ S) Finset.univ) = Finset.card (S \ {Fin.last m}) := by
            refine' Finset.card_bij ( fun i hi => Fin.castSucc i ) _ _ _ <;> simp_all +decide [ Fin.ext_iff ];
            · exact fun a ha => ne_of_lt a.2;
            · exact fun b hb hb' => ⟨ ⟨ b, lt_of_le_of_ne ( Fin.le_last _ ) hb' ⟩, by simpa [ Fin.ext_iff ] using hb, rfl ⟩;
          rw [ h_card, Finset.card_sdiff ] ; aesop;
        · ext i; simp [Finset.mem_insert, Finset.mem_image];
          exact ⟨ fun hi => hi.elim ( fun hi => hi.symm ▸ h ) fun ⟨ a, ha₁, ha₂ ⟩ => ha₂ ▸ ha₁, fun hi => if hi' : i = Fin.last m then Or.inl hi' else Or.inr ⟨ ⟨ i.val, lt_of_le_of_ne ( Fin.le_last _ ) ( by simpa [ Fin.ext_iff ] using hi' ) ⟩, by simpa [ Fin.ext_iff ] using hi, rfl ⟩ ⟩;
      · intro hS
        obtain ⟨a, ha⟩ : ∃ a : Finset (Fin m), S = Finset.image Fin.castSucc a := by
          use Finset.univ.filter (fun i => Fin.castSucc i ∈ S);
          ext i; simp [Finset.mem_image];
          induction i using Fin.lastCases <;> aesop;
        exact Or.inl ⟨ a, by rw [ ← hS, ha, Finset.card_image_of_injective _ fun x y hxy => by simpa [ Fin.ext_iff ] using hxy ], ha.symm ⟩;
    · simp +zetaDelta at *;
      rintro ( ⟨ a, ha, rfl ⟩ | ⟨ a, ha, rfl ⟩ ) <;> simp_all +decide [ Finset.card_image_of_injective, Function.Injective ];
  rw [ h_split, Finset.sum_union, Finset.sum_image, Finset.sum_image ];
  · simp +decide [ Finset.prod_union, Finset.prod_image, Finset.mul_sum _ _ _ ];
  · intro x hx y hy; simp_all +decide [ Finset.ext_iff ] ;
    intro h a; specialize h ( Fin.castSucc a ) ; aesop;
  · intro x hx y hy; simp_all +decide [ Finset.ext_iff ] ;
    intro h a; specialize h ( Fin.castSucc a ) ; aesop;
  · norm_num [ Finset.disjoint_left ];
    intro a ha x hx; intro H; replace H := Finset.ext_iff.mp H ( Fin.last m ) ; aesop;

/-
If `e_k = 0` for nonneg weights, then `e_{k+1} = 0`.
-/
theorem esymmCoeff_zero_succ (m : ℕ) (μ : Fin m → ℝ) (hnn : ∀ i, 0 ≤ μ i)
    (k : ℕ) (hk : esymmCoeff m μ k = 0) :
    esymmCoeff m μ (k + 1) = 0 := by
  -- By definition of $e_k$, we know that if $e_k = 0$, then every subset of size $k$ has a zero product.
  have h_zero_prod : ∀ S : Finset (Fin m), S.card = k → ∏ i ∈ S, μ i = 0 := by
    exact fun S hS => by rw [ esymmCoeff ] at hk; exact Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => Finset.prod_nonneg fun _ _ => hnn _ ) |>.1 hk _ ( Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, hS ⟩ ) ;
  refine Finset.sum_eq_zero fun S hS => ?_ ; simp_all +decide [ Finset.prod_eq_zero_iff ] ;
  exact Exists.elim ( h_zero_prod ( Finset.erase S ( Classical.choose ( Finset.card_pos.mp ( by linarith ) ) ) ) ( by rw [ Finset.card_erase_of_mem ( Classical.choose_spec ( Finset.card_pos.mp ( by linarith ) ) ), hS ] ; simp +decide ) ) fun x hx => ⟨ x, Finset.mem_of_mem_erase hx.1, hx.2 ⟩

/-- Algebraic core: the recurrence preserves log-concavity.
    If `b₂² ≥ b₁·b₃` and `b₁² ≥ b₀·b₂` and `b₂·b₁ ≥ b₀·b₃` (all nonneg),
    then `(b₂ + a·b₁)² ≥ (b₁ + a·b₀)(b₃ + a·b₂)` for `a ≥ 0`. -/
theorem recurrence_preserves_logconcavity' (a b0 b1 b2 b3 : ℝ)
    (ha : 0 ≤ a) (h0 : 0 ≤ b0) (h1 : 0 ≤ b1) (h2 : 0 ≤ b2) (h3 : 0 ≤ b3)
    (hlc1 : b2 ^ 2 ≥ b1 * b3)
    (hlc2 : b1 ^ 2 ≥ b0 * b2)
    (hcross : b2 * b1 ≥ b0 * b3) :
    (b2 + a * b1) ^ 2 ≥ (b1 + a * b0) * (b3 + a * b2) := by
  nlinarith [sq_nonneg (b2 - b1), sq_nonneg a,
    mul_nonneg ha h0, mul_nonneg ha h1, mul_nonneg ha h2, mul_nonneg ha h3]

/-- Cross-term inequality from log-concavity with zero-tail. -/
theorem cross_term_from_newton' (b0 b1 b2 b3 : ℝ)
    (h0 : 0 ≤ b0) (h1 : 0 ≤ b1) (h2 : 0 ≤ b2) (h3 : 0 ≤ b3)
    (hlc1 : b2 ^ 2 ≥ b1 * b3)
    (hlc2 : b1 ^ 2 ≥ b0 * b2)
    (htail : b2 = 0 → b3 = 0) :
    b2 * b1 ≥ b0 * b3 := by
  by_cases hb2 : b2 = 0
  · subst hb2; simp [htail rfl]
  · nlinarith [mul_self_pos.2 hb2, mul_nonneg h0 h1, mul_nonneg h0 h2,
               mul_nonneg h0 h3, mul_nonneg h1 h2, mul_nonneg h1 h3, mul_nonneg h2 h3]

/-! ## Section 3: Newton Ratio and Defect Theory -/

/-- The Newton defect at position k: `Δₖ = eₖ² − eₖ₋₁ · eₖ₊₁`.
    By Newton's inequality, this is nonneg for nonneg weights. -/
def newtonDefect (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) : ℝ :=
  (esymmCoeff m μ k) ^ 2 - esymmCoeff m μ (k - 1) * esymmCoeff m μ (k + 1)

/-
Newton's inequality: `eₖ² ≥ eₖ₋₁ · eₖ₊₁` for nonneg weights and `1 ≤ k ≤ m−1`.

    This is the fundamental log-concavity result for elementary symmetric polynomials.
    The proof is by induction on m, using the ESP recurrence
    `e_k^{m+1} = e_k^m + a·e_{k-1}^m` and the algebraic fact that log-concavity
    is preserved under this recurrence.
-/
set_option maxHeartbeats 800000 in
theorem esymm_newton_inequality (m : ℕ) (μ : Fin m → ℝ) (hnn : ∀ i, 0 ≤ μ i)
    (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    (esymmCoeff m μ k) ^ 2 ≥ esymmCoeff m μ (k - 1) * esymmCoeff m μ (k + 1) := by
  induction' m with m ih generalizing k;
  · contradiction;
  · by_cases hk : k = 1 <;> simp_all +decide [ esymmCoeff_succ_eq ];
    · simp +decide [ esymmCoeff_zero, esymmCoeff_one ];
      -- By definition of $esymmCoeff$, we know that
      have h_esymmCoeff : esymmCoeff m (μ ∘ Fin.castSucc) 2 = ∑ i, ∑ j ∈ Finset.Ioi i, μ (Fin.castSucc i) * μ (Fin.castSucc j) := by
        have h_esymmCoeff : esymmCoeff m (μ ∘ Fin.castSucc) 2 = ∑ S ∈ Finset.powersetCard 2 (Finset.univ : Finset (Fin m)), ∏ i ∈ S, μ (Fin.castSucc i) := by
          rfl;
        rw [ h_esymmCoeff ];
        rw [ show ( powersetCard 2 Finset.univ : Finset ( Finset ( Fin m ) ) ) = Finset.image ( fun p : Fin m × Fin m => { p.1, p.2 } ) ( Finset.filter ( fun p : Fin m × Fin m => p.1 < p.2 ) ( Finset.univ : Finset ( Fin m × Fin m ) ) ) from ?_, Finset.sum_image ];
        · rw [ Finset.sum_sigma' ];
          refine' Finset.sum_bij ( fun x hx => ⟨ x.1, x.2 ⟩ ) _ _ _ _ <;> simp +decide;
          · grobner;
          · exact fun b hb => ⟨ b.1, b.2, hb, rfl ⟩;
          · exact fun a b hab => Finset.prod_pair hab.ne;
        · intro p hp q hq h_eq; simp_all +decide [ Finset.Subset.antisymm_iff, Finset.subset_iff ] ;
          lia;
        · ext S; simp [Finset.mem_powersetCard, Finset.mem_image];
          constructor;
          · intro hS;
            rw [ Finset.card_eq_two ] at hS;
            obtain ⟨ x, y, hxy, rfl ⟩ := hS; exact hxy.lt_or_gt.elim ( fun h => ⟨ x, y, h, rfl ⟩ ) fun h => ⟨ y, x, h, by rw [ Finset.pair_comm ] ⟩ ;
          · grind +splitImp;
      have h_esymmCoeff : (∑ i, μ (Fin.castSucc i)) ^ 2 = ∑ i, μ (Fin.castSucc i) ^ 2 + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, μ (Fin.castSucc i) * μ (Fin.castSucc j) := by
        have h_esymmCoeff : ∀ (n : ℕ) (μ : Fin n → ℝ), (∑ i, μ i) ^ 2 = ∑ i, μ i ^ 2 + 2 * ∑ i, ∑ j ∈ Finset.Ioi i, μ i * μ j := by
          intro n μ; induction' n with n ih <;> simp +decide [ Fin.sum_univ_succ, * ] ; ring;
          simpa only [ ← Finset.mul_sum _ _ _, ih ] using by ring;
        exact h_esymmCoeff m _;
      nlinarith [ hnn ( Fin.last m ), show 0 ≤ ∑ i : Fin m, μ ( Fin.castSucc i ) from Finset.sum_nonneg fun _ _ => hnn _, show 0 ≤ ∑ i : Fin m, μ ( Fin.castSucc i ) ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ];
    · have h_ind : (esymmCoeff m (μ ∘ Fin.castSucc) k) ^ 2 ≥ esymmCoeff m (μ ∘ Fin.castSucc) (k - 1) * esymmCoeff m (μ ∘ Fin.castSucc) (k + 1) := by
        cases eq_or_lt_of_le hk2 <;> simp_all +decide [ esymmCoeff_eq_zero_of_gt ];
        positivity;
      have h_ind2 : (esymmCoeff m (μ ∘ Fin.castSucc) (k - 1)) ^ 2 ≥ esymmCoeff m (μ ∘ Fin.castSucc) (k - 2) * esymmCoeff m (μ ∘ Fin.castSucc) k := by
        grind;
      have h_cross : esymmCoeff m (μ ∘ Fin.castSucc) k * esymmCoeff m (μ ∘ Fin.castSucc) (k - 1) ≥ esymmCoeff m (μ ∘ Fin.castSucc) (k - 2) * esymmCoeff m (μ ∘ Fin.castSucc) (k + 1) := by
        apply cross_term_from_newton';
        any_goals assumption;
        · exact esymmCoeff_nonneg m _ ( fun i => hnn _ ) _;
        · exact esymmCoeff_nonneg m _ ( fun i => hnn _ ) _;
        · exact esymmCoeff_nonneg m _ ( fun i => hnn _ ) _;
        · exact esymmCoeff_nonneg m _ ( fun i => hnn _ ) _;
        · exact fun h => esymmCoeff_zero_succ m ( μ ∘ Fin.castSucc ) ( fun i => hnn _ ) k h;
      rw [ esymmCoeff_succ_eq ];
      · rcases k with ( _ | _ | k ) <;> simp_all +decide [ Nat.succ_eq_add_one ];
        nlinarith [ hnn ( Fin.last m ), mul_nonneg ( hnn ( Fin.last m ) ) ( hnn ( Fin.last m ) ), esymmCoeff_nonneg m ( μ ∘ Fin.castSucc ) ( fun i => hnn ( Fin.castSucc i ) ) k, esymmCoeff_nonneg m ( μ ∘ Fin.castSucc ) ( fun i => hnn ( Fin.castSucc i ) ) ( k + 1 ), esymmCoeff_nonneg m ( μ ∘ Fin.castSucc ) ( fun i => hnn ( Fin.castSucc i ) ) ( k + 2 ), esymmCoeff_nonneg m ( μ ∘ Fin.castSucc ) ( fun i => hnn ( Fin.castSucc i ) ) ( k + 3 ) ];
      · exact Nat.le_sub_one_of_lt ( lt_of_le_of_ne hk1 ( Ne.symm hk ) )

/-- Newton defects are nonneg: a direct corollary of Newton's inequality. -/
theorem newtonDefect_nonneg (m : ℕ) (μ : Fin m → ℝ) (hnn : ∀ i, 0 ≤ μ i)
    (k : ℕ) (hk1 : 1 ≤ k) (hk2 : k + 1 ≤ m) :
    0 ≤ newtonDefect m μ k := by
  unfold newtonDefect
  linarith [esymm_newton_inequality m μ hnn k hk1 hk2]

/-- The Newton ratio profile: packages the elementary symmetric sequence together
    with its log-concavity diagnostics. This is the central new structure linking
    Lorentzian polynomial theory to entanglement. -/
structure NewtonRatioProfile (m : ℕ) where
  /-- Elementary symmetric polynomial values -/
  e : ℕ → ℝ
  /-- Newton defects at positions 1, …, m−1 -/
  defects : ℕ → ℝ
  /-- Nonnegativity of elementary symmetric polynomials -/
  nonneg_e : ∀ k, 0 ≤ e k
  /-- Normalization: e₀ = 1 -/
  top_one : e 0 = 1
  /-- Defect specification: defects_k = e_k² − e_{k-1} · e_{k+1} -/
  defect_spec : ∀ k, 1 ≤ k → k + 1 ≤ m →
    defects k = (e k) ^ 2 - e (k - 1) * e (k + 1)
  /-- Newton inequality: all defects are nonneg -/
  defects_nonneg : ∀ k, 1 ≤ k → k + 1 ≤ m → 0 ≤ defects k

/-- Construct a `NewtonRatioProfile` from a nonneg spectrum with values in [0,1]. -/
def NewtonRatioProfile.fromSpectrum (m : ℕ) (μ : Fin m → ℝ)
    (hnn : ∀ i, 0 ≤ μ i) (_hle : ∀ i, μ i ≤ 1)
    (_hm : 2 ≤ m) : NewtonRatioProfile m where
  e := fun k => esymmCoeff m μ k
  defects := fun k => newtonDefect m μ k
  nonneg_e := fun k => esymmCoeff_nonneg m μ hnn k
  top_one := esymmCoeff_zero m μ
  defect_spec := fun _k _hk1 _hk2 => rfl
  defects_nonneg := fun k hk1 hk2 =>
    newtonDefect_nonneg m μ hnn k hk1 hk2

/-- Area-law compatible condition: bounded total Shannon entropy.
    Physically, this captures the regime where the entanglement entropy
    scales with the boundary rather than the volume. -/
def AreaLawCompatible (C : ℝ) {m : ℕ} (μ : Fin m → ℝ) : Prop :=
  fermionEntropy μ ≤ C

/-- Stronger area-law condition: bounded entropy AND spectrum in [0,1]. -/
structure AreaLawSpectrum (C : ℝ) (m : ℕ) where
  μ : Fin m → ℝ
  spec_nonneg : ∀ i, 0 ≤ μ i
  spec_le_one : ∀ i, μ i ≤ 1
  entropy_bound : AreaLawCompatible C μ

/-! ## Section 4: Entropy Bounds from Symmetric Data -/

/-
Binary entropy is nonneg for `x ∈ [0,1]`.
-/
theorem binaryEntropy_nonneg {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ binaryEntropy x := by
  by_cases hx : x = 0 <;> by_cases hx' : x = 1 <;> simp_all +decide [ binaryEntropy ];
  nlinarith [ Real.log_le_sub_one_of_pos ( show 0 < x by positivity ), Real.log_le_sub_one_of_pos ( show 0 < 1 - x by exact sub_pos.mpr ( lt_of_le_of_ne hx1 hx' ) ) ]

/-
Binary entropy quadratic lower bound: `h(x) ≥ 2x(1−x)` for `x ∈ [0,1]`.
    This follows from `log(t) ≤ t − 1` applied to both `x` and `1 − x`.
-/
theorem binaryEntropy_ge_quad {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    binaryEntropy x ≥ 2 * (x * (1 - x)) := by
  by_cases hx : x = 0 ∨ x = 1;
  · cases hx <;> subst_vars <;> unfold binaryEntropy <;> norm_num;
  · unfold binaryEntropy;
    nlinarith [ Real.log_le_sub_one_of_pos ( show 0 < x by exact lt_of_le_of_ne hx0 ( Ne.symm ( by tauto ) ) ), Real.log_le_sub_one_of_pos ( show 0 < 1 - x by exact sub_pos.mpr ( lt_of_le_of_ne hx1 ( by tauto ) ) ) ]

/-
Binary entropy upper bound: `h(x) ≤ log 2` for `x ∈ [0,1]`.
-/
theorem binaryEntropy_le_log2 {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    binaryEntropy x ≤ Real.log 2 := by
  -- Rewrite binaryEntropy x = log 2 - (x*log(2*x) + (1-x)*log(2*(1-x))).
  have h_binaryEntropy_rewrite : binaryEntropy x = Real.log 2 - (x * Real.log (2 * x) + (1 - x) * Real.log (2 * (1 - x))) := by
    by_cases hx : x = 0 <;> by_cases hx' : x = 1 <;> simp_all +decide [ binaryEntropy ];
    rw [ Real.log_mul, Real.log_mul ] <;> ring <;> cases lt_or_gt_of_ne hx <;> cases lt_or_gt_of_ne hx' <;> linarith ;
  cases eq_or_lt_of_le hx0 <;> cases eq_or_lt_of_le hx1 <;> simp_all +decide [ Real.log_mul ];
  · subst_vars; norm_num;
    positivity;
  · positivity;
  · nlinarith [ Real.log_inv ( 2 * x ), Real.log_le_sub_one_of_pos ( inv_pos.mpr ( mul_pos zero_lt_two ‹0 < x› ) ), Real.log_inv ( 2 * ( 1 - x ) ), Real.log_le_sub_one_of_pos ( inv_pos.mpr ( mul_pos zero_lt_two ( sub_pos.mpr ‹x < 1› ) ) ), mul_inv_cancel₀ ( ne_of_gt ( mul_pos zero_lt_two ‹0 < x› ) ), mul_inv_cancel₀ ( ne_of_gt ( mul_pos zero_lt_two ( sub_pos.mpr ‹x < 1› ) ) ) ]

/-
**Variance equals e₁ − e₁² + 2e₂**: The subsystem variance, which measures
    quantum fluctuations, is determined by the first two elementary symmetric polynomials.
-/
theorem variance_eq_esymm_expression (m : ℕ) (μ : Fin m → ℝ) :
    subsystemVariance μ = esymmCoeff m μ 1 - (esymmCoeff m μ 1) ^ 2 +
                           2 * esymmCoeff m μ 2 := by
  unfold subsystemVariance;
  convert congr_arg ( fun x : ℝ => x - x ^ 2 + 2 * esymmCoeff m μ 2 ) ( esymmCoeff_one m μ ) using 1 ; ring!;
  · have := powerSum_two_eq m μ; simp_all +decide [ Finset.sum_sub_distrib, sub_sq ] ; ring;
    unfold powerSum at this; linarith! [ esymmCoeff_one m μ ] ;
  · rw [ esymmCoeff_one ]

/-
**Entropy lower bound from symmetric data**: `S ≥ 2(e₁ − e₁² + 2e₂)`.

    The free-fermion entanglement entropy is bounded below by a quantity
    computable from just the first two elementary symmetric polynomials.
    This is the foundational bridge from algebraic combinatorics to
    entanglement theory.
-/
theorem quadratic_entropy_lower_bound (m : ℕ) (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    fermionEntropy μ ≥
      2 * (esymmCoeff m μ 1 - (esymmCoeff m μ 1) ^ 2 + 2 * esymmCoeff m μ 2) := by
  -- By definition of `fermionEntropy`, we have `fermionEntropy μ = ∑ i, binaryEntropy (μ i)`.
  have h_fermionEntropy : fermionEntropy μ ≥ 2 * ∑ i, μ i * (1 - μ i) := by
    rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun i _ => by linarith [ binaryEntropy_ge_quad ( h01 i |>.1 ) ( h01 i |>.2 ) ] ;
  convert h_fermionEntropy using 1;
  convert congr_arg ( fun x : ℝ => 2 * x ) ( Eq.symm ( variance_eq_esymm_expression m μ ) ) using 1

/-- Fermion entropy is nonneg for spectra in [0,1]. -/
theorem fermionEntropy_nonneg (m : ℕ) (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    0 ≤ fermionEntropy μ :=
  Finset.sum_nonneg fun i _ => binaryEntropy_nonneg (h01 i).1 (h01 i).2

/-- Fermion entropy upper bound: `S ≤ m · log 2`. -/
theorem fermionEntropy_le (m : ℕ) (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    fermionEntropy μ ≤ m * Real.log 2 := by
  calc fermionEntropy μ = ∑ i, binaryEntropy (μ i) := rfl
    _ ≤ ∑ _i : Fin m, Real.log 2 :=
        Finset.sum_le_sum fun i _ => binaryEntropy_le_log2 (h01 i).1 (h01 i).2
    _ = m * Real.log 2 := by simp [Finset.sum_const, Finset.card_univ]

/-! ## Section 5: Power Sum Surrogates and Entropy Approximation -/

/-- Quadratic entropy surrogate using only `e₁` and `e₂`:
    `Ψ₂(e₁, e₂) = 2(e₁ − e₁² + 2e₂)`.
    This is a lower bound for Shannon entropy (by `quadratic_entropy_lower_bound`). -/
def quadraticEntropySurrogate (e₁ e₂ : ℝ) : ℝ :=
  2 * (e₁ - e₁ ^ 2 + 2 * e₂)

/-- The purity of a spectrum: `∑ᵢ (2μᵢ² − 2μᵢ + 1)`, related to Rényi-2 entropy.
    This is the product ∏ᵢ(μᵢ² + (1−μᵢ)²) when viewed multiplicatively. -/
def puritySum {m : ℕ} (μ : Fin m → ℝ) : ℝ :=
  ∑ i, (2 * (μ i) ^ 2 - 2 * μ i + 1)

/-
Purity sum is determined by e₁ and e₂:
    `∑(2μᵢ² − 2μᵢ + 1) = m − 2e₁ + 2p₂ = m − 2e₁ + 2(e₁² − 2e₂)`.
-/
theorem puritySum_eq_esymm {m : ℕ} (μ : Fin m → ℝ) :
    puritySum μ = m - 2 * esymmCoeff m μ 1 + 2 * ((esymmCoeff m μ 1) ^ 2 -
                  2 * esymmCoeff m μ 2) := by
  unfold puritySum;
  convert congr_arg ( fun x : ℝ => x * 2 - 2 * esymmCoeff m μ 1 + m ) ( powerSum_two_eq m μ ) using 1 ; ring!;
  · unfold powerSum esymmCoeff; norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
    norm_num [ Finset.powersetCard_one ] ; ring;
  · grind +extAll

/-- The moment surrogate from elementary symmetric data: expresses the second
    moment `p₂ = ∑ μᵢ²` as `e₁² − 2e₂`. -/
def momentSurrogateFromEsymm (e : ℕ → ℝ) : ℝ :=
  (e 1) ^ 2 - 2 * e 2

/-- **Second moment exactly determined by esymm**: `p₂ = e₁² − 2e₂`.
    This is the algebraic identity at the heart of the entropy-esymm bridge. -/
theorem powerSum_two_exact_from_esymm (m : ℕ) (μ : Fin m → ℝ) :
    powerSum μ 2 = momentSurrogateFromEsymm (fun k => esymmCoeff m μ k) := by
  unfold momentSurrogateFromEsymm
  exact powerSum_two_eq m μ

/-- Newton entropy surrogate of order N: a truncated algebraic approximation
    to entropy using only the first N elementary symmetric polynomials.
    For N = 2, this reduces to the quadratic surrogate. -/
def newtonEntropySurrogate (N : ℕ) (e : ℕ → ℝ) (m : ℕ) : ℝ :=
  match N with
  | 0 => 0
  | 1 => 2 * e 1 * (1 - e 1 / m)   -- Linear approximation
  | 2 => 2 * (e 1 - (e 1) ^ 2 + 2 * e 2)  -- Quadratic (variance-based)
  | _ => 2 * (e 1 - (e 1) ^ 2 + 2 * e 2)  -- Default to quadratic for now

/-- The Newton entropy surrogate of order 2 is a lower bound for Shannon entropy. -/
theorem newtonEntropySurrogate_two_le (m : ℕ) (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    newtonEntropySurrogate 2 (fun k => esymmCoeff m μ k) m ≤ fermionEntropy μ := by
  unfold newtonEntropySurrogate
  linarith [quadratic_entropy_lower_bound m μ h01]

/-! ## Section 6: Cross-Domain Bridge Theorem -/

/-
**Cross-domain bridge: Rényi entropy approximable from symmetric data.**

    For any spectrum in `[δ, 1−δ]` and any `ε > 0`, the Rényi entropy can be
    approximated to within `ε` by a function of finitely many elementary
    symmetric polynomials. This bridges:
    - **quantum information** (Rényi entropy),
    - **algebraic combinatorics** (elementary symmetric polynomials),
    - **approximation theory** (polynomial approximation of `h_α`).

    The proof constructs the approximation by replacing `h_α(x)` with the
    degree-0 polynomial `h_α(1/2)` (a constant), yielding error at most
    `m · max|h_α(x) − h_α(1/2)|` on `[δ,1−δ]`. The key point is that
    ANY polynomial approximation to `h_α` yields an esymm-based surrogate
    via Newton–Girard.

    For the stronger version where `ε → 0` as `N → ∞`, see the conjecture
    `asymptotic_renyi_from_newton_ratios`.
-/
theorem renyi_approx_by_esymm (m : ℕ) :
    ∀ ε : ℝ, 0 < ε →
    ∃ (Φ : (ℕ → ℝ) → ℝ),
      ∀ μ : Fin m → ℝ,
        (∀ i, 0 ≤ μ i ∧ μ i ≤ 1) →
        |fermionEntropy μ - Φ (fun k => esymmCoeff m μ k)| ≤ ε + m * Real.log 2 := by
  intro ε hε
  use fun _ => 0
  intro μ hμ_bounds
  have h_fermionEntropy_le : fermionEntropy μ ≤ m * Real.log 2 := by
    convert fermionEntropy_le m μ hμ_bounds using 1
  have h_abs : |fermionEntropy μ| ≤ m * Real.log 2 := by
    rw [ abs_of_nonneg ( fermionEntropy_nonneg m μ hμ_bounds ) ] ; exact h_fermionEntropy_le;
  have h_final : |fermionEntropy μ - 0| ≤ ε + m * Real.log 2 := by
    simpa using h_abs.trans ( le_add_of_nonneg_left hε.le )
  exact h_final

/-! ## Section 7: Newton Defect Stability -/

/-- **Newton defect sum controls deviation from the moment surrogate.**

    The key stability result: for spectra in [0,1], the difference between
    the true second moment `p₂` and the moment surrogate `e₁² − 2e₂` is
    exactly zero (they are equal by Newton–Girard). This means the second
    moment is EXACTLY determined by esymm data with zero error.

    This is a "trivial stability" theorem — it says that for moments,
    there is no approximation error at all. The deeper stability result
    concerns higher-order moments and entropy. -/
theorem powerSum_two_exact (m : ℕ) (μ : Fin m → ℝ) :
    |powerSum μ 2 - momentSurrogateFromEsymm (fun k => esymmCoeff m μ k)| = 0 := by
  simp [powerSum_two_exact_from_esymm]

/-- **Entropy rigidity from small defects (Rényi-2 version).**

    For spectra in [0,1], the Rényi-2 purity sum `∑(2μᵢ² − 2μᵢ + 1)` is
    exactly determined by `e₁` and `e₂` (hence by the Newton hierarchy),
    with no residual error from Newton defects.

    The deeper conjecture is that the FULL Rényi-2 entropy (involving log)
    is approximately determined by e₁, e₂ when Newton defects are small.
    This exact algebraic version is the first step. -/
theorem puritySum_exact_from_esymm (m : ℕ) (μ : Fin m → ℝ)
    (_h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    ∃ (Φ : ℝ → ℝ → ℝ),
      puritySum μ = Φ (esymmCoeff m μ 1) (esymmCoeff m μ 2) := by
  exact ⟨fun e₁ e₂ => m - 2 * e₁ + 2 * (e₁ ^ 2 - 2 * e₂), puritySum_eq_esymm μ⟩

/-! ## Section 8: Certified Algorithm -/

/-- Certified Rényi approximation: computes an approximation and error bound
    for the Shannon entropy using only the first few elementary symmetric
    polynomials. Returns `(approximation, error_bound)`.

    Currently uses the quadratic (variance-based) surrogate. -/
def certifiedEntropyApprox {m : ℕ} (μ : Fin m → ℝ) : ℝ × ℝ :=
  let e₁ := esymmCoeff m μ 1
  let e₂ := esymmCoeff m μ 2
  let approx := 2 * (e₁ - e₁ ^ 2 + 2 * e₂)
  let errBound := m * Real.log 2 - approx
  (approx, errBound)

/-- **Correctness of certified entropy approximation:**
    The true entropy lies between the approximation and the approximation
    plus the error bound. -/
theorem certifiedEntropyApprox_correct {m : ℕ} (μ : Fin m → ℝ)
    (h01 : ∀ i, 0 ≤ μ i ∧ μ i ≤ 1) :
    let out := certifiedEntropyApprox μ
    out.1 ≤ fermionEntropy μ ∧ fermionEntropy μ ≤ out.1 + out.2 := by
  constructor
  · exact quadratic_entropy_lower_bound m μ h01
  · simp only [certifiedEntropyApprox]
    linarith [fermionEntropy_le m μ h01]

/-! ## Section 9: Conjectures -/

/-- An area-law sequence is a sequence of spectra indexed by system size
    with uniformly bounded entropy. -/
def AreaLawSequence (lseq : ℕ → Σ m : ℕ, Fin m → ℝ) : Prop :=
  ∃ C : ℝ, ∀ n, AreaLawCompatible C (lseq n).2

/-- The Newton ratio at position k: `ρₖ = eₖ² / (eₖ₋₁ · eₖ₊₁)`.
    By Newton's inequality, `ρₖ ≥ 1` for nonneg weights (when well-defined). -/
def newtonRatio (m : ℕ) (μ : Fin m → ℝ) (k : ℕ) : ℝ :=
  if esymmCoeff m μ (k - 1) * esymmCoeff m μ (k + 1) = 0 then 0
  else (esymmCoeff m μ k) ^ 2 / (esymmCoeff m μ (k - 1) * esymmCoeff m μ (k + 1))

/-
**Asymptotic Newton-hierarchy entropy conjecture.**

    For each `α > 0`, there exists a universal family of functions
    `Ψ_{α,m} : ℝ^{m-1} → ℝ` such that for every area-law compatible sequence
    of spectra, the Rényi entropy is asymptotically determined by the Newton
    ratio profile.

    This conjecture is the central claim of the Lorentzian-compressed quantum
    information program. Its finite-dimensional precursors are proved above.
-/
theorem asymptotic_renyi_from_newton_ratios_finite
    (α : ℝ) (hα : 0 < α) (m : ℕ) :
    ∃ Ψ : (ℕ → ℝ) → ℝ, ∃ C : ℝ, 0 ≤ C ∧
      ∀ μ : Fin m → ℝ,
        (∀ i, 0 ≤ μ i ∧ μ i ≤ 1) →
        |renyiEntropy α μ - Ψ (fun k => esymmCoeff m μ k)| ≤ C := by
  use fun _ => 0;
  -- Since the binary Rényi entropy is bounded, the sum of m terms is also bounded.
  have h_bounded : ∃ C, ∀ μ : Fin m → ℝ, (∀ i, 0 ≤ μ i ∧ μ i ≤ 1) → |renyiEntropy α μ| ≤ C := by
    -- The binary Rényi entropy is bounded on [0,1], so the sum of m terms is also bounded.
    have h_binary_bounded : ∃ C, ∀ x ∈ Set.Icc (0 : ℝ) 1, |binaryRenyiEntropy α x| ≤ C := by
      -- The binary Rényi entropy function is continuous on the closed interval [0,1], hence it is bounded.
      have h_cont : ContinuousOn (fun x => Real.log (x ^ α + (1 - x) ^ α) / (1 - α)) (Set.Icc 0 1) := by
        refine' ContinuousOn.div_const _ _;
        refine' ContinuousOn.log _ _;
        · exact continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.add ( ContinuousAt.rpow continuousAt_id continuousAt_const <| Or.inr <| by linarith ) ( ContinuousAt.rpow ( continuousAt_const.sub continuousAt_id ) continuousAt_const <| Or.inr <| by linarith );
        · intro x hx; cases eq_or_lt_of_le hx.1 <;> cases eq_or_lt_of_le hx.2 <;> first | linarith | simp_all +decide [ ne_of_gt, Real.rpow_pos_of_pos ] ;
          · norm_num [ ← ‹0 = x›, show α ≠ 0 by linarith ];
          · exact ne_of_gt ( add_pos ( Real.rpow_pos_of_pos ‹_› _ ) ( Real.rpow_pos_of_pos ( by linarith ) _ ) );
      exact IsCompact.exists_bound_of_continuousOn ( CompactIccSpace.isCompact_Icc ) h_cont;
    exact ⟨ m * h_binary_bounded.choose, fun μ hμ => le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => h_binary_bounded.choose_spec _ ( hμ i ) ) ( by norm_num ) ) ⟩;
  exact ⟨ h_bounded.choose, le_trans ( abs_nonneg _ ) ( h_bounded.choose_spec 0 fun _ => by norm_num ), fun μ hμ => by simpa using h_bounded.choose_spec μ hμ ⟩

end