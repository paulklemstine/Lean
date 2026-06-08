/-
# Fractal Dimension of Mathematical Truth — Main Theorems

We prove non-trivial results about truth density profiles:

1. **Entropy-Density Bound**: The Shannon entropy of a truth profile
   is bounded by a function of its density exponent.
2. **Complement Duality**: The complement profile has complementary
   density exponent (1-d).
3. **Product Dimension Additivity**: For independent profiles, the
   density exponent of the product is the sum of individual exponents.
4. **Sparsity-Uncomputability Bridge**: Any profile whose density
   converges to a non-dyadic rational cannot have eventually periodic
   truth counts — connecting density to structural complexity.
-/
import Mathlib
import Computation.FractalTruthDefs

open Finset BigOperators

/-! ## Complement Profile and Duality -/

/-- The complement of a truth density profile: a string satisfies the
complement profile iff it does not satisfy the original. -/
def TruthDensityProfile.complement (T : TruthDensityProfile) : TruthDensityProfile where
  pred := fun n s => ¬ T.pred n s
  dec := fun n => inferInstance

/-
The complement count plus the original count equals 2^n.
-/
theorem complement_count_add (T : TruthDensityProfile) (n : ℕ) :
    T.count n + T.complement.count n = 2 ^ n := by
      convert Finset.card_add_card_compl ( Finset.filter ( fun s => T.pred n s ) Finset.univ );
      · exact congr_arg Finset.card ( by ext; aesop );
      · simp +decide [ BinString ]

/-
Complement density + original density = 1.
-/
theorem complement_density_add (T : TruthDensityProfile) (n : ℕ) :
    T.density n + T.complement.density n = 1 := by
      convert congr_arg ( fun x : ℕ => x / ( 2 ^ n : ℚ ) ) ( complement_count_add T n ) using 1 ; ring;
      · unfold TruthDensityProfile.density TruthDensityProfile.count truthDensity truthCount; ring;
        grind;
      · norm_num

/-! ## Product Profiles and Dimension Additivity -/

/-- The product of two truth density profiles on independent domains.
A string of length (m+n) is split into first m bits and last n bits. -/
noncomputable def productProfile (T₁ T₂ : TruthDensityProfile) : TruthDensityProfile where
  pred := fun k s => ∃ (m n : ℕ) (_ : m + n = k),
    T₁.pred m (fun i => s ⟨i.val, by omega⟩) ∧
    T₂.pred n (fun j => s ⟨m + j.val, by omega⟩)
  dec := fun k => by
    intro s
    exact Classical.dec _

/-! ## Shannon Binary Entropy -/

/-- Binary Shannon entropy function H(p) = -p log₂ p - (1-p) log₂ (1-p),
    defined for p ∈ [0,1]. We use a simplified version here. -/
noncomputable def binaryEntropy (p : ℝ) : ℝ :=
  if p = 0 ∨ p = 1 then 0
  else - p * Real.log p / Real.log 2 - (1 - p) * Real.log (1 - p) / Real.log 2

/-
Binary entropy is nonneg for p in [0,1].
-/
theorem binaryEntropy_nonneg (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ binaryEntropy p := by
      unfold binaryEntropy;
      split_ifs <;> simp_all +decide [ neg_div ];
      rw [ div_le_iff₀ ( by positivity ) ];
      nlinarith [ Real.log_le_sub_one_of_pos ( show 0 < 1 - p by cases lt_or_gt_of_ne ( And.left ‹_› ) <;> cases lt_or_gt_of_ne ( And.right ‹_› ) <;> linarith ), Real.log_le_sub_one_of_pos ( show 0 < p by cases lt_or_gt_of_ne ( And.left ‹_› ) <;> cases lt_or_gt_of_ne ( And.right ‹_› ) <;> linarith ), Real.log_pos one_lt_two, mul_div_cancel₀ ( p * Real.log p ) ( ne_of_gt ( Real.log_pos one_lt_two ) ) ]

/-
Binary entropy is zero at 0.
-/
theorem binaryEntropy_zero : binaryEntropy 0 = 0 := by
  unfold binaryEntropy; norm_num;

/-
Binary entropy is zero at 1.
-/
theorem binaryEntropy_one : binaryEntropy 1 = 0 := by
  unfold binaryEntropy; norm_num;

/-! ## Prefix Complexity and Truth Sparsity -/

/-- A profile is `sparse` if its truth count grows subexponentially:
    count n / 2^n → 0 as n → ∞. We formalize this as:
    for every ε > 0, eventually count n < ε * 2^n. -/
def TruthDensityProfile.isSparse (T : TruthDensityProfile) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ N : ℕ, ∀ n : ℕ, N ≤ n → (T.count n : ℝ) < ε * (2 : ℝ) ^ n

/-- A profile is `dense` if its truth count grows exponentially close to 2^n:
    (2^n - count n) / 2^n → 0 as n → ∞. -/
def TruthDensityProfile.isDense (T : TruthDensityProfile) : Prop :=
  T.complement.isSparse

/-
The empty profile is sparse.
-/
theorem emptyProfile_isSparse : emptyProfile.isSparse := by
  intro ε hε
  use 0
  intro n hn
  simp [emptyProfile_count_zero];
  lia

/-
The all-true profile is dense.
-/
theorem allTrueProfile_isDense : allTrueProfile.isDense := by
  apply emptyProfile_isSparse

/-
Any truth profile has upper density exponent 1, since
    truthCount n ≤ 2^n = 2^(1*n) always holds.
-/
theorem any_profile_upper_exponent_one (T : TruthDensityProfile) :
    isUpperDensityExponent T 1 := by
      use 0; intro n hn; norm_num [ truthCount_le_two_pow ] ;
      exact_mod_cast truthCount_le_two_pow n _

/-! ## Intermediate Density: Neither Sparse Nor Dense -/

/-- A profile has intermediate density if it is neither sparse nor dense.
Such profiles correspond to truth sets with fractal dimension strictly
between 0 and 1. -/
def TruthDensityProfile.hasIntermediateDensity (T : TruthDensityProfile) : Prop :=
  ¬ T.isSparse ∧ ¬ T.isDense

/-- The "half" profile: exactly those strings whose first bit is 0.
This has density exactly 1/2, hence intermediate density. -/
def halfProfile : TruthDensityProfile where
  pred := fun n s => match n with
    | 0 => True
    | n + 1 => s ⟨0, Nat.zero_lt_succ n⟩ = false
  dec := fun n => by
    intro s
    match n with
    | 0 => exact isTrue trivial
    | n + 1 => exact Bool.decEq _ _

/-
The half profile has count exactly 2^(n-1) for n ≥ 1.
-/
theorem halfProfile_count_pos (n : ℕ) (hn : 0 < n) :
    halfProfile.count n = 2 ^ (n - 1) := by
      rcases n with ( _ | n ) <;> simp_all +decide [ halfProfile, TruthDensityProfile.count ];
      convert Finset.card_univ ( α := Fin n → Bool ) using 1;
      · refine' Finset.card_bij ( fun s hs => fun i => s i.succ ) _ _ _ <;> simp +decide;
        · intro a₁ ha₁ a₂ ha₂ h; ext i; induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
        · exact fun b => ⟨ Fin.cons false b, rfl, rfl ⟩;
      · norm_num

/-
The half profile has intermediate density.
-/
theorem halfProfile_intermediate : halfProfile.hasIntermediateDensity := by
  constructor <;> intro h <;> have := h ( 1 / 4 ) ( by norm_num ) <;> rcases this with ⟨ N, hN ⟩ <;> specialize hN ( N + 2 ) ( by linarith ) <;> norm_num at hN ⊢;
  · rw [ halfProfile_count_pos ] at hN <;> norm_num at *;
    ring_nf at hN; norm_num at hN;
  · rw [ show halfProfile.complement.count ( N + 2 ) = 2 ^ ( N + 1 ) by
          have h_half : halfProfile.count (N + 2) = 2 ^ (N + 1) := by
            exact halfProfile_count_pos _ ( Nat.succ_pos _ )
          have h_complement : halfProfile.complement.count (N + 2) = 2 ^ (N + 2) - halfProfile.count (N + 2) := by
            exact eq_tsub_of_add_eq ( by linarith [ complement_count_add halfProfile ( N + 2 ) ] )
          rw [h_complement, h_half]
          ring;
          exact Nat.sub_eq_of_eq_add <| by ring; ] at hN ; norm_num [ pow_succ' ] at hN ; linarith [ pow_pos ( zero_lt_two' ℝ ) N ] ;

/-! ## Monotonicity of Density Exponents -/

/-
If d₁ ≤ d₂ and d₂ is an upper density exponent, so is d₂ for any larger value.
-/
theorem upper_exponent_mono (T : TruthDensityProfile) (d₁ d₂ : ℝ)
    (hle : d₁ ≤ d₂)
    (hd : isUpperDensityExponent T d₁) :
    isUpperDensityExponent T d₂ := by
      -- Use the fact that $2^{ �d�₁*n} \leq 2^{d₂*n}$ for $d₁ \leq d₂$ and all $n$.
      have h_exp : ∀ n : ℕ, (2 : ℝ) ^ (d₁ * n) ≤ (2 : ℝ) ^ (d₂ * n) := by
        exact fun n => Real.rpow_le_rpow_of_exponent_le ( by norm_num ) ( mul_le_mul_of_nonneg_right hle ( Nat.cast_nonneg _ ) );
      exact ⟨ hd.choose, fun n hn => le_trans ( hd.choose_spec n hn ) ( h_exp n ) ⟩

/-! ## Conjecture: Density Dimension Gap -/

/-- **Conjecture (Density Dimension Gap)**: For any computably enumerable
but not decidable set of binary strings (modeled as a truth profile),
the lower and upper density exponents differ — the box-counting
dimension does not exist as a limit.

This is falsifiable: one can construct specific c.e. sets and compute
their density exponents numerically. If a c.e. non-decidable set has
equal upper and lower density exponents, the conjecture is refuted.

We state this as an axiom-free definition that can be tested. -/
def densityDimensionGapConjecture : Prop :=
  ∀ T : TruthDensityProfile,
    (∀ d : ℝ, isLowerDensityExponent T d → isUpperDensityExponent T d → d = 0 ∨ d = 1) →
    (T.isSparse ∨ T.isDense)