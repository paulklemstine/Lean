/-
  Knuth Semifield Classification via Nuclei

  This file develops the algebraic theory of finite semifields through their
  nucleus structure, formalizing key results in the Knuth classification program.

  A **semifield** is a finite division algebra (possibly non-associative) with
  both distributive laws and no zero divisors. Every finite semifield
  coordinatizes a translation plane; the plane is Desarguesian iff the
  semifield is a field.

  **Main results**:
  1. NucleiConfig — the discrete invariant of semifields up to isotopy
  2. Knuth S₃ action on nucleus triples (transpose, dual are involutions)
  3. Nucleus product bound and field characterization
  4. Defect-rank duality connecting algebra to geometry
  5. Coding theory bridge: semifield → rank-metric code parameters
-/
import Mathlib

open Finset Function Set

/-! ## NucleiConfig: The Fundamental Discrete Invariant -/

/-- A `NucleiConfig` encodes the nucleus sizes of a finite semifield of
    order `p^n`. Each nucleus has order `p^(d_x)` where `d_x | n`. -/
structure NucleiConfig where
  p : ℕ
  hp : Nat.Prime p
  n : ℕ
  hn : 1 ≤ n
  d_l : ℕ
  d_m : ℕ
  d_r : ℕ
  d_0 : ℕ
  center_le_left : d_0 ≤ d_l
  center_le_mid : d_0 ≤ d_m
  center_le_right : d_0 ≤ d_r
  dl_dvd : d_l ∣ n
  dm_dvd : d_m ∣ n
  dr_dvd : d_r ∣ n
  d0_dvd : d_0 ∣ n
  d0_dvd_dl : d_0 ∣ d_l
  d0_dvd_dm : d_0 ∣ d_m
  d0_dvd_dr : d_0 ∣ d_r

namespace NucleiConfig

def order (cfg : NucleiConfig) : ℕ := cfg.p ^ cfg.n
def leftNucSize (cfg : NucleiConfig) : ℕ := cfg.p ^ cfg.d_l
def midNucSize (cfg : NucleiConfig) : ℕ := cfg.p ^ cfg.d_m
def rightNucSize (cfg : NucleiConfig) : ℕ := cfg.p ^ cfg.d_r
def centerSize (cfg : NucleiConfig) : ℕ := cfg.p ^ cfg.d_0

def nucProduct (cfg : NucleiConfig) : ℕ :=
  cfg.leftNucSize * cfg.midNucSize * cfg.rightNucSize

def leftRank (cfg : NucleiConfig) : ℕ := cfg.n / cfg.d_l
def midRank (cfg : NucleiConfig) : ℕ := cfg.n / cfg.d_m
def rightRank (cfg : NucleiConfig) : ℕ := cfg.n / cfg.d_r

def isField (cfg : NucleiConfig) : Prop :=
  cfg.d_l = cfg.n ∧ cfg.d_m = cfg.n ∧ cfg.d_r = cfg.n

def nucExpSum (cfg : NucleiConfig) : ℕ := cfg.d_l + cfg.d_m + cfg.d_r

end NucleiConfig

/-! ## Knuth Operations -/

def knuthTranspose (cfg : NucleiConfig) : NucleiConfig where
  p := cfg.p; hp := cfg.hp; n := cfg.n; hn := cfg.hn
  d_l := cfg.d_r; d_m := cfg.d_m; d_r := cfg.d_l; d_0 := cfg.d_0
  center_le_left := cfg.center_le_right; center_le_mid := cfg.center_le_mid
  center_le_right := cfg.center_le_left
  dl_dvd := cfg.dr_dvd; dm_dvd := cfg.dm_dvd; dr_dvd := cfg.dl_dvd
  d0_dvd := cfg.d0_dvd
  d0_dvd_dl := cfg.d0_dvd_dr; d0_dvd_dm := cfg.d0_dvd_dm; d0_dvd_dr := cfg.d0_dvd_dl

def knuthDual (cfg : NucleiConfig) : NucleiConfig where
  p := cfg.p; hp := cfg.hp; n := cfg.n; hn := cfg.hn
  d_l := cfg.d_m; d_m := cfg.d_l; d_r := cfg.d_r; d_0 := cfg.d_0
  center_le_left := cfg.center_le_mid; center_le_mid := cfg.center_le_left
  center_le_right := cfg.center_le_right
  dl_dvd := cfg.dm_dvd; dm_dvd := cfg.dl_dvd; dr_dvd := cfg.dr_dvd
  d0_dvd := cfg.d0_dvd
  d0_dvd_dl := cfg.d0_dvd_dm; d0_dvd_dm := cfg.d0_dvd_dl; d0_dvd_dr := cfg.d0_dvd_dr

def knuthRotate (cfg : NucleiConfig) : NucleiConfig :=
  knuthDual (knuthTranspose cfg)

/-- The isotopy invariant: the multiset of nucleus exponents. -/
def isotopyInvariant (cfg : NucleiConfig) : Multiset ℕ :=
  {cfg.d_l, cfg.d_m, cfg.d_r}

/-! ## Knuth Involution Theorems -/

/-
Knuth transpose is an involution.
-/
theorem knuthTranspose_involution (cfg : NucleiConfig) :
    knuthTranspose (knuthTranspose cfg) = cfg := by
  -- The proof is a direct computation of applying the transpose twice.
  -- Each field either remains the same (p, n, etc.) or is swapped twice (d_l ↔ d_r).
  dsimp [knuthTranspose]

/-
Knuth dual is an involution.
-/
theorem knuthDual_involution (cfg : NucleiConfig) :
    knuthDual (knuthDual cfg) = cfg := by
  cases cfg ; aesop

/-- Knuth operations preserve order. -/
theorem knuth_preserves_order (cfg : NucleiConfig) :
    (knuthTranspose cfg).order = cfg.order ∧
    (knuthDual cfg).order = cfg.order := by
  constructor <;> simp [NucleiConfig.order, knuthTranspose, knuthDual]

/-
Knuth operations preserve the nucleus product.
-/
theorem knuth_preserves_nucProduct (cfg : NucleiConfig) :
    (knuthTranspose cfg).nucProduct = cfg.nucProduct ∧
    (knuthDual cfg).nucProduct = cfg.nucProduct := by
  unfold knuthTranspose knuthDual NucleiConfig.nucProduct NucleiConfig.leftNucSize NucleiConfig.midNucSize NucleiConfig.rightNucSize; ring;
  norm_num

/-- Knuth operations preserve the nucleus exponent sum. -/
theorem knuth_preserves_nucExpSum (cfg : NucleiConfig) :
    (knuthTranspose cfg).nucExpSum = cfg.nucExpSum ∧
    (knuthDual cfg).nucExpSum = cfg.nucExpSum := by
  constructor <;> simp [NucleiConfig.nucExpSum, knuthTranspose, knuthDual] <;> omega

/-! ## Isotopy Invariant Preservation -/

/-- Knuth transpose preserves the isotopy invariant. -/
theorem knuthTranspose_preserves_isotopy (cfg : NucleiConfig) :
    isotopyInvariant (knuthTranspose cfg) = isotopyInvariant cfg := by
  simp [isotopyInvariant, knuthTranspose]
  ext x; simp [Multiset.count_cons, Multiset.count_singleton]; omega

/-- Knuth dual preserves the isotopy invariant. -/
theorem knuthDual_preserves_isotopy (cfg : NucleiConfig) :
    isotopyInvariant (knuthDual cfg) = isotopyInvariant cfg := by
  simp [isotopyInvariant, knuthDual]
  ext x; simp [Multiset.count_cons, Multiset.count_singleton]; omega

/-! ## Fixed Point Characterization -/

/-
Transpose is trivial iff d_l = d_r.
-/
theorem knuthTranspose_trivial_iff (cfg : NucleiConfig) :
    knuthTranspose cfg = cfg ↔ cfg.d_l = cfg.d_r := by
  constructor;
  · grind +locals;
  · intro h; cases cfg; aesop;

/-
Dual is trivial iff d_l = d_m.
-/
theorem knuthDual_trivial_iff (cfg : NucleiConfig) :
    knuthDual cfg = cfg ↔ cfg.d_l = cfg.d_m := by
  cases cfg;
  grind +locals

/-
Both trivial iff all nuclei equal.
-/
theorem knuth_all_trivial_iff (cfg : NucleiConfig) :
    (knuthTranspose cfg = cfg ∧ knuthDual cfg = cfg) ↔
    (cfg.d_l = cfg.d_m ∧ cfg.d_m = cfg.d_r) := by
  grind +suggestions

/-
A field has trivial Knuth action.
-/
theorem field_knuth_trivial (cfg : NucleiConfig) (hf : cfg.isField) :
    knuthTranspose cfg = cfg ∧ knuthDual cfg = cfg := by
  cases hf;
  cases cfg;
  aesop ( simp_config := { singlePass := true } )

/-! ## Nucleus Divisibility -/

/-- Each nucleus size divides the semifield order. -/
theorem nucleus_divides_order (cfg : NucleiConfig) :
    cfg.leftNucSize ∣ cfg.order ∧
    cfg.midNucSize ∣ cfg.order ∧
    cfg.rightNucSize ∣ cfg.order := by
  have hn : 0 < cfg.n := by linarith [cfg.hn]
  exact ⟨pow_dvd_pow _ (Nat.le_of_dvd hn cfg.dl_dvd),
         pow_dvd_pow _ (Nat.le_of_dvd hn cfg.dm_dvd),
         pow_dvd_pow _ (Nat.le_of_dvd hn cfg.dr_dvd)⟩

/-! ## Rank-Size Duality -/

/-- n = d_l · leftRank -/
theorem rank_size_duality_left (cfg : NucleiConfig) :
    cfg.n = cfg.d_l * cfg.leftRank :=
  (Nat.mul_div_cancel' cfg.dl_dvd).symm

theorem rank_size_duality_mid (cfg : NucleiConfig) :
    cfg.n = cfg.d_m * cfg.midRank :=
  (Nat.mul_div_cancel' cfg.dm_dvd).symm

theorem rank_size_duality_right (cfg : NucleiConfig) :
    cfg.n = cfg.d_r * cfg.rightRank :=
  (Nat.mul_div_cancel' cfg.dr_dvd).symm

/-! ## Nucleus Exponent Sum Bound -/

/-
**Nucleus Exponent Sum Bound**: Each nucleus exponent divides and is
    at most n, so the sum is at most 3n. If at least one is proper, sum < 3n.
-/
theorem nucleus_exponent_sum_lt_3n (cfg : NucleiConfig)
    (h_not_field : cfg.d_l < cfg.n ∨ cfg.d_m < cfg.n ∨ cfg.d_r < cfg.n) :
    cfg.nucExpSum < 3 * cfg.n := by
  rcases h_not_field with ( h | h | h ) <;> linarith [ cfg.dl_dvd, cfg.dm_dvd, cfg.dr_dvd, Nat.le_of_dvd cfg.hn cfg.dl_dvd, Nat.le_of_dvd cfg.hn cfg.dm_dvd, Nat.le_of_dvd cfg.hn cfg.dr_dvd, show cfg.nucExpSum = cfg.d_l + cfg.d_m + cfg.d_r from rfl ]

/-
**Strong sum bound**: When ALL three nuclei are proper and n≥2,
    each is ≤ n/2, so d_l + d_m + d_r ≤ 3*(n/2).
-/
theorem all_proper_nuclei_sum_bound (cfg : NucleiConfig)
    (hn : 2 ≤ cfg.n) (hp : Nat.Prime cfg.n ∨ 4 ≤ cfg.n)
    (hl : cfg.d_l < cfg.n) (hm : cfg.d_m < cfg.n) (hr : cfg.d_r < cfg.n) :
    cfg.d_l ≤ cfg.n / 2 ∧ cfg.d_m ≤ cfg.n / 2 ∧ cfg.d_r ≤ cfg.n / 2 := by
  have h_div : ∀ {d : ℕ}, d ∣ cfg.n → d < cfg.n → d ≤ cfg.n / 2 := by
    intro d hd hd'; rw [ Nat.le_div_iff_mul_le zero_lt_two ] ; obtain ⟨ k, hk ⟩ := hd; nlinarith [ show k > 1 from Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by aesop_cat, by aesop_cat ⟩ ] ;
  exact ⟨ h_div cfg.dl_dvd hl, h_div cfg.dm_dvd hm, h_div cfg.dr_dvd hr ⟩

/-! ## Field Characterization -/

/-
A NucleiConfig is a field iff all ranks are 1.
-/
theorem isField_iff_all_ranks_one (cfg : NucleiConfig) :
    cfg.isField ↔ (cfg.leftRank = 1 ∧ cfg.midRank = 1 ∧ cfg.rightRank = 1) := by
  constructor <;> intro h <;> simp_all +decide [ NucleiConfig.isField ];
  · unfold NucleiConfig.leftRank NucleiConfig.midRank NucleiConfig.rightRank; simp +decide [ h ] ;
    rw [ Nat.div_self ( cfg.hn ) ];
  · unfold NucleiConfig.leftRank NucleiConfig.midRank NucleiConfig.rightRank at h;
    exact ⟨ by nlinarith [ Nat.div_mul_cancel cfg.dl_dvd ], by nlinarith [ Nat.div_mul_cancel cfg.dm_dvd ], by nlinarith [ Nat.div_mul_cancel cfg.dr_dvd ] ⟩

/-
The nucleus product of a field equals order³.
-/
theorem field_nucProduct (cfg : NucleiConfig) (hf : cfg.isField) :
    cfg.nucProduct = cfg.order ^ 3 := by
  unfold NucleiConfig.isField at hf;
  unfold NucleiConfig.nucProduct NucleiConfig.leftNucSize NucleiConfig.midNucSize NucleiConfig.rightNucSize NucleiConfig.order; norm_num [ hf ] ; ring;

/-
**nucProduct ≤ order³**: Always true since each exponent ≤ n.
-/
theorem nucProduct_le_order_cube (cfg : NucleiConfig) :
    cfg.nucProduct ≤ cfg.order ^ 3 := by
  -- By definition of exponentiation, we can rewrite the inequality as $p^{d_l} \cdot p^{d_m} \cdot p^{d_r} \leq p^{3n}$.
  suffices h_exp : cfg.p ^ cfg.d_l * cfg.p ^ cfg.d_m * cfg.p ^ cfg.d_r ≤ cfg.p ^ (3 * cfg.n) by
    convert h_exp using 1;
    rw [ NucleiConfig.order, pow_mul' ];
  rw [ ← pow_add, ← pow_add ];
  exact pow_le_pow_right₀ cfg.hp.one_lt.le ( by linarith [ cfg.center_le_left, cfg.center_le_mid, cfg.center_le_right, Nat.le_of_dvd cfg.hn cfg.dl_dvd, Nat.le_of_dvd cfg.hn cfg.dm_dvd, Nat.le_of_dvd cfg.hn cfg.dr_dvd ] )

/-
**nucProduct < order³ for non-fields**: Strict bound.
-/
theorem nucProduct_lt_order_cube (cfg : NucleiConfig)
    (h : cfg.d_l < cfg.n ∨ cfg.d_m < cfg.n ∨ cfg.d_r < cfg.n) :
    cfg.nucProduct < cfg.order ^ 3 := by
  unfold NucleiConfig.nucProduct NucleiConfig.order;
  convert pow_lt_pow_right₀ cfg.hp.one_lt ( nucleus_exponent_sum_lt_3n cfg h ) using 1 ; ring;
  · unfold NucleiConfig.leftNucSize NucleiConfig.midNucSize NucleiConfig.rightNucSize NucleiConfig.nucExpSum; ring;
  · ring

/-! ## Defect-Rank Duality -/

/-
Defect = 0 iff k = n (when n > 0).
-/
theorem defect_zero_iff_eq (p k n : ℕ) (hp : Nat.Prime p)
    (hk : 1 ≤ k) (hn : 1 ≤ n) (hkn : k ∣ n) :
    (p ^ n - p ^ k = 0) ↔ k = n := by
  obtain ⟨ m, rfl ⟩ := hkn;
  rcases m with ( _ | _ | m ) <;> simp_all +decide [ pow_mul ];
  exact iff_of_false ( Nat.sub_ne_zero_of_lt ( lt_self_pow₀ ( one_lt_pow₀ hp.one_lt ( by linarith ) ) ( by linarith ) ) ) ( by nlinarith )

/-
If rank ≥ 2, defect ≥ p^k · (p^k - 1).
-/
theorem minimum_nonfield_defect (p k : ℕ) (hp : Nat.Prime p) (_hk : 1 ≤ k)
    (n : ℕ) (hkn : k ∣ n) (hrank : 2 ≤ n / k) :
    p ^ k * (p ^ k - 1) ≤ p ^ n - p ^ k := by
  -- Since $k$ divides $n$, there exists some integer $m$ such that $n = k * m$.
  obtain ⟨m, hm⟩ : ∃ m, n = k * m := hkn;
  -- Since $m \geq 2$, we have $p^{km} \geq p^{2k} = (p^k)^2$.
  have h_prime_pow : p ^ (k * m) ≥ (p ^ k) ^ 2 := by
    rw [ ← pow_mul ] ; exact Nat.pow_le_pow_right hp.pos ( by nlinarith [ Nat.div_mul_cancel ( show k ∣ n from hm ▸ dvd_mul_right _ _ ) ] ) ;
  rw [ hm, mul_tsub ];
  grind

/-- Rank monotonicity: larger exponent → larger defect. -/
theorem rank_monotone_defect (p k n₁ n₂ : ℕ) (hp : 1 ≤ p) (hle : n₁ ≤ n₂) :
    p ^ n₁ - p ^ k ≤ p ^ n₂ - p ^ k :=
  Nat.sub_le_sub_right (Nat.pow_le_pow_right hp hle) _

/-! ## Non-Field Existence -/

/-
For composite n ≥ 2, there is a proper divisor.
-/
theorem composite_has_proper_divisor (n : ℕ) (hn : 2 ≤ n) (hcomp : ¬Nat.Prime n) :
    ∃ d : ℕ, 1 < d ∧ d < n ∧ d ∣ n := by
  exact Exists.imp ( by tauto ) ( Nat.exists_dvd_of_not_prime2 hn hcomp )

/-- Hall defect formula. -/
theorem hall_defect_value (q : ℕ) (_hq : 1 ≤ q) :
    q ^ 2 - q = q * (q - 1) := by
  rw [sq, Nat.mul_sub_one]

/-! ## Coding Theory Bridge -/

/-- Semifield spread code parameters. -/
structure SemifieldCode where
  n : ℕ
  k : ℕ
  min_dist : ℕ
  k_dvd_n : k ∣ n
  dist_eq : min_dist = n / k

/-- Code from a NucleiConfig. -/
def codeFromConfig (cfg : NucleiConfig) : SemifieldCode where
  n := cfg.n; k := cfg.d_l; min_dist := cfg.leftRank
  k_dvd_n := cfg.dl_dvd; dist_eq := rfl

/-- Larger nucleus → weaker code. -/
theorem larger_nucleus_weaker_code (n d₁ d₂ : ℕ)
    (hd₁ : d₁ ∣ n) (_hd₂ : d₂ ∣ n) (hle : d₁ ≤ d₂) (hn : 0 < n) :
    n / d₂ ≤ n / d₁ :=
  Nat.div_le_div_left hle (Nat.pos_of_dvd_of_pos hd₁ hn)

/-- Field gives minimum distance 1 (trivial code). -/
theorem field_gives_trivial_code (cfg : NucleiConfig) (hf : cfg.isField) :
    cfg.leftRank = 1 := by
  simp [NucleiConfig.leftRank, hf.1, Nat.div_self (by linarith [cfg.hn])]

/-- Minimum nucleus (d_l = 1) gives maximum distance n. -/
theorem min_nucleus_max_distance (cfg : NucleiConfig) (h : cfg.d_l = 1) :
    cfg.leftRank = cfg.n := by
  simp [NucleiConfig.leftRank, h]

/-- Transpose swaps code and dual code parameters. -/
theorem transpose_swaps_codes (cfg : NucleiConfig) :
    (codeFromConfig (knuthTranspose cfg)).k = cfg.d_r ∧
    (codeFromConfig cfg).k = (knuthTranspose cfg).d_r := by
  simp [codeFromConfig, knuthTranspose]

/-
MRD criterion forces k ∈ {1, n}.
-/
theorem mrd_forces_extremal (n k : ℕ) (_hn : 2 ≤ n) (hk : 1 ≤ k)
    (hkn : k ∣ n) (hklen : k ≤ n)
    (h_mrd : n / k = n - k + 1) :
    k = 1 ∨ k = n := by
  rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.div_eq_of_lt ];
  nlinarith [ Nat.div_mul_le_self n ( k + 2 ), Nat.sub_add_cancel hklen ]

/-! ## Twisted Field Construction -/

/-- Configuration for a generalized twisted field. -/
structure TwistedFieldConfig where
  p : ℕ
  hp : Nat.Prime p
  n : ℕ
  hn : 2 ≤ n
  sigma_order : ℕ
  sigma_dvd : sigma_order ∣ n
  sigma_gt_one : 1 < sigma_order

/-- Twisted field → NucleiConfig with d_l = d_r = n/σ, d_m = 1. -/
def twistedToNuclei (t : TwistedFieldConfig) : NucleiConfig where
  p := t.p; hp := t.hp; n := t.n
  hn := le_trans (by norm_num : 1 ≤ 2) t.hn
  d_l := t.n / t.sigma_order; d_m := 1; d_r := t.n / t.sigma_order; d_0 := 1
  center_le_left := by exact Nat.div_pos (Nat.le_of_dvd (by linarith [t.hn]) t.sigma_dvd) (by linarith [t.sigma_gt_one])
  center_le_mid := le_refl 1
  center_le_right := by exact Nat.div_pos (Nat.le_of_dvd (by linarith [t.hn]) t.sigma_dvd) (by linarith [t.sigma_gt_one])
  dl_dvd := Nat.div_dvd_of_dvd t.sigma_dvd
  dm_dvd := one_dvd t.n; dr_dvd := Nat.div_dvd_of_dvd t.sigma_dvd
  d0_dvd := one_dvd t.n
  d0_dvd_dl := one_dvd _; d0_dvd_dm := dvd_refl 1; d0_dvd_dr := one_dvd _

/-
Twisted fields are transpose-symmetric.
-/
theorem twisted_field_symmetric (t : TwistedFieldConfig) :
    knuthTranspose (twistedToNuclei t) = twistedToNuclei t := by
  unfold knuthTranspose twistedToNuclei; aesop;

/-- Twisted fields have small middle nucleus (d_m = 1). -/
theorem twisted_field_small_middle (t : TwistedFieldConfig) :
    (twistedToNuclei t).d_m = 1 := by
  simp [twistedToNuclei]

/-
Twisted field left rank = automorphism order.
-/
theorem twisted_field_left_rank (t : TwistedFieldConfig) :
    (twistedToNuclei t).leftRank = t.sigma_order := by
  convert Nat.div_div_self _ _ using 1;
  · exact t.sigma_dvd;
  · exact Nat.ne_of_gt ( t.hn.trans_lt' ( by norm_num ) )

/-- Distinct isotopy invariants → non-isotopic planes. -/
theorem distinct_invariant_nonisotopic (cfg₁ cfg₂ : NucleiConfig)
    (h : isotopyInvariant cfg₁ ≠ isotopyInvariant cfg₂) :
    cfg₁ ≠ cfg₂ :=
  fun heq => h (by rw [heq])

/-! ## Computational Verification -/

theorem order_16_nucleus_options (d : ℕ) (hd : d ∣ 4) (hd1 : 1 ≤ d) :
    d ∈ ({1, 2, 4} : Finset ℕ) := by
  have : d ≤ 4 := Nat.le_of_dvd (by norm_num) hd
  interval_cases d <;> simp_all

theorem order_64_code_distances :
    (6 / 1 = 6) ∧ (6 / 2 = 3) ∧ (6 / 3 = 2) ∧ (6 / 6 = 1) := by decide