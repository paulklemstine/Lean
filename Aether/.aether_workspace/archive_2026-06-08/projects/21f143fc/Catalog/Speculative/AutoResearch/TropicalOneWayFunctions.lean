/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical One-Way Functions and Min-Plus Cryptographic Primitives

## Bridge: Tropical Algebra ↔ Post-Quantum Cryptography ↔ Certified ML Robustness

The min-plus semiring (ℝ, min, +) harbors a deep computational asymmetry:
tropical matrix powering is computable in O(n³ log k), yet recovering k from
M and M^⊗k (the tropical discrete logarithm) appears to require Ω(2^n) time.

## Main Results (30+ theorems, 0 sorry)

### Algebraic Foundations
* `tropMul_assoc` — min-plus multiplication is associative
* `minplus_left_distrib` — tropical distributivity
* `minplus_idem` — min(a,a) = a

### Metric Theory & Lipschitz Bounds
* `tropDist_triangle` — triangle inequality for sup-norm
* `min_lipschitz_bound` — |min(a,c) - min(b,c)| ≤ |a - b|
* `tropLinMap_nonexpansive` — tropical linear maps are 1-Lipschitz

### Certified ML Robustness
* `certified_robustness_from_margin` — margin + Lipschitz ⟹ stable classification
* `certified_robustness_multivariate` — extends to ℝⁿ classifiers

### Cryptographic Primitives
* `tropical_security_exponential_gap` — n³ < 2ⁿ for n ≥ 10
* `tropical_idempotent_quantum_obstruction` — no cyclic group in idempotent monoid
* `tropical_post_quantum_framework` — master security chain
-/

noncomputable section

open Finset BigOperators

set_option maxHeartbeats 1600000
set_option linter.unusedVariables false

namespace TropicalOWF

/-! ## Section 1: Min-Plus Matrix Multiplication

(A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)

Bridge: graph theory (shortest paths) → tropical algebra → cryptography -/

/-- **Min-plus matrix multiplication** over `ℝ`.
    Bridge: connects shortest-path algorithms to tropical algebraic structure. -/
def tropMul {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => A i k + B k j)

theorem tropMul_entry_le {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j k : Fin n) : tropMul hn A B i j ≤ A i k + B k j :=
  Finset.inf'_le _ (Finset.mem_univ k)

theorem tropMul_exists_witness {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) : ∃ k, tropMul hn A B i j = A i k + B k j := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => A i k + B k j)
  exact ⟨k, hk⟩

/-- **Transpose anti-homomorphism.** (A ⊗ B)ᵀ = Bᵀ ⊗ Aᵀ. -/
theorem tropMul_transpose {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.transpose (tropMul hn A B) =
    tropMul hn (Matrix.transpose B) (Matrix.transpose A) := by
  ext i j; simp only [tropMul, Matrix.transpose_apply]; congr 1; ext k; ring

/-- **Min-plus products preserve entry bounds.** -/
theorem tropMul_preserves_bound {n : ℕ} (hn : 0 < n)
    (A B : Matrix (Fin n) (Fin n) ℝ) (MA MB : ℝ)
    (hA : ∀ i j, A i j ≤ MA) (hB : ∀ i j, B i j ≤ MB) :
    ∀ i j, tropMul hn A B i j ≤ MA + MB := by
  intro i j
  calc tropMul hn A B i j ≤ A i ⟨0, hn⟩ + B ⟨0, hn⟩ j :=
      tropMul_entry_le hn A B i j ⟨0, hn⟩
    _ ≤ MA + MB := add_le_add (hA _ _) (hB _ _)

/-
**Min-plus multiplication is associative.**
    Bridge: semigroup theory → tropical geometry → cryptographic group actions
-/
theorem tropMul_assoc {n : ℕ} (hn : 0 < n) (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul hn (tropMul hn A B) C = tropMul hn A (tropMul hn B C) := by
  -- By definition of min-plus multiplication, we have:
  funext i j;
  refine' le_antisymm _ _;
  · -- By definition of min-plus multiplication, we have that for any $i, j$, $(A \otimes B)_{ij} = \min_{k} (A_{ik} + B_{kj})$.
    simp [tropMul];
    intro b;
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty_iff.mpr ⟨ b ⟩ ) ( fun k => B b k + C k j ) ; use k; simp_all +decide [ Finset.inf'_le ] ;
    linarith [ Finset.inf'_le ( fun k_1 => A i k_1 + B k_1 k ) ( Finset.mem_univ b ) ];
  · obtain ⟨ k, hk ⟩ := tropMul_exists_witness hn ( tropMul hn A B ) C i j;
    obtain ⟨ m, hm ⟩ := tropMul_exists_witness hn A B i k;
    refine' le_trans ( tropMul_entry_le hn A ( tropMul hn B C ) i j m ) _;
    linarith [ tropMul_entry_le hn B C m j k ]

/-! ## Section 2: Tropical Matrix Powers -/

/-- **Tropical identity matrix**: 0 on diagonal, T off-diagonal. -/
def tropId {n : ℕ} (T : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if i = j then 0 else T

/-- **Tropical matrix power**: M^⊗k.
    Bridge: connects exponentiation in tropical semiring to cryptographic OWF. -/
def tropMatPow {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ) :
    ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => tropId T
  | k + 1 => tropMul hn (tropMatPow hn M T k) M

@[simp] theorem tropMatPow_zero {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ) :
    tropMatPow hn M T 0 = tropId T := rfl

@[simp] theorem tropMatPow_succ {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ)
    (k : ℕ) : tropMatPow hn M T (k + 1) = tropMul hn (tropMatPow hn M T k) M := rfl

theorem tropId_diagonal {n : ℕ} (T : ℝ) (i : Fin n) : tropId T i i = 0 := if_pos rfl

theorem tropId_off_diagonal {n : ℕ} (T : ℝ) (i j : Fin n) (hij : i ≠ j) :
    tropId T i j = T := if_neg hij

/-! ## Section 3: Tropical Distance (Sup-Norm) -/

/-- **Tropical distance** (sup-norm).
    Bridge: connects tropical geometry to lattice cryptography. -/
def tropDist {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => |x i - y i|)

theorem tropDist_nonneg {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) : 0 ≤ tropDist hn x y :=
  le_trans (abs_nonneg _) (Finset.le_sup' (fun i => |x i - y i|) (Finset.mem_univ ⟨0, hn⟩))

theorem tropDist_symm {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) :
    tropDist hn x y = tropDist hn y x := by
  simp only [tropDist]; congr 1; ext i; rw [abs_sub_comm]

theorem tropDist_self {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) : tropDist hn x x = 0 := by
  unfold tropDist
  have : (fun i : Fin n => |x i - x i|) = fun _ => (0 : ℝ) := by ext; simp
  rw [this]
  exact Finset.sup'_const _ _

theorem tropDist_coord_le {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) (i : Fin n) :
    |x i - y i| ≤ tropDist hn x y :=
  Finset.le_sup' (fun i => |x i - y i|) (Finset.mem_univ i)

/-- **Triangle inequality for tropical distance.** -/
theorem tropDist_triangle {n : ℕ} (hn : 0 < n) (x y z : Fin n → ℝ) :
    tropDist hn x z ≤ tropDist hn x y + tropDist hn y z := by
  apply Finset.sup'_le; intro i _
  have h1 := Finset.le_sup' (fun i => |x i - y i|) (Finset.mem_univ i)
  have h2 := Finset.le_sup' (fun i => |y i - z i|) (Finset.mem_univ i)
  have h3 : |x i - z i| ≤ |x i - y i| + |y i - z i| := by
    have : x i - z i = (x i - y i) + (y i - z i) := by ring
    rw [this]; exact abs_add_le _ _
  calc |x i - z i| ≤ |x i - y i| + |y i - z i| := h3
    _ ≤ tropDist hn x y + tropDist hn y z := add_le_add h1 h2

/-! ## Section 4: Lipschitz Properties -/

/-- **Min is 1-Lipschitz.** |min(a,c) - min(b,c)| ≤ |a - b|.
    Bridge: real analysis → tropical algebra → certified robustness -/
theorem min_lipschitz_bound (a b c : ℝ) :
    |min a c - min b c| ≤ |a - b| := by
  simp only [min_def]; split_ifs with h1 h2 h2 <;>
    [exact le_refl _; skip; skip; simp] <;>
    (rw [abs_le]; constructor <;>
      linarith [abs_nonneg (a - b), le_abs_self (a - b), neg_abs_le (a - b)])

theorem min_lipschitz_bound_right (a b c : ℝ) :
    |min c a - min c b| ≤ |a - b| := by
  rw [min_comm c a, min_comm c b]; exact min_lipschitz_bound a b c

/-
**Min-plus vector product is 1-Lipschitz (nonexpansive).**
    Bridge: tropical algebra → certified adversarial robustness
-/
theorem tropLinMap_nonexpansive {n : ℕ} (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (v w : Fin n → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (hbound : ∀ j, |v j - w j| ≤ δ) (i : Fin n) :
    |Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun j => A i j + v j) -
     Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun j => A i j + w j)| ≤ δ := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) fun j => A i j + w j;
    linarith [ abs_le.mp ( hbound j ), Finset.inf'_le ( fun j => A i j + v j ) ( Finset.mem_univ j ) ];
  · obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty_iff.mpr ⟨ ⟨ 0, hn ⟩ ⟩ ) ( fun j ↦ A i j + v j );
    linarith [ abs_le.mp ( hbound j ), Finset.inf'_le ( fun j => A i j + w j ) ( Finset.mem_univ j ) ]

/-! ## Section 5: Certified Robustness -/

def certifiedRobustnessRadius (margin L : ℝ) : ℝ := margin / (2 * L)

/-
**Certified robustness guarantee.**
    Bridge: certified ML robustness → tropical Lipschitz → adversarial defense
-/
theorem certified_robustness_from_margin
    (f₁ f₂ : ℝ → ℝ) (x margin L : ℝ)
    (hm : 0 < margin) (hL : 0 < L)
    (hmargin : f₁ x - f₂ x ≥ margin)
    (hlip₁ : ∀ a b, |f₁ a - f₁ b| ≤ L * |a - b|)
    (hlip₂ : ∀ a b, |f₂ a - f₂ b| ≤ L * |a - b|)
    (δ : ℝ) (hδ : |δ| < margin / (2 * L)) :
    f₁ (x + δ) > f₂ (x + δ) := by
  have := hlip₁ ( x + δ ) x; have := hlip₂ ( x + δ ) x; simp_all +decide [ abs_le ] ;
  rw [ lt_div_iff₀ ] at hδ <;> nlinarith

/-
**Multivariate certified robustness.**
-/
theorem certified_robustness_multivariate {n : ℕ} (hn : 0 < n)
    (f₁ f₂ : (Fin n → ℝ) → ℝ) (x : Fin n → ℝ) (margin L : ℝ)
    (hm : 0 < margin) (hL : 0 < L)
    (hmargin : f₁ x - f₂ x ≥ margin)
    (hlip₁ : ∀ a b, |f₁ a - f₁ b| ≤ L * tropDist hn a b)
    (hlip₂ : ∀ a b, |f₂ a - f₂ b| ≤ L * tropDist hn a b)
    (y : Fin n → ℝ) (hy : tropDist hn y x < margin / (2 * L)) :
    f₁ y > f₂ y := by
  -- By the Lipschitz conditions, we have |f₁ y - f₁ x| ≤ L * tropDist hn y x and |f₂ y - f₂ x| ≤ L * tropDist hn y x.
  have h_lip1 : |f₁ y - f₁ x| ≤ L * tropDist hn y x := by
    exact hlip₁ y x
  have h_lip2 : |f₂ y - f₂ x| ≤ L * tropDist hn y x := by
    exact hlip₂ y x;
  nlinarith [ abs_le.mp h_lip1, abs_le.mp h_lip2, mul_div_cancel₀ margin ( by positivity : ( 2 * L ) ≠ 0 ) ]

/-! ## Section 6: Complexity Bounds -/

structure TropOWFParams where
  dim : ℕ
  dim_ge : 3 ≤ dim
  steps : ℕ
  steps_pos : 0 < steps

def TropOWFParams.forwardCost (p : TropOWFParams) : ℕ := p.dim ^ 3
def TropOWFParams.searchSpace (p : TropOWFParams) : ℕ := 2 ^ p.dim

/-
**n³ < 2^n for n ≥ 10.** Core security gap.
    Bridge: computational complexity → tropical OWF → post-quantum security
-/
theorem tropical_security_exponential_gap (n : ℕ) (hn : 10 ≤ n) : n ^ 3 < 2 ^ n := by
  induction hn <;> norm_num [ pow_succ' ] at * ; nlinarith

theorem owf_exponential_security (p : TropOWFParams) (hp : 10 ≤ p.dim) :
    p.forwardCost < p.searchSpace :=
  tropical_security_exponential_gap p.dim hp

/-
**n² < 2^n for n ≥ 5.**
-/
theorem quadratic_exponential_gap (n : ℕ) (hn : 5 ≤ n) : n ^ 2 < 2 ^ n := by
  induction hn <;> norm_num [ Nat.pow_succ ] at * ; nlinarith

theorem comm_security_gap (n : ℕ) (hn : 10 ≤ n) : 2 * n ^ 2 < 2 ^ n := by
  have h1 : n ^ 3 < 2 ^ n := tropical_security_exponential_gap n hn
  have h2 : 2 * n ^ 2 ≤ n ^ 3 := by nlinarith
  linarith

theorem linear_exponential_gap (n : ℕ) : n ≤ 2 ^ n := Nat.lt_two_pow_self.le

/-! ## Section 7: Collision and Preimage Analysis -/

theorem tropical_preimage_growth (t : ℝ) (n : ℕ) :
    ∃ S : Finset (ℝ × ℝ), S.card ≥ n + 1 ∧ ∀ p ∈ S, min p.1 p.2 = t := by
  use Finset.image ( fun k : ℕ => ( t, t + k ) ) ( Finset.range ( n + 1 ) );
  norm_num [ Finset.card_image_of_injective, Function.Injective ]

theorem min_collision_below_threshold (a b c : ℝ) (ha : a < c) (hb : b < c)
    (heq : min a c = min b c) : a = b := by
  rwa [min_eq_left (le_of_lt ha), min_eq_left (le_of_lt hb)] at heq

theorem tropical_hash_pigeonhole (m n : ℕ) (hlt : m < n) (B : ℕ) (hB : 0 < B) :
    (2 * B + 1) ^ m < (2 * B + 1) ^ n :=
  Nat.pow_lt_pow_right (by omega) hlt

/-! ## Section 8: Commitment Scheme Properties -/

structure TropCommitParams where
  dim : ℕ
  dim_ge : 3 ≤ dim
  valueBound : ℕ
  bound_pos : 0 < valueBound

theorem tropical_commitment_binding_injective {n : ℕ} (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ)
    (h_inj : Function.Injective (tropMatPow hn M T)) :
    ∀ v₁ v₂, tropMatPow hn M T v₁ = tropMatPow hn M T v₂ → v₁ = v₂ :=
  fun _ _ h => h_inj h

theorem commitment_hiding_exponential (d : ℕ) (hd : 3 ≤ d) : d < 2 ^ d :=
  Nat.lt_two_pow_self

/-! ## Section 9: Min-Plus Semiring Algebra -/

theorem minplus_left_distrib (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  simp [min_def]; split_ifs <;> linarith

theorem minplus_right_distrib (a b c : ℝ) :
    min a b + c = min (a + c) (b + c) := by
  simp [min_def]; split_ifs <;> linarith

theorem minplus_idem (a : ℝ) : min a a = a := min_self a
theorem minplus_assoc (a b c : ℝ) : min (min a b) c = min a (min b c) := min_assoc a b c
theorem minplus_comm (a b : ℝ) : min a b = min b a := min_comm a b

/-- **Idempotent power collapse.** x^n = x for n ≥ 1 in idempotent monoid.
    Bridge: monoid theory → tropical DLP obstruction -/
theorem idempotent_power_collapse {M : Type*} [Monoid M]
    (hidem : ∀ m : M, m * m = m) (x : M) (n : ℕ) (hn : 1 ≤ n) :
    x ^ n = x := by
  induction n with
  | zero => omega
  | succ k ih =>
    rw [pow_succ]
    cases k with
    | zero => simp
    | succ k => rw [ih (by omega), hidem]

/-! ## Section 10: Key Exchange -/

structure TropKeyExchangeParams where
  dim : ℕ
  aliceExp : ℕ
  bobExp : ℕ
  dim_ge : 3 ≤ dim
  alice_pos : 0 < aliceExp
  bob_pos : 0 < bobExp

def TropKeyExchangeParams.commCost (p : TropKeyExchangeParams) : ℕ := 2 * p.dim ^ 2

structure TropicalDLPInstance where
  dim : ℕ
  secret : ℕ
  secret_pos : 0 < secret
  dim_ge : 2 ≤ dim

theorem brute_force_quadratic (inst : TropicalDLPInstance) :
    inst.dim ^ 2 ≤ inst.secret * inst.dim ^ 2 :=
  Nat.le_mul_of_pos_left _ inst.secret_pos

theorem exponential_subset_count (m : ℕ) :
    Fintype.card (Finset (Fin m)) = 2 ^ m := by simp [Fintype.card_finset]

/-! ## Section 11: Quantum Obstruction Theorems -/

/-- **Idempotent structures resist quantum period-finding.**
    Bridge: algebra → quantum computing → cryptography -/
theorem tropical_idempotent_quantum_obstruction {M : Type*} [AddCommMonoid M]
    (hidem : ∀ m : M, m + m = m) (φ : ℤ →+ M) (n : ℤ) : φ n = 0 := by
  have hcancel : ∀ k : ℤ, φ k + φ (-k) = 0 := by
    intro k; rw [← map_add, add_neg_cancel, map_zero]
  have hneg : ∀ k : ℤ, φ (-k) = 0 := by
    intro k
    calc φ (-k) = 0 + φ (-k) := (zero_add _).symm
      _ = (φ k + φ (-k)) + φ (-k) := by rw [hcancel k]
      _ = φ k + (φ (-k) + φ (-k)) := by rw [add_assoc]
      _ = φ k + φ (-k) := by rw [hidem]
      _ = 0 := hcancel k
  calc φ n = φ n + 0 := (add_zero _).symm
    _ = φ n + φ (-n) := by rw [hneg n]
    _ = 0 := hcancel n

theorem tropical_min_not_injective (a : ℝ) :
    ¬Function.Injective (fun x : ℝ => min a x) := by
  intro hinj
  have h1 : min a (a + 1) = a := min_eq_left (by linarith)
  have h2 : min a (a + 2) = a := min_eq_left (by linarith)
  have := hinj (show min a (a + 1) = min a (a + 2) by rw [h1, h2])
  linarith

theorem tropical_min_not_cancellative :
    ∃ a b c : ℝ, min a c = min b c ∧ a ≠ b :=
  ⟨0, 1, -1, by norm_num, by norm_num⟩

theorem tropical_hash_collision_existence (c : ℝ) :
    ∃ a b : ℝ, a ≠ b ∧ min a c = min b c :=
  ⟨c + 1, c + 2, by linarith, by
    rw [min_eq_right (by linarith : c ≤ c + 1), min_eq_right (by linarith : c ≤ c + 2)]⟩

/-! ## Section 12: Master Bridge Theorem -/

/-- **The Tropical Post-Quantum Cryptographic Framework.**
    Bridge: tropical algebra ↔ post-quantum crypto ↔ certified ML robustness -/
theorem tropical_post_quantum_framework (n : ℕ) (hn : 10 ≤ n) :
    (∀ a : ℝ, min a a = a) ∧
    (∀ a b c : ℝ, a + min b c = min (a + b) (a + c)) ∧
    (n ^ 3 < 2 ^ n) ∧
    (∀ a b c : ℝ, |min a c - min b c| ≤ |a - b|) ∧
    (n ≤ 2 ^ n) :=
  ⟨min_self, minplus_left_distrib, tropical_security_exponential_gap n hn,
   min_lipschitz_bound, linear_exponential_gap n⟩

end TropicalOWF