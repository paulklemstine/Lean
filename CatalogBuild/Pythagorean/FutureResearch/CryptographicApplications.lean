/-! # CatalogBuild.Pythagorean.FutureResearch.CryptographicApplications

Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 10
-/

import Mathlib

/-- [Section: ## Pell Sequence Definitions] -/
def pellH : ℕ → ℤ
  | 0 => 1
  | 1 => 1
  | n + 2 => 2 * pellH (n + 1) + pellH n


/-- [Section: # CatalogBuild.Pythagorean.FutureResearch.CryptographicApplications
Auto-generated from theorem catalog database.
Domain: Pythagorean/FutureResearch
Declarations: 10] -/
def pellP : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => 2 * pellP (n + 1) + pellP n


/-- [Section: ## Correctness of Fast Doubling
The fast doubling algorithm computes P_{2n} and H_{2n} from P_n and H_n.
This is the core of efficient Pell sequence computation in O(log n) steps.] -/
theorem pellP_double (n : ℕ) : pellP (2 * n) = 2 * pellP n * pellH n := by
  by_contra h;
  -- We'll use induction to prove that the formula holds for all $n$.
  have h_ind : ∀ n, pellP (2 * n) = 2 * pellP n * pellH n ∧ pellH (2 * n) = pellH n ^ 2 + 2 * pellP n ^ 2 := by
    intro n;
    induction' n using Nat.strong_induction_on with n ih;
    rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, Nat.mul_succ ];
    have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; have := ih ( n + 2 ) ( by linarith ) ; simp_all +decide [ Nat.mul_succ, pellP, pellH ] ; ring;
    grind;
  exact h ( h_ind n |>.1 )


theorem pellH_double (n : ℕ) : pellH (2 * n) = 2 * pellH n ^ 2 - (-1 : ℤ) ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, ih ];
  have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; have := ih ( n + 2 ) ( by linarith ) ; norm_num [ Nat.mul_succ, pow_succ, pellH ] at *;
  grind


/-- [Section: ## Key Exchange Security
The security of Pell-based key exchange relies on the hardness of:
Given P_a mod N and P_b mod N, compute P_{ab} mod N.
Key property: The addition formula P(m+n) = P(m)H(n) + H(m)P(n)
allows computing P_{ab} from (H_a, P_a) and (H_b, P_b).] -/
theorem pellP_add (m n : ℕ) :
    pellP (m + n) = pellP m * pellH n + pellH m * pellP n := by
  -- By definition of $pellP$ and $pellH$, we know that they satisfy the same recurrence relation.
  have h_recurrence : ∀ n, pellP (n + 2) = 2 * pellP (n + 1) + pellP n ∧ pellH (n + 2) = 2 * pellH (n + 1) + pellH n := by
    exact fun n => ⟨ rfl, rfl ⟩;
  induction' n using Nat.strong_induction_on with n ih generalizing m;
  rcases n with ( _ | _ | n ) <;> simp +arith +decide [ * ];
  · induction' m using Nat.strong_induction_on with m ih;
    rcases m with ( _ | _ | m ) <;> simp +arith +decide [ * ];
    grind;
  · induction' m using Nat.strong_induction_on with m ih;
    rcases m with ( _ | _ | m ) <;> simp +arith +decide [ * ];
    grind;
  · have := ih n ( by linarith ) m; have := ih ( n + 1 ) ( by linarith ) m; simp_all +decide [ Nat.add_comm, Nat.add_left_comm, Nat.add_assoc ] ; ring;
    rw [ show 1 + n = n + 1 by ring ] ; have := ih 1 ( by linarith ) ( m + n ) ; simp_all +decide [ Nat.add_comm, Nat.add_left_comm, Nat.add_assoc ] ; ring;
    rw [ show 1 + n = n + 1 by ring ] ; norm_num [ pellP, pellH ] at * ; linarith;


theorem pellH_from_pellP (n : ℕ) :
    pellH n ^ 2 = 2 * pellP n ^ 2 + (-1 : ℤ) ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp_all +decide;
  have h₁ := ih ( n + 1 ) ( by linarith ) ; have h₂ := ih n ( by linarith ) ; norm_num [ pow_succ, pellP, pellH ] at *;
  have h₄ := ih ( n + 1 ) ( by linarith ) ; have h₅ := ih ( n + 2 ) ( by linarith ) ; norm_num [ pow_succ, pellP, pellH ] at * ; linarith


/-- [Section: ## Verifiable Delay Function Properties
A VDF based on Pell sequences: compute P_G mod N sequentially.
Verification: check H_G² - 2·P_G² ≡ ±1 (mod N).] -/
theorem vdf_verification (n : ℕ) :
    pellH n ^ 2 - 2 * pellP n ^ 2 = (-1 : ℤ) ^ n := by
  cases n <;> simp_all +decide [ pow_succ' ];
  rename_i n;
  have := pellH_from_pellP ( n + 1 );
  linear_combination' this


theorem vdf_parity_detection (n : ℕ) :
    (pellH n ^ 2 - 2 * pellP n ^ 2 = 1) ↔ Even n := by
  rw [ vdf_verification ];
  by_cases h : Even n <;> simp +decide [ h ];
  aesop


/-- The Pell "norm" is multiplicative (pure algebra, no Pell sequences needed) -/
theorem pell_norm_mul (a b c d : ℤ) :
    (a * c + 2 * b * d) ^ 2 - 2 * (b * c + a * d) ^ 2 =
    (a ^ 2 - 2 * b ^ 2) * (c ^ 2 - 2 * d ^ 2) := by
  ring


/-- [Section: ## Modular Exponentiation Properties] -/
theorem pell_norm_compose (m n : ℕ) :
    pellH (m + n) ^ 2 - 2 * pellP (m + n) ^ 2 =
    (pellH m ^ 2 - 2 * pellP m ^ 2) * (pellH n ^ 2 - 2 * pellP n ^ 2) := by
  have := vdf_verification ( m + n );
  rw [ this, pow_add, ← vdf_verification m, ← vdf_verification n ]


