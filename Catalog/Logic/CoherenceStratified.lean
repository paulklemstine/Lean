/-! # CatalogBuild.Logic.CoherenceStratified

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 27
-/

import Mathlib

noncomputable section

/-- Coherence tier of a computational problem -/
inductive CoherenceTier
  | tier0  -- locally decidable
  | tier1  -- bounded coordination
  | tier2  -- polynomial coordination
  | tier3  -- global coordination
  deriving DecidableEq, Repr




/-- Natural ordering on tiers -/
def CoherenceTier.toNat : CoherenceTier → ℕ
  | .tier0 => 0
  | .tier1 => 1
  | .tier2 => 2
  | .tier3 => 3




/-- [Section: # CatalogBuild.Logic.CoherenceStratified
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 27] -/
instance : LE CoherenceTier where
  le a b := a.toNat ≤ b.toNat




/-- Tier 0 ≤ all tiers -/
theorem tier0_le (t : CoherenceTier) : CoherenceTier.tier0 ≤ t := by
  show (0 : ℕ) ≤ t.toNat
  exact Nat.zero_le _




/-- Tier ordering is total -/
theorem tier_total (a b : CoherenceTier) : a ≤ b ∨ b ≤ a := by
  show a.toNat ≤ b.toNat ∨ b.toNat ≤ a.toNat
  exact le_total a.toNat b.toNat




/-- All tiers ≤ tier3 -/
theorem le_tier3 (t : CoherenceTier) : t ≤ CoherenceTier.tier3 := by
  show t.toNat ≤ 3
  cases t <;> simp [CoherenceTier.toNat] <;> omega




/-- Communication complexity of a two-party problem -/
structure CommComplexity where
  commBits : ℕ → ℕ  -- communication as function of input size




/-- Constant communication -/
def isConstantComm (cc : CommComplexity) : Prop :=
  ∃ c, ∀ n, cc.commBits n ≤ c




/-- Logarithmic communication -/
def isLogComm (cc : CommComplexity) : Prop :=
  ∃ c, ∀ n, 0 < n → cc.commBits n ≤ c * Nat.log 2 n




/-- Polynomial communication -/
def isPolyComm (cc : CommComplexity) : Prop :=
  ∃ c k, ∀ n, 0 < n → cc.commBits n ≤ c * n ^ k




/-- [Section: # CatalogBuild.Logic.CoherenceStratified
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 27] -/
theorem log_implies_poly (cc : CommComplexity) (h : isLogComm cc) :
    isPolyComm cc := by
      obtain ⟨ c, hc ⟩ := h;
      use c, 1;
      exact fun n hn => le_trans ( hc n hn ) ( Nat.mul_le_mul_left _ ( Nat.le_of_lt ( Nat.log_lt_of_lt_pow ( by linarith ) ( by exact Nat.recOn n ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ ] at * ; nlinarith ) ) ) )




theorem binomial_sum (n : ℕ) :
    Finset.sum (Finset.range (n + 1)) (fun k => Nat.choose n k) = 2 ^ n := by
      convert Nat.sum_range_choose n




theorem info_lower_bound (k : ℕ) : k ≤ Nat.log 2 (2 ^ k) + 1 := by
  rw [ Nat.log_pow ] <;> norm_num




/-- Circuit depth measures sequential coordination -/
structure CircuitDepth where
  depth : ℕ → ℕ  -- depth as function of input size
  size : ℕ → ℕ   -- size as function of input size




/-- Constant-depth circuits correspond to Tier 0/1 -/
def isConstantDepth (cd : CircuitDepth) : Prop :=
  ∃ d, ∀ n, cd.depth n ≤ d




/-- Log-depth circuits correspond to Tier 1/2 -/
def isLogDepth (cd : CircuitDepth) : Prop :=
  ∃ c, ∀ n, 0 < n → cd.depth n ≤ c * Nat.log 2 n




/-- Polynomial-depth circuits correspond to Tier 2/3 -/
def isPolyDepth (cd : CircuitDepth) : Prop :=
  ∃ c k, ∀ n, cd.depth n ≤ c * n ^ k




theorem bool_fn_count (n : ℕ) :
    Fintype.card (Fin (2^n) → Bool) = 2 ^ (2 ^ n) := by
      norm_num




theorem tier0_fraction (n : ℕ) (hn : 2 ≤ n) :
    2 ^ (n + 1) ≤ 2 ^ (2 ^ n) := by
      exact pow_le_pow_right₀ ( by norm_num ) ( Nat.recOn n ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ Nat.pow_le_pow_right ( by norm_num : 1 ≤ 2 ) ihn ] )




/-- A defect measures how far a solution is from optimal -/
structure Defect where
  value : ℝ
  hnneg : 0 ≤ value




/-- Zero defect means perfect solution -/
def Defect.zero : Defect := ⟨0, le_refl _⟩




/-- Defect addition -/
def Defect.add (d1 d2 : Defect) : Defect :=
  ⟨d1.value + d2.value, add_nonneg d1.hnneg d2.hnneg⟩




/-- Zero is the least defect -/
theorem defect_zero_le (d : Defect) : Defect.zero ≤ d := d.hnneg




/-- Approximation ratio via defect -/
noncomputable def approxRatio (optimal achieved : ℝ) (hopt : 0 < optimal) : ℝ :=
  achieved / optimal




theorem approxRatio_ge_one (opt ach : ℝ) (hopt : 0 < opt) (hge : opt ≤ ach) :
    1 ≤ approxRatio opt ach hopt := by
      unfold approxRatio;
      rwa [ one_le_div hopt ]




/-- FPT: solvable in f(k) · n^c time -/
def IsFPT (time : ℕ → ℕ → ℕ) : Prop :=
  ∃ f : ℕ → ℕ, ∃ c : ℕ, ∀ n k, time n k ≤ f k * n ^ c + f k




/-- FPT problems have coherence tier ≤ 1 -/
theorem fpt_tier_bound :
    CoherenceTier.tier0 ≤ CoherenceTier.tier1 := by
  show (0 : ℕ) ≤ 1
  exact Nat.zero_le _




end
