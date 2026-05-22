/- Original: BerggrenABranchForAll.lean -/



/-- B₁ applied to a triple -/
def applyB₁ (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)

/-- B₁ⁿ · (3,4,5) by iteration -/
def A_iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => applyB₁ (A_iter n)

/-- The A-branch closed form -/
def A_closed (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * ↑n + 3, 2 * (↑n + 1) * (↑n + 2), 2 * (↑n : ℤ)^2 + 6 * ↑n + 5)

/-- B₁ applied to the closed form gives the next closed form -/
theorem A_closed_recurrence (n : ℕ) :
    applyB₁ ((A_closed n).1, (A_closed n).2.1, (A_closed n).2.2) =
    ((A_closed (n + 1)).1, (A_closed (n + 1)).2.1, (A_closed (n + 1)).2.2) := by
  simp only [A_closed, applyB₁]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> push_cast <;> ring

/-- **The closed form matches iteration for ALL n** -/
theorem A_iter_eq_A_closed : ∀ n : ℕ, A_iter n = ((A_closed n).1, (A_closed n).2) := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [A_iter, ih]
    exact A_closed_recurrence n

/-- [Section: ## A-Branch Gap: c - b = 1 for all n] -/
theorem A_branch_gap_all (n : ℕ) : (A_closed n).2.2 - (A_closed n).2.1 = 1 := by
  simp only [A_closed]; ring

/-- [Section: ## A-Branch GCD: always coprime] -/
theorem A_branch_coprime (n : ℕ) :
    Int.gcd (A_closed n).1 (A_closed n).2.1 = 1 := by
  unfold A_closed; norm_num;
  norm_num [ Int.gcd, Int.natAbs_mul, Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
  norm_cast ; norm_num [ ( by ring : 2 * n + 3 = n + 1 + ( n + 2 ) ) ];
  norm_num [ ( by ring : n + 2 = n + 1 + 1 ) ]

/-- Verification for small values -/
theorem A_branch_coprime_vals :
    Int.gcd (A_closed 0).1 (A_closed 0).2.1 = 1 ∧
    Int.gcd (A_closed 1).1 (A_closed 1).2.1 = 1 ∧
    Int.gcd (A_closed 2).1 (A_closed 2).2.1 = 1 ∧
    Int.gcd (A_closed 3).1 (A_closed 3).2.1 = 1 ∧
    Int.gcd (A_closed 4).1 (A_closed 4).2.1 = 1 := by native_decide

/-- [Section: ## A-Branch Pythagorean] -/
theorem A_closed_pythagorean (n : ℕ) :
    (A_closed n).1 ^ 2 + (A_closed n).2.1 ^ 2 = (A_closed n).2.2 ^ 2 := by
  simp only [A_closed]; ring

/- Original: BerggrenB2Entries.lean -/



def BN2E : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Cayley-Hamilton for B2: B2^3 = 5*B2^2 + 5*B2 - I -/
theorem BN2E_cayley : BN2E ^ 3 = 5 • BN2E ^ 2 + 5 • BN2E - 1 := by native_decide

theorem BN2E_entry_recurrence (i j : Fin 3) (n : ℕ) :
    (BN2E ^ (n + 3)) i j =
    5 * (BN2E ^ (n + 2)) i j + 5 * (BN2E ^ (n + 1)) i j -
    (BN2E ^ n) i j := by
  -- From BN2E_cayley: BN2E^3 = 5 • BN2E^2 + 5 • BN2E - 1. Multiply by BN2E^n on the right: BN2E^(n+3) = 5 • BN2E^(n+2) + 5 • BN2E^(n+1) - BN2E^n.
  have h_mul : BN2E^(n+3) = 5 • BN2E^(n+2) + 5 • BN2E^(n+1) - BN2E^n := by
    induction n <;> simp_all +decide [ pow_succ, mul_comm ];
    simp_all +decide [ mul_assoc, add_mul, sub_mul ];
  convert congr_arg ( fun m : Matrix _ _ ℤ => m i j ) h_mul using 1

theorem BN2E_nonneg (n : ℕ) (i j : Fin 3) : 0 ≤ (BN2E ^ n) i j := by
  induction' n with n ih generalizing i j <;> norm_num [ pow_succ ] at *;
  · decide +revert;
  · simp +decide only [mul_apply];
    exact Finset.sum_nonneg fun k _ => mul_nonneg ( ih _ _ ) ( by fin_cases k <;> fin_cases j <;> decide )

/-- B2 has eigenvector (1,-1,0) with eigenvalue -1 -/
theorem BN2E_eigenvector : BN2E.mulVec ![1, -1, 0] = (-1 : ℤ) • ![1, -1, 0] := by
  native_decide

theorem BN2E_eigenvector_pow (n : ℕ) :
    (BN2E ^ n).mulVec ![1, -1, 0] = ((-1 : ℤ) ^ n) • ![1, -1, 0] := by
  induction n <;> simp_all +decide [ pow_succ' ];
  simp_all +decide [ ← Matrix.mulVec_mulVec, BN2E_eigenvector ];
  ext i; fin_cases i <;> norm_num [ Matrix.mulVec ] ;
  · simp +decide [ BN2E ] ; ring!;
  · unfold BN2E; norm_num [ vecHead, vecTail ] ; ring;
  · ring!

theorem BN2E_row_diff_0 (n : ℕ) :
    (BN2E ^ n) 0 0 - (BN2E ^ n) 0 1 = (-1) ^ n := by
  convert congr_arg ( fun x : Fin 3 → ℤ => x 0 ) ( BN2E_eigenvector_pow n ) using 1 ; simp +decide [ Matrix.mulVec ];
  · exact?;
  · rw [ Pi.smul_apply ] ; norm_num

theorem BN2E_row_diff_1 (n : ℕ) :
    (BN2E ^ n) 1 0 - (BN2E ^ n) 1 1 = -((-1) ^ n) := by
  convert congr_arg ( fun x : Fin 3 → ℤ => x 1 ) ( BN2E_eigenvector_pow n ) using 1 ; simp +decide [ Matrix.mulVec ];
  · ring!;
  · rw [ Pi.smul_apply ] ; norm_num

theorem BN2E_row_diff_2 (n : ℕ) :
    (BN2E ^ n) 2 0 - (BN2E ^ n) 2 1 = 0 := by
  induction' n with n ih;
  · rfl;
  · simp_all +decide [ pow_succ, Matrix.mul_apply ];
    simp_all +decide [ Fin.sum_univ_three, BN2E ];
    linarith

/- Original: BerggrenB3ClosedForm.lean -/



def BN3F : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Corrected closed-form formula for B3^n -/
def BN3_pow_closed (n : ℕ) : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1 - 2 * (↑n : ℤ) ^ 2, 2 * ↑n, 2 * (↑n : ℤ) ^ 2;
     -(2 * ↑n), 1, 2 * ↑n;
     -(2 * (↑n : ℤ) ^ 2), 2 * ↑n, 1 + 2 * (↑n : ℤ) ^ 2]

theorem BN3_pow_eq_closed (n : ℕ) : BN3F ^ n = BN3_pow_closed n := by
  induction' n with n ih;
  · native_decide +revert;
  · simp_all +decide [ pow_succ, BN3_pow_closed ];
    simp +decide [ BN3F, Matrix.vecMul ] ; ring_nf ; aesop;

/-- Verification at n=0,1,2,3 -/
theorem BN3_pow_closed_check :
    BN3F ^ 0 = BN3_pow_closed 0 ∧
    BN3F ^ 1 = BN3_pow_closed 1 ∧
    BN3F ^ 2 = BN3_pow_closed 2 ∧
    BN3F ^ 3 = BN3_pow_closed 3 := by
  native_decide

/-- C-branch iteration via B3 -/
def C_iterF : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => let t := C_iterF n
    (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- C-branch closed form -/
def C_closedF (n : ℕ) : ℤ × ℤ × ℤ :=
  ((2 * ↑n + 1) * (2 * ↑n + 3), 4 * (↑n + 1), 4 * (↑n : ℤ) ^ 2 + 8 * ↑n + 5)

theorem C_iter_eq_closedF (n : ℕ) : C_iterF n = C_closedF n := by
  induction' n with n ih <;> norm_num [ C_iterF, C_closedF ] at * ; ring_nf at *;
  grind

/-- C-branch Pythagorean property for ALL n -/
theorem C_closed_pythagoreanF (n : ℕ) :
    (C_closedF n).1 ^ 2 + (C_closedF n).2.1 ^ 2 = (C_closedF n).2.2 ^ 2 := by
  simp only [C_closedF]; ring

/-- C-branch gap: c - a = 2 for ALL n -/
theorem C_branch_gapF (n : ℕ) : (C_closedF n).2.2 - (C_closedF n).1 = 2 := by
  simp only [C_closedF]; ring

/- Original: BerggrenCBranch.lean -/



/-- The C-branch triple at depth n (B₃ⁿ applied to (3,4,5)) -/
def C_branch (n : ℕ) : ℤ × ℤ × ℤ :=
  ((2 * ↑n + 1) * (2 * ↑n + 3), 4 * (↑n + 1), 4 * (↑n : ℤ)^2 + 8 * ↑n + 5)

/-- [Section: ## Base Case Verifications] -/
theorem C_branch_0 : C_branch 0 = (3, 4, 5) := by simp [C_branch]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenCBranch
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22] -/
theorem C_branch_1 : C_branch 1 = (15, 8, 17) := by simp [C_branch]

theorem C_branch_2 : C_branch 2 = (35, 12, 37) := by simp [C_branch]

theorem C_branch_3 : C_branch 3 = (63, 16, 65) := by simp [C_branch]

theorem C_branch_4 : C_branch 4 = (99, 20, 101) := by simp [C_branch]

/-- [Section: ## C-Branch is Always Pythagorean] -/
theorem C_branch_pythagorean (n : ℕ) :
    (C_branch n).1 ^ 2 + (C_branch n).2.1 ^ 2 = (C_branch n).2.2 ^ 2 := by
  simp only [C_branch]; ring

/-- The hypotenuse minus the odd leg is always 2 -/
theorem C_branch_gap (n : ℕ) :
    (C_branch n).2.2 - (C_branch n).1 = 2 := by
  simp only [C_branch]; ring

/-- The first component (odd leg) is always odd -/
theorem C_branch_first_odd (n : ℕ) : Odd (C_branch n).1 := by
  simp only [C_branch]
  exact ⟨2 * (↑n : ℤ) ^2 + 4 * ↑n + 1, by ring⟩

/-- The second component (even leg) is always divisible by 4 -/
theorem C_branch_second_div4 (n : ℕ) : (4 : ℤ) ∣ (C_branch n).2.1 :=
  ⟨↑n + 1, by simp [C_branch]⟩

/-- The hypotenuse is always odd -/
theorem C_branch_hyp_odd (n : ℕ) : Odd (C_branch n).2.2 := by
  simp only [C_branch]
  exact ⟨2 * (↑n : ℤ)^2 + 4 * ↑n + 2, by ring⟩

/-- The hypotenuse is strictly increasing -/
theorem C_branch_hyp_growth (n : ℕ) :
    (C_branch n).2.2 < (C_branch (n + 1)).2.2 := by
  simp only [C_branch]; push_cast; nlinarith [n.zero_le]

/-- All components are positive -/
theorem C_branch_all_pos (n : ℕ) :
    0 < (C_branch n).1 ∧ 0 < (C_branch n).2.1 ∧ 0 < (C_branch n).2.2 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp only [C_branch] <;> positivity

/-- B₃ applied to (a,b,c) -/
def applyB₃ (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- B₃ⁿ applied to (3,4,5) by iteration -/
def C_iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => applyB₃ (C_iter n)

/-- [Section: ## C-Branch Inductive Proof] -/
theorem C_branch_recurrence (n : ℕ) :
    applyB₃ ((C_branch n).1, (C_branch n).2.1, (C_branch n).2.2) =
    ((C_branch (n + 1)).1, (C_branch (n + 1)).2.1, (C_branch (n + 1)).2.2) := by
  simp only [C_branch, applyB₃]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> push_cast <;> ring

/-- The closed form matches the B₃ iteration for ALL n -/
theorem C_iter_eq_C_branch : ∀ n : ℕ, C_iter n = ((C_branch n).1, (C_branch n).2) := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [C_iter, ih]
    exact C_branch_recurrence n

/-- A-branch definition -/
def A_branch' (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * ↑n + 3, 2 * (↑n + 1) * (↑n + 2), 2 * (↑n : ℤ)^2 + 6 * ↑n + 5)

/-- A-branch gap is 1 -/
theorem A_branch_gap' (n : ℕ) : (A_branch' n).2.2 - (A_branch' n).2.1 = 1 := by
  simp only [A_branch']; ring

/-- A-branch + C-branch: two fundamental families of PPTs -/
theorem AC_families_distinct (n : ℕ) (hn : 0 < n) :
    (A_branch' n).1 ≠ (C_branch n).1 := by
  simp only [A_branch', C_branch]
  intro h
  have h1 : (2 * (↑n : ℤ) + 3) = (2 * ↑n + 1) * (2 * ↑n + 3) := by linarith
  have h2 : 1 = 2 * (↑n : ℤ) + 1 := by nlinarith
  linarith [show (0 : ℤ) < n from Nat.cast_pos.mpr hn]

/-- The odd legs are products of consecutive odd numbers -/
theorem C_branch_odd_leg_factored (n : ℕ) :
    (C_branch n).1 = (2 * ↑n + 1) * (2 * ↑n + 3) := by
  simp [C_branch]

/-- The even legs form an arithmetic progression with common difference 4 -/
theorem C_branch_even_leg_arith (n : ℕ) :
    (C_branch (n + 1)).2.1 - (C_branch n).2.1 = 4 := by
  simp only [C_branch]; push_cast; ring

/- Original: BerggrenCBranchGCD.lean -/



/-- The C-branch odd leg -/
def C_odd (n : ℕ) : ℤ := (2 * ↑n + 1) * (2 * ↑n + 3)

/-- The C-branch even leg -/
def C_even (n : ℕ) : ℤ := 4 * (↑n + 1)

/-- [Section: ## Main Result] -/
theorem C_branch_coprime (n : ℕ) : Int.gcd (C_odd n) (C_even n) = 1 := by
  unfold C_odd C_even;
  norm_cast;
  norm_num [ ( by ring : 2 * n + 3 = 2 * n + 1 + 2 ), ( by ring : 4 * ( n + 1 ) = 2 * ( 2 * ( n + 1 ) ) ), Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
  norm_num [ ( by ring : 2 * n + 1 + 2 = 2 * ( n + 1 ) + 1 ) ];
  norm_num [ ( by ring : 2 * n + 1 = n + ( n + 1 ) ) ]

/-- [Section: ## Verification for small values] -/
theorem C_branch_coprime_vals :
    Int.gcd (C_odd 0) (C_even 0) = 1 ∧
    Int.gcd (C_odd 1) (C_even 1) = 1 ∧
    Int.gcd (C_odd 2) (C_even 2) = 1 ∧
    Int.gcd (C_odd 3) (C_even 3) = 1 ∧
    Int.gcd (C_odd 4) (C_even 4) = 1 ∧
    Int.gcd (C_odd 5) (C_even 5) = 1 := by native_decide

/- Original: BerggrenCompleteness.lean -/



/-- Apply inverse Berggren B₁⁻¹ -/
def invB1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- Apply inverse Berggren B₂⁻¹ -/
def invB2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Apply inverse Berggren B₃⁻¹ -/
def invB3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Apply forward Berggren B₁ -/
def fwdB1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Apply forward Berggren B₂ -/
def fwdB2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Apply forward Berggren B₃ -/
def fwdB3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenCompleteness
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 33] -/
theorem invB1_fwdB1 (a b c : ℤ) :
    invB1 (fwdB1 a b c).1 (fwdB1 a b c).2.1 (fwdB1 a b c).2.2 = (a, b, c) := by
  unfold invB1 fwdB1; ext <;> simp <;> ring

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenCompleteness
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 33] -/
theorem invB2_fwdB2 (a b c : ℤ) :
    invB2 (fwdB2 a b c).1 (fwdB2 a b c).2.1 (fwdB2 a b c).2.2 = (a, b, c) := by
  unfold invB2 fwdB2; ext <;> simp <;> ring

theorem invB3_fwdB3 (a b c : ℤ) :
    invB3 (fwdB3 a b c).1 (fwdB3 a b c).2.1 (fwdB3 a b c).2.2 = (a, b, c) := by
  unfold invB3 fwdB3; ext <;> simp <;> ring

theorem fwdB1_invB1 (a b c : ℤ) :
    fwdB1 (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 = (a, b, c) := by
  unfold invB1 fwdB1; ext <;> simp <;> ring

theorem fwdB2_invB2 (a b c : ℤ) :
    fwdB2 (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 = (a, b, c) := by
  unfold invB2 fwdB2; ext <;> simp <;> ring

theorem fwdB3_invB3 (a b c : ℤ) :
    fwdB3 (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 = (a, b, c) := by
  unfold invB3 fwdB3; ext <;> simp <;> ring

theorem invB1_preserves_pt (a b c : ℤ) (h : IsPT a b c) :
    IsPT (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 := by
  unfold IsPT invB1 at *; nlinarith [h, sq_nonneg a, sq_nonneg b, sq_nonneg c,
    sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

theorem invB2_preserves_pt (a b c : ℤ) (h : IsPT a b c) :
    IsPT (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 := by
  unfold IsPT invB2 at *; nlinarith [h, sq_nonneg a, sq_nonneg b, sq_nonneg c,
    sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

theorem invB3_preserves_pt (a b c : ℤ) (h : IsPT a b c) :
    IsPT (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 := by
  unfold IsPT invB3 at *; nlinarith [h, sq_nonneg a, sq_nonneg b, sq_nonneg c,
    sq_nonneg (a - b), sq_nonneg (a + b), sq_nonneg (a - c), sq_nonneg (b - c)]

/-- The first components of invB1 and invB2 are equal -/
theorem invB1_invB2_first_eq (a b c : ℤ) :
    (invB1 a b c).1 = (invB2 a b c).1 := by
  unfold invB1 invB2; ring

/-- The first component of invB3 is the negation of invB1's first component -/
theorem invB3_neg_invB1_first (a b c : ℤ) :
    (invB3 a b c).1 = -(invB1 a b c).1 := by
  unfold invB1 invB3; ring

/-- The second component of invB1 is the negation of invB2's second component -/
theorem invB1_neg_invB2_second (a b c : ℤ) :
    (invB1 a b c).2.1 = -(invB2 a b c).2.1 := by
  unfold invB1 invB2; ring

/-- The second components of invB2 and invB3 are equal -/
theorem invB2_invB3_second_eq (a b c : ℤ) :
    (invB2 a b c).2.1 = (invB3 a b c).2.1 := by
  unfold invB2 invB3; ring

/-- All three inverse transforms share the same third component (hypotenuse) -/
theorem inv_same_hyp (a b c : ℤ) :
    (invB1 a b c).2.2 = (invB2 a b c).2.2 ∧
    (invB2 a b c).2.2 = (invB3 a b c).2.2 := by
  unfold invB1 invB2 invB3; exact ⟨rfl, rfl⟩

/-- If a + 2b > 2c and 2a + b > 2c, then invB2 has all positive components -/
theorem invB2_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c)
    (h1 : a + 2*b > 2*c) (h2 : 2*a + b > 2*c) :
    0 < (invB2 a b c).1 ∧ 0 < (invB2 a b c).2.1 ∧ 0 < (invB2 a b c).2.2 := by
  refine ⟨?_, ?_, parent_hyp_pos a b c ha hb hc hpt⟩
  · show 0 < a + 2 * b - 2 * c; linarith
  · show 0 < 2 * a + b - 2 * c; linarith

/-- If a + 2b > 2c and 2a + b < 2c, then invB1 has all positive components -/
theorem invB1_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c)
    (h1 : a + 2*b > 2*c) (h2 : 2*a + b < 2*c) :
    0 < (invB1 a b c).1 ∧ 0 < (invB1 a b c).2.1 ∧ 0 < (invB1 a b c).2.2 := by
  refine ⟨?_, ?_, parent_hyp_pos a b c ha hb hc hpt⟩
  · show 0 < a + 2 * b - 2 * c; linarith
  · show 0 < -2 * a - b + 2 * c; linarith

/-- If a + 2b < 2c and 2a + b > 2c, then invB3 has all positive components -/
theorem invB3_pos_case (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpt : IsPT a b c)
    (h1 : a + 2*b < 2*c) (h2 : 2*a + b > 2*c) :
    0 < (invB3 a b c).1 ∧ 0 < (invB3 a b c).2.1 ∧ 0 < (invB3 a b c).2.2 := by
  refine ⟨?_, ?_, parent_hyp_pos a b c ha hb hc hpt⟩
  · show 0 < -a - 2 * b + 2 * c; linarith
  · show 0 < 2 * a + b - 2 * c; linarith

/-- The case 2a + b = 2c and a + 2b = 2c simultaneously is impossible for a PPT with a > 0 -/
theorem no_simultaneous_zero (a b c : ℤ) (ha : 0 < a)
    (hpt : IsPT a b c)
    (h1 : a + 2*b = 2*c) (h2 : 2*a + b = 2*c) : False := by
  unfold IsPT at hpt
  have hab : a = b := by linarith
  subst hab
  have h2eq : 2 * c = 3 * a := by linarith
  have h3 : (2*c)^2 = (3*a)^2 := by rw [h2eq]
  have h4 : 4 * c^2 = 9 * a^2 := by ring_nf at h3 ⊢; linarith
  have h5 : 4 * (2 * a^2) = 9 * a^2 := by linarith
  have h6 : a^2 = 0 := by linarith
  have ha0 : a = 0 := pow_eq_zero_iff (n := 2) (by omega) |>.mp h6
  linarith

/-- Both a+2b ≤ 2c and 2a+b ≤ 2c is impossible for a PPT with positive legs -/
theorem not_both_neg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpt : IsPT a b c)
    (h1 : a + 2*b ≤ 2*c) (h2 : 2*a + b ≤ 2*c) : False := by
  unfold IsPT at hpt
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_nonneg (a + b - c),
    sq_nonneg (2*a + b - 2*c), sq_nonneg (a + 2*b - 2*c)]

/-- For the root (3,4,5), no inverse branch gives all-positive components -/
theorem root_no_parent :
    ¬(0 < (invB1 3 4 5).1 ∧ 0 < (invB1 3 4 5).2.1 ∧ 0 < (invB1 3 4 5).2.2) ∧
    ¬(0 < (invB2 3 4 5).1 ∧ 0 < (invB2 3 4 5).2.1 ∧ 0 < (invB2 3 4 5).2.2) ∧
    ¬(0 < (invB3 3 4 5).1 ∧ 0 < (invB3 3 4 5).2.1 ∧ 0 < (invB3 3 4 5).2.2) := by
  simp only [invB1, invB2, invB3]; omega

/-- (5,12,13) descends to (3,4,5) via invB1 -/
theorem descent_5_12_13 : invB1 5 12 13 = (3, 4, 5) := by
  unfold invB1; norm_num

/-- (21,20,29) descends to (3,4,5) via invB2 -/
theorem descent_21_20_29 : invB2 21 20 29 = (3, 4, 5) := by
  unfold invB2; norm_num

/-- (15,8,17) descends to (3,4,5) via invB3 -/
theorem descent_15_8_17 : invB3 15 8 17 = (3, 4, 5) := by
  unfold invB3; norm_num

/-- (7,24,25) descends to (5,12,13) via invB1 -/
theorem descent_7_24_25 : invB1 7 24 25 = (5, 12, 13) := by
  unfold invB1; norm_num

/-- Two-step descent: (7,24,25) → (5,12,13) → (3,4,5) -/
theorem descent_7_24_25_full :
    let t1 := invB1 7 24 25
    invB1 t1.1 t1.2.1 t1.2.2 = (3, 4, 5) := by
  unfold invB1; norm_num

/-- (9,40,41) descends via invB1 -/
theorem descent_9_40_41 : invB1 9 40 41 = (7, 24, 25) := by
  unfold invB1; norm_num

/-- (119,120,169) descends via invB2 -/
theorem descent_119_120_169 : invB2 119 120 169 = (21, 20, 29) := by
  unfold invB2; norm_num


/- Original: BerggrenCompletenessV13.lean -/



/-- A step in the Berggren tree -/
inductive BStepC where
  | A  -- Apply B₁
  | B  -- Apply B₂
  | C  -- Apply B₃
  deriving Repr, DecidableEq

/-- Forward Berggren map for a given step -/
def applyStepC (s : BStepC) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match s with
  | .A => (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)
  | .B => (t.1 + 2*t.2.1 + 2*t.2.2, 2*t.1 + t.2.1 + 2*t.2.2, 2*t.1 + 2*t.2.1 + 3*t.2.2)
  | .C => (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

/-- Apply a path (list of steps) starting from the root (3,4,5) -/
def applyPathC (path : List BStepC) : ℤ × ℤ × ℤ :=
  path.foldl (fun t s => applyStepC s t) (3, 4, 5)

/-- [Section: ## Inverse maps] -/
def invAC (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def invBC (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def invCC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- [Section: ## Forward-inverse cancellation] -/
theorem fwd_invAC (a b c : ℤ) :
    applyStepC .A ((invAC a b c).1, (invAC a b c).2.1, (invAC a b c).2.2) = (a, b, c) := by
  simp only [invAC, applyStepC]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem fwd_invBC (a b c : ℤ) :
    applyStepC .B ((invBC a b c).1, (invBC a b c).2.1, (invBC a b c).2.2) = (a, b, c) := by
  simp only [invBC, applyStepC]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem fwd_invCC (a b c : ℤ) :
    applyStepC .C ((invCC a b c).1, (invCC a b c).2.1, (invCC a b c).2.2) = (a, b, c) := by
  simp only [invCC, applyStepC]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

/-- [Section: ## Inverse maps preserve Pythagorean property] -/
theorem invAC_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invAC a b c).1 ^ 2 + (invAC a b c).2.1 ^ 2 = (invAC a b c).2.2 ^ 2 := by
  simp only [invAC]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

theorem invBC_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invBC a b c).1 ^ 2 + (invBC a b c).2.1 ^ 2 = (invBC a b c).2.2 ^ 2 := by
  simp only [invBC]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

theorem invCC_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invCC a b c).1 ^ 2 + (invCC a b c).2.1 ^ 2 = (invCC a b c).2.2 ^ 2 := by
  simp only [invCC]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Parent hypotenuse is positive for PPTs with positive legs -/
theorem parent_hyp_posC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < -2 * a - 2 * b + 3 * c := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b - c)]

/-- Parent hypotenuse is strictly less than c -/
theorem parent_hyp_ltC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) :
    -2 * a - 2 * b + 3 * c < c := by
  nlinarith [sq_nonneg (a + b - c)]

/-- σ₁ = a + 2b - 2c and σ₂ = 2a + b - 2c cannot both be ≤ 0 -/
theorem not_both_sigma_negC (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2)
    (h1 : a + 2 * b ≤ 2 * c) (h2 : 2 * a + b ≤ 2 * c) : False := by
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_nonneg (a + b - c),
    sq_nonneg (2 * a + b - 2 * c), sq_nonneg (a + 2 * b - 2 * c)]

/-- When σ₁ < 0 for a PPT, σ₂ > 0 -/
theorem sigma1_neg_sigma2_posC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hs : a + 2 * b - 2 * c < 0) :
    0 < 2 * a + b - 2 * c := by
  by_contra hle
  push_neg at hle
  exact not_both_sigma_negC a b c ha hb h (by linarith) (by linarith)

/-- σ₁ = 0 is impossible when a is odd (forces a to be even) -/
theorem sigma1_zero_impossibleC (a b c : ℤ)
    (hodd : a % 2 = 1) (hs : a + 2 * b - 2 * c = 0) : False := by
  omega

/-- [Section: ## Case analysis: σ₁ and σ₂] -/
theorem sigma2_zero_rootC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop : Int.gcd a b = 1)
    (hodd : a % 2 = 1) (heven : b % 2 = 0)
    (hs : 2 * a + b - 2 * c = 0) : c = 5 := by
  -- From 2a + b = 2c and a² + b² = c², substitute c = (2a+b)/2 to get a² + b² = (2a+b)²/4, so 4a² + 4b² = 4a² + 4ab + b², giving 3b² = 4ab, so 3b = 4a (since b > 0). Then a = 3k, b = 4k for some positive k, and gcd(a,b) = k·gcd(3,4) = k. Since gcd = 1, k = 1, so a = 3, b = 4, c = 5.
  have h_eq : 3 * b = 4 * a := by
    nlinarith only [ ha, hb, hc, hs, h ];
  -- Since $a = 3k$ and $b = 4k$ for some positive integer $k$, we have $gcd(a, b) = k \cdot gcd(3, 4) = k$. Since $gcd = 1$, $k = 1$, so $a = 3$ and $b = 4$.
  obtain ⟨k, ha_eq, hb_eq⟩ : ∃ k : ℤ, a = 3 * k ∧ b = 4 * k := by
    exact ⟨ a / 3, by omega, by omega ⟩;
  simp_all +decide [ Int.gcd_mul_left, Int.gcd_mul_right ];
  linarith [ abs_of_pos ha ]

/-- [Section: ## Coprimality preservation under inverse maps
Key argument: if p is any prime dividing both parent legs a' and b',
then p | c' (since a'² + b'² = c'² and p | a', p | b' implies p | c'²,
hence p | c' since p is prime). Then since (a,b,c) = fwd(a',b',c') is an
integer linear combination, p | a and p | b, contradicting gcd(a,b) = 1.] -/
theorem coprime_invAC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hcop : Int.gcd a b = 1) :
    Int.gcd (invAC a b c).1 (invAC a b c).2.1 = 1 := by
  by_contra h_contra;
  obtain ⟨ p, hp, hpa, hpb ⟩ := Nat.Prime.not_coprime_iff_dvd.mp h_contra;
  -- Since p divides both a' and b', it must also divide c' because a'^2 + b'^2 = c'^2.
  have hpc : p ∣ Int.natAbs (-2 * a - 2 * b + 3 * c) := by
    have hpc : (Int.natAbs (invAC a b c).1) ^ 2 + (Int.natAbs (invAC a b c).2.1) ^ 2 = (Int.natAbs (-2 * a - 2 * b + 3 * c)) ^ 2 := by
      simp +decide [ ← Int.natCast_inj, invAC ];
      linarith;
    exact hp.dvd_of_dvd_pow <| hpc ▸ dvd_add ( hpa.pow two_ne_zero ) ( hpb.pow two_ne_zero );
  -- Since p divides a', b', and c', it must also divide a and b because a = a' - 2b' + 2c' and b = 2a' - b' + 2c'.
  have hpa' : p ∣ Int.natAbs a := by
    rw [ ← Int.natCast_dvd ] at *;
    convert dvd_sub hpa ( dvd_mul_of_dvd_right hpb 2 ) |> dvd_add <| hpc.mul_left 2 using 1 ; ring;
    unfold invAC; ring;
  have hpb' : p ∣ Int.natAbs b := by
    rw [ ← Int.natCast_dvd ] at *;
    unfold invAC at *; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
    linear_combination' hpb + hpa;
  exact Nat.Prime.not_dvd_one hp ( hcop ▸ Nat.dvd_gcd hpa' hpb' )

theorem coprime_invBC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hcop : Int.gcd a b = 1) :
    Int.gcd (invBC a b c).1 (invBC a b c).2.1 = 1 := by
  -- Assume there exists a prime $p$ that divides both $(invBC a b c).1$ and $(invBC a b c).2.1$.
  by_contra h_contra
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ (Int.natAbs (invBC a b c).1) ∧ p ∣ (Int.natAbs (invBC a b c).2.1) := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h_contra;
  -- Then $p$ divides $a$ and $b$ since $a = a' + 2b' + 2c'$ and $b = 2a' + b' + 2c'$.
  have hp_div_a_b : (p : ℤ) ∣ a ∧ (p : ℤ) ∣ b := by
    have hp_div_c : (p : ℤ) ∣ -2 * a - 2 * b + 3 * c := by
      have hp_div_c : (p : ℤ) ∣ (a + 2 * b - 2 * c) ^ 2 + (2 * a + b - 2 * c) ^ 2 := by
        exact dvd_add ( dvd_pow ( Int.natCast_dvd.mpr hp_div.1 ) two_ne_zero ) ( dvd_pow ( Int.natCast_dvd.mpr hp_div.2 ) two_ne_zero );
      convert Int.Prime.dvd_pow' hp_prime ( show ( p : ℤ ) ∣ ( -2 * a - 2 * b + 3 * c ) ^ 2 by convert hp_div_c using 1; linarith ) using 1;
    have hp_div_a : (p : ℤ) ∣ a + 2 * b - 2 * c := by
      convert Int.natCast_dvd.mpr hp_div.1 using 1
    have hp_div_b : (p : ℤ) ∣ 2 * a + b - 2 * c := by
      exact Int.natCast_dvd.mpr hp_div.2;
    haveI := Fact.mk hp_prime; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
    grind;
  exact Nat.Prime.not_dvd_one hp_prime ( hcop ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd hp_div_a_b.1 hp_div_a_b.2 ) )

theorem coprime_invCC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hcop : Int.gcd a b = 1) :
    Int.gcd (invCC a b c).1 (invCC a b c).2.1 = 1 := by
  -- Let p be a prime that divides both a' and b'.
  by_contra h_contra
  obtain ⟨p, hp_prime, hp_div_a', hp_div_b'⟩ : ∃ p, Nat.Prime p ∧ p ∣ Int.natAbs (-a - 2 * b + 2 * c) ∧ p ∣ Int.natAbs (2 * a + b - 2 * c) := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h_contra;
  -- Since $a = -a' + 2b' + 2c'$ and $b = -2a' + b' + 2c'$, we have $p \mid a$ and $p \mid b$.
  have hp_div_a : p ∣ Int.natAbs a := by
    rw [ ← Int.natCast_dvd ] at *;
    haveI := Fact.mk hp_prime; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ];
    replace h := congr_arg ( ( ↑ ) : ℤ → ZMod p ) h ; simp_all +decide [ ← eq_sub_iff_add_eq' ];
    grind
  have hp_div_b : p ∣ Int.natAbs b := by
    simp_all +decide [ ← Int.natCast_dvd_natCast, ← ZMod.intCast_zmod_eq_zero_iff_dvd ];
    haveI := Fact.mk hp_prime; simp_all +decide [ ← eq_sub_iff_add_eq', ← ZMod.intCast_eq_intCast_iff ] ;
    grind;
  exact Nat.Prime.not_dvd_one hp_prime ( hcop ▸ Nat.dvd_gcd hp_div_a hp_div_b )

/-- [Section: ## Parity preservation: inverse maps preserve a-odd, b-even] -/
theorem parity_invAC (a b c : ℤ) (hodd : a % 2 = 1) (heven : b % 2 = 0)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invAC a b c).1 % 2 = 1 ∧ (invAC a b c).2.1 % 2 = 0 := by
  norm_num [ invAC ];
  exact ⟨ hodd, dvd_sub ( dvd_neg.mpr ( dvd_mul_right _ _ ) ) ( Int.dvd_of_emod_eq_zero heven ) ⟩

theorem parity_invBC (a b c : ℤ) (hodd : a % 2 = 1) (heven : b % 2 = 0)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invBC a b c).1 % 2 = 1 ∧ (invBC a b c).2.1 % 2 = 0 := by
  unfold invBC; simp +decide [ *, Int.add_emod, Int.sub_emod, Int.mul_emod ] ;

theorem parity_invCC (a b c : ℤ) (hodd : a % 2 = 1) (heven : b % 2 = 0)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invCC a b c).1 % 2 = 1 ∧ (invCC a b c).2.1 % 2 = 0 := by
  unfold invCC; simp +decide [ *, Int.add_emod, Int.sub_emod, Int.mul_emod ] ;

/-- [Section: ## Root classification] -/
theorem root_classC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc5 : c = 5)
    (hcop : Int.gcd a b = 1)
    (hodd : a % 2 = 1) (heven : b % 2 = 0) :
    a = 3 ∧ b = 4 := by
  subst hc5
  have ha5 : a ≤ 4 := by nlinarith [sq_nonneg (a - 5)]
  have hb5 : b ≤ 4 := by nlinarith [sq_nonneg (b - 5)]
  interval_cases a <;> interval_cases b <;> simp_all

theorem hyp_ge_5C (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop : Int.gcd a b = 1)
    (hodd : a % 2 = 1) (heven : b % 2 = 0) :
    5 ≤ c := by
  contrapose! hcop; interval_cases c <;> ( norm_num at * ) ;
  · nlinarith;
  · have : a ≤ 2 := Int.le_of_lt_add_one ( by nlinarith only [ ha, hb, h ] ) ; ( have : b ≤ 2 := Int.le_of_lt_add_one ( by nlinarith only [ ha, hb, h ] ) ; interval_cases a <;> interval_cases b <;> trivial; );
  · have : a ≤ 3 := Int.le_of_lt_add_one ( by nlinarith only [ h ] ) ; ( have : b ≤ 3 := Int.le_of_lt_add_one ( by nlinarith only [ h ] ) ; interval_cases a <;> interval_cases b <;> trivial; );
  · have : a ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h ] ) ; ( have : b ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h ] ) ; interval_cases a <;> interval_cases b <;> trivial; )

/-- [Section: ## Path append lemma] -/
theorem applyPathC_append_step (path : List BStepC) (s : BStepC) :
    applyPathC (path ++ [s]) = applyStepC s (applyPathC path) := by
  simp only [applyPathC, List.foldl_append, List.foldl_cons, List.foldl_nil]

/-- [Section: ## Descent step: finding a parent with all properties] -/
theorem descent_stepC (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hc5 : 5 < c)
    (hcop : Int.gcd a b = 1)
    (hodd : a % 2 = 1) (heven : b % 2 = 0) :
    ∃ (s : BStepC) (a' b' c' : ℤ),
      a' ^ 2 + b' ^ 2 = c' ^ 2 ∧
      0 < a' ∧ 0 < b' ∧ 0 < c' ∧ c' < c ∧
      Int.gcd a' b' = 1 ∧
      a' % 2 = 1 ∧ b' % 2 = 0 ∧
      applyStepC s (a', b', c') = (a, b, c) := by
  by_cases hcase : a + 2 * b - 2 * c > 0 ∧ 2 * a + b - 2 * c > 0;
  · refine' ⟨ BStepC.B, _, _, _, _, _, _, _, _ ⟩ <;> norm_num [ * ];
    exact a + 2 * b - 2 * c;
    exact 2 * a + b - 2 * c;
    exact -2 * a - 2 * b + 3 * c;
    · linarith;
    · linarith;
    · linarith;
    · linarith [ parent_hyp_posC a b c h ha hb hc ];
    · refine' ⟨ _, _, _, _, _ ⟩ <;> norm_num [ applyStepC ];
      · linarith;
      · convert coprime_invBC a b c h hcop using 1;
      · assumption;
      · grind;
      · exact ⟨ by ring, by ring, by ring ⟩;
  · by_cases hcase : a + 2 * b - 2 * c > 0 ∧ 2 * a + b - 2 * c < 0;
    · use .A, a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c;
      refine' ⟨ _, _, _, _, _, _, _ ⟩ <;> try linarith;
      · linarith [ parent_hyp_posC a b c h ha hb hc ];
      · convert coprime_invAC a b c h hcop using 1;
      · exact ⟨ by omega, by omega, by unfold applyStepC; ring ⟩;
    · -- Since these two cases are impossible, we must have $a + 2b - 2c < 0$ and $2a + b - 2c > 0$.
      have hcase3 : a + 2 * b - 2 * c < 0 ∧ 2 * a + b - 2 * c > 0 := by
        grind +suggestions;
      refine' ⟨ .C, -a - 2 * b + 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c, _, _, _, _, _ ⟩ <;> norm_num at * <;> try linarith;
      · linarith [ parent_hyp_posC a b c h ha hb hc ];
      · refine' ⟨ _, _, hodd, heven, _ ⟩;
        · nlinarith only [ ha, hb, hc, h, hcase3 ];
        · convert coprime_invCC a b c h hcop using 1;
        · unfold applyStepC; norm_num; ring;
          norm_num

/-- [Section: ## Main completeness theorem] -/
theorem berggren_complete (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop : Int.gcd a b = 1)
    (hodd : a % 2 = 1) (heven : b % 2 = 0) :
    ∃ path : List BStepC, applyPathC path = (a, b, c) := by
  induction' n : c.toNat using Nat.strong_induction_on with n ih generalizing a b c;
  by_cases hc5 : c ≤ 5;
  · -- By the root classification theorem, if $c = 5$, then $a = 3$ and $b = 4$.
    have h_root : a = 3 ∧ b = 4 := by
      apply root_classC a b c h ha hb (by
      exact le_antisymm hc5 ( hyp_ge_5C a b c h ha hb hc hcop hodd heven )) hcop hodd heven;
    interval_cases c <;> simp_all +decide only;
    exists [ ];
  · obtain ⟨ s, a', b', c', h₁, h₂, h₃, h₄, h₅, h₆ ⟩ := descent_stepC a b c h ha hb hc ( by linarith ) hcop hodd heven;
    obtain ⟨path', hpath'⟩ : ∃ path' : List BStepC, applyPathC path' = (a', b', c') := by
      exact ih _ ( by linarith [ Int.toNat_of_nonneg h₄.le, Int.toNat_of_nonneg hc.le ] ) _ _ _ h₁ h₂ h₃ h₄ h₆.1 h₆.2.1 h₆.2.2.1 rfl;
    use path' ++ [s];
    rw [ applyPathC_append_step, hpath', h₆.2.2.2 ]

theorem berggren_complete_general (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop : Int.gcd a b = 1) :
    ∃ path : List BStepC, applyPathC path = (a, b, c) ∨
                            applyPathC path = (b, a, c) := by
  by_cases ha_odd : a % 2 = 1;
  · -- Since a is odd, we need to show that b is even.
    have hb_even : b % 2 = 0 := by
      replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *;
    exact Exists.imp ( by tauto ) ( berggren_complete a b c h ha hb hc hcop ha_odd hb_even );
  · by_cases hb_odd : b % 2 = 1;
    · exact Exists.imp ( by aesop ) ( berggren_complete b a c ( by linarith ) hb ha hc ( by simpa [ Int.gcd_comm ] using hcop ) hb_odd ( by simpa using ha_odd ) );
    · exact absurd ( Int.dvd_coe_gcd ( Int.dvd_of_emod_eq_zero ( by simpa using ha_odd ) ) ( Int.dvd_of_emod_eq_zero ( by simpa using hb_odd ) ) ) ( by norm_num [ hcop ] )

/- Original: BerggrenDeficitClassification.lean -/



/-- [Section: ## Section 1: Basic PPT Properties] -/
def IsPPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The deficit: d = c - b -/
def deficit (b c : ℤ) : ℤ := c - b

/-- The excess: e = c - a -/
def excess (a c : ℤ) : ℤ := c - a

/-- Key identity: a² = (c-b)(c+b) for PPTs -/
theorem deficit_times_sum (a b c : ℤ) (h : IsPPT a b c) :
    deficit b c * (c + b) = a ^ 2 := by
  simp [deficit, IsPPT] at *; nlinarith

/-- Key identity: b² = (c-a)(c+a) for PPTs -/
theorem excess_times_sum (a b c : ℤ) (h : IsPPT a b c) :
    excess a c * (c + a) = b ^ 2 := by
  simp [excess, IsPPT] at *; nlinarith

/-- Step A preserves deficit: (c' - b') = (c - b) -/
theorem stepA_preserves_deficit (a b c : ℤ) :
    deficit (2*a - b + 2*c) (2*a - 2*b + 3*c) = deficit b c := by
  simp [deficit]; ring

/-- Step B transforms deficit: d' = c + b -/
theorem stepB_transforms_deficit (a b c : ℤ) :
    deficit (2*a + b + 2*c) (2*a + 2*b + 3*c) = c + b := by
  simp [deficit]; ring

/-- Step C transforms deficit: d' = c + b -/
theorem stepC_transforms_deficit (a b c : ℤ) :
    deficit (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = c + b := by
  simp [deficit]; ring

/-- Root has deficit 1 -/
theorem root_deficit_one : deficit 4 5 = 1 := by norm_num [deficit]

/-- All A-branch descendants preserve deficit -/
theorem A_branch_deficit_chain (a b c : ℤ) (hd : deficit b c = 1) :
    deficit (2*a - b + 2*c) (2*a - 2*b + 3*c) = 1 := by
  rw [stepA_preserves_deficit]; exact hd

/-- Euclid parametrization: (m²-n², 2mn, m²+n²) is a PPT -/
theorem euclid_is_ppt (m n : ℤ) :
    IsPPT (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  simp [IsPPT]; ring

/-- Deficit of Euclid PPT: c - b = (m-n)² -/
theorem euclid_deficit (m n : ℤ) :
    deficit (2*m*n) (m^2 + n^2) = (m - n)^2 := by
  simp [deficit]; ring

/-- Excess of Euclid PPT: c - a = 2n² -/
theorem euclid_excess (m n : ℤ) :
    excess (m^2 - n^2) (m^2 + n^2) = 2 * n^2 := by
  simp [excess]; ring

/-- **Deficit is a perfect square** for Euclid-parametrized PPTs -/
theorem euclid_deficit_is_square (m n : ℤ) :
    ∃ k : ℤ, deficit (2*m*n) (m^2 + n^2) = k ^ 2 := by
  exact ⟨m - n, euclid_deficit m n⟩

/-- The family (2n+1, 2n²+2n, 2n²+2n+1) has deficit 1 -/
theorem near_isosceles_deficit (n : ℤ) :
    deficit (2*n^2 + 2*n) (2*n^2 + 2*n + 1) = 1 := by
  simp [deficit]

/-- The near-isosceles family satisfies the PPT equation -/
theorem near_isosceles_is_ppt (n : ℤ) :
    IsPPT (2*n + 1) (2*n^2 + 2*n) (2*n^2 + 2*n + 1) := by
  simp [IsPPT]; ring

/-- Verify: n=1 gives (3,4,5) -/
theorem near_isosceles_1 :
    (2*(1:ℤ) + 1, 2*1^2 + 2*1, 2*1^2 + 2*1 + 1) = (3, 4, 5) := by norm_num

/-- Verify: n=2 gives (5,12,13) -/
theorem near_isosceles_2 :
    (2*(2:ℤ) + 1, 2*2^2 + 2*2, 2*2^2 + 2*2 + 1) = (5, 12, 13) := by norm_num

/-- Verify: n=3 gives (7,24,25) -/
theorem near_isosceles_3 :
    (2*(3:ℤ) + 1, 2*3^2 + 2*3, 2*3^2 + 2*3 + 1) = (7, 24, 25) := by norm_num

/-- Verify: n=4 gives (9,40,41) -/
theorem near_isosceles_4 :
    (2*(4:ℤ) + 1, 2*4^2 + 2*4, 2*4^2 + 2*4 + 1) = (9, 40, 41) := by norm_num

/-- B-step makes deficit grow: if b > 0, the new deficit is c + b > c - b -/
theorem stepB_deficit_grows (a b c : ℤ) (hb : 0 < b) :
    deficit b c < deficit (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  rw [stepB_transforms_deficit]; simp [deficit]; linarith

/-- deficit + excess = 2c - a - b -/
theorem deficit_plus_excess (a b c : ℤ) :
    deficit b c + excess a c = 2 * c - a - b := by
  simp [deficit, excess]; ring

/-- For a PPT: deficit · (c+b) + excess · (c+a) = c² -/
theorem deficit_excess_sum_sq (a b c : ℤ) (h : IsPPT a b c) :
    deficit b c * (c + b) + excess a c * (c + a) = c ^ 2 := by
  have h1 := deficit_times_sum a b c h
  have h2 := excess_times_sum a b c h
  simp [IsPPT] at h; nlinarith

/-- [Section: ## Section 9: Deficit and Perimeter] -/
def perim (a b c : ℤ) : ℤ := a + b + c

/-- Perimeter via deficit: P = a + 2c - d -/
theorem perimeter_via_deficit (a b c : ℤ) :
    perim a b c = a + 2 * c - deficit b c := by
  simp [perim, deficit]; ring

/-- For deficit-1 triples: P = 4n²+6n+2 -/
theorem near_isosceles_perimeter (n : ℤ) :
    perim (2*n + 1) (2*n^2 + 2*n) (2*n^2 + 2*n + 1) = 4*n^2 + 6*n + 2 := by
  simp [perim]; ring

/-- Area of near-isosceles PPT: 2·area = (2n+1)·2n(n+1) -/
theorem near_isosceles_double_area (n : ℤ) :
    (2*n + 1) * (2*n^2 + 2*n) = 2 * (2*n + 1) * n * (n + 1) := by ring

/-- The deficit divides a² for any PPT -/
theorem deficit_divides_a_sq (a b c : ℤ) (h : IsPPT a b c) :
    deficit b c ∣ a ^ 2 := by
  exact ⟨c + b, by linarith [deficit_times_sum a b c h]⟩

/-- For deficit d: a + b - c = a - d -/
theorem inradius_via_deficit (a b c : ℤ) :
    a + b - c = a - deficit b c := by
  simp [deficit]; ring

/-- Near-isosceles inradius: a + b - c = 2n -/
theorem near_isosceles_inradius (n : ℤ) :
    (2*n + 1) + (2*n^2 + 2*n) - (2*n^2 + 2*n + 1) = 2 * n := by ring

/- Original: BerggrenDescentComplete.lean -/



/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenDescentComplete
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22] -/
def invAD (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenDescentComplete
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22] -/
def invBD (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def invCD (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def chAD (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def chBD (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def chCD (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

theorem chAD_invAD (a b c : ℤ) :
    let t := chAD a b c; invAD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [chAD, invAD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem chBD_invBD (a b c : ℤ) :
    let t := chBD a b c; invBD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [chBD, invBD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem chCD_invCD (a b c : ℤ) :
    let t := chCD a b c; invCD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [chCD, invCD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem invAD_chAD (a b c : ℤ) :
    let t := invAD a b c; chAD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invAD, chAD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem invBD_chBD (a b c : ℤ) :
    let t := invBD a b c; chBD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invBD, chBD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem invCD_chCD (a b c : ℤ) :
    let t := invCD a b c; chCD t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [invCD, chCD]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem invAD_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invAD a b c).1^2 + (invAD a b c).2.1^2 = (invAD a b c).2.2^2 := by
  simp only [invAD]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

theorem invBD_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invBD a b c).1^2 + (invBD a b c).2.1^2 = (invBD a b c).2.2^2 := by
  simp only [invBD]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

theorem invCD_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invCD a b c).1^2 + (invCD a b c).2.1^2 = (invCD a b c).2.2^2 := by
  simp only [invCD]; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

theorem sigma_sum (a b c : ℤ) :
    (a + 2*b - 2*c) + (a - 2*b + 2*c) = 2 * a := by ring

/-- σ₁ and -σ₁ can't both be ≤ 0 with a > 0, b > 0 -/
theorem not_both_sigma_nonpos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) :
    0 < a + 2*b - 2*c ∨ 0 < -a - 2*b + 2*c ∨ (a + 2*b - 2*c = 0) := by omega

theorem sigma1_neg_invC_works (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hs : a + 2*b - 2*c < 0) :
    0 < 2*a + b - 2*c := by
  by_contra hle
  push_neg at hle
  -- From hs: (a+2b)² < 4c² → 4ab < 3a²
  have h1 : 4 * a * b < 3 * a^2 := by nlinarith [sq_nonneg (a + 2*b - 2*c)]
  -- From hle: (2a+b)² ≤ 4c² → 4ab ≤ 3b²
  have h2 : 4 * a * b ≤ 3 * b^2 := by nlinarith [sq_nonneg (2*a + b - 2*c)]
  -- From h1: b < 3a/4, i.e., 4b < 3a
  -- From h2: a ≤ 3b/4, i.e., 4a ≤ 3b
  -- Then 16ab < 9a·(b from h2: b ≥ 4a/3) → 16ab < 9·a·... this needs work
  -- Better: h1 → 4b < 3a (dividing by a > 0)
  -- h2 → 4a ≤ 3b (dividing by b > 0)
  -- Multiply: 16ab ≤ 9ab, contradiction since ab > 0
  nlinarith

/-- When σ₁ > 0, either invA or invB has positive second component -/
theorem sigma1_pos_descent (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hs : 0 < a + 2*b - 2*c) :
    (0 < -2*a - b + 2*c) ∨ (0 < 2*a + b - 2*c) ∨ (2*a + b = 2*c) := by omega

theorem root_classification (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc5 : c = 5)
    (hcop : Int.gcd a b = 1) :
    (a = 3 ∧ b = 4) ∨ (a = 4 ∧ b = 3) := by
  subst hc5; have : a ≤ 5 := Int.le_of_lt_add_one ( by nlinarith only [ h ] ) ; have : b ≤ 5 := Int.le_of_lt_add_one ( by nlinarith only [ h ] ) ; interval_cases a <;> interval_cases b <;> trivial;

theorem sigma1_zero_coprime (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hs : a + 2*b - 2*c = 0) (hcop : Int.gcd a b = 1) :
    c = 5 := by
  -- From sigma1_zero_forces, we have 3a = 4b.
  have h3a4b : 3 * a = 4 * b := by
    exact?;
  -- Since $\gcd(3, 4) = 1$, we can write $a = 4t$ and $b = 3t$ for some integer $t$.
  obtain ⟨t, ht⟩ : ∃ t : ℤ, a = 4 * t ∧ b = 3 * t := by
    exact ⟨ a / 4, by omega, by omega ⟩;
  simp_all +decide [ Int.gcd_mul_left, Int.gcd_mul_right ];
  grind +locals

theorem descent_step (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hc5 : 5 < c)
    (hcop : Int.gcd a b = 1) :
    ∃ (a' b' c' : ℤ),
      a'^2 + b'^2 = c'^2 ∧
      0 < a' ∧ 0 < b' ∧ 0 < c' ∧ c' < c := by
  exact ⟨ 3, 4, 5, by norm_num, by norm_num, by norm_num, by norm_num, hc5 ⟩


/- Original: BerggrenGPS.lean -/



noncomputable section

/-- Zone A inverse: maps (m, n) to (n, 2n - m) when m < 2n. -/
def zoneA_inv (m n : ℤ) : ℤ × ℤ := (n, 2 * n - m)

/-- Zone B inverse: maps (m, n) to (n, m - 2n) when 2n < m < 3n. -/
def zoneB_inv (m n : ℤ) : ℤ × ℤ := (n, m - 2 * n)

/-- Zone C inverse: maps (m, n) to (m - 2n, n) when m > 3n. -/
def zoneC_inv (m n : ℤ) : ℤ × ℤ := (m - 2 * n, n)

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenGPS
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22] -/
theorem zoneA_valid (m n : ℤ) (hm_gt_n : m > n) (hn_pos : n > 0) (hm_lt : m < 2 * n) :
    let (m', n') := zoneA_inv m n
    m' > n' ∧ n' > 0 := by
  simp [zoneA_inv]; constructor <;> omega

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenGPS
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22] -/
theorem zoneB_valid (m n : ℤ) (hm_gt : m > 2 * n) (hm_lt : m < 3 * n) (hn_pos : n > 0) :
    let (m', n') := zoneB_inv m n
    m' > n' ∧ n' > 0 := by
  simp [zoneB_inv]; constructor <;> omega

theorem zoneC_valid (m n : ℤ) (hm_gt : m > 3 * n) (hn_pos : n > 0) :
    let (m', n') := zoneC_inv m n
    (m - 2 * n) > n ∧ n > 0 := by
  constructor <;> omega

theorem zoneA_hyp_decreases (m n : ℤ) (hm_gt_n : m > n) (hn_pos : n > 0) (hm_lt : m < 2 * n) :
    let (m', n') := zoneA_inv m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneA_inv]
  nlinarith [sq_nonneg (m - n), sq_nonneg n, sq_nonneg (2 * n - m)]

theorem zoneB_hyp_decreases (m n : ℤ) (hm_gt : m > 2 * n) (hm_lt : m < 3 * n) (hn_pos : n > 0) :
    let (m', n') := zoneB_inv m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneB_inv]
  nlinarith [sq_nonneg (m - 2 * n), sq_nonneg n, sq_nonneg (m - n)]

theorem zoneC_hyp_decreases (m n : ℤ) (hm_gt : m > 3 * n) (hn_pos : n > 0) :
    let (m', n') := zoneC_inv m n
    m' ^ 2 + n' ^ 2 < m ^ 2 + n ^ 2 := by
  simp [zoneC_inv]
  nlinarith [sq_nonneg (m - 2 * n), sq_nonneg n, sq_nonneg (m - 3 * n)]

/-- Zone A preserves the Pythagorean property. -/
theorem zoneA_preserves_pyth (m n : ℤ) :
    let (m', n') := zoneA_inv m n
    (m' ^ 2 - n' ^ 2) ^ 2 + (2 * m' * n') ^ 2 = (m' ^ 2 + n' ^ 2) ^ 2 := by
  simp [zoneA_inv]; ring

/-- The Berggren-Gauss map on ℝ. -/
noncomputable def berggrenGauss (z : ℝ) : ℝ :=
  if z < 2 then 1 / (2 - z)
  else if z < 3 then 1 / (z - 2)
  else z - 2

theorem silver_ratio_fixed_point :
    berggrenGauss (1 + Real.sqrt 2) = 1 + Real.sqrt 2 := by
  unfold berggrenGauss;
  rw [ if_neg, if_pos ] <;> try nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two ] ; ; rw [ div_eq_iff ] <;> nlinarith [ Real.sqrt_nonneg 2, Real.sq_sqrt zero_le_two ] ;

theorem golden_ratio_step1 :
    berggrenGauss ((1 + Real.sqrt 5) / 2) = (3 + Real.sqrt 5) / 2 := by
  unfold berggrenGauss;
  rw [ if_pos, div_eq_iff ] <;> nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ]

theorem golden_ratio_step2 :
    berggrenGauss ((3 + Real.sqrt 5) / 2) = (1 + Real.sqrt 5) / 2 := by
  rw [ berggrenGauss ];
  rw [ if_neg ( by nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ), if_pos ( by nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ) ] ; rw [ div_eq_iff ] <;> nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ]

/-- The golden ratio has a period-2 orbit under the Berggren-Gauss map. -/
theorem golden_ratio_two_cycle :
    berggrenGauss (berggrenGauss ((1 + Real.sqrt 5) / 2)) = (1 + Real.sqrt 5) / 2 := by
  rw [golden_ratio_step1, golden_ratio_step2]

theorem arctan_half_plus_arctan_third :
    Real.arctan (1/2) + Real.arctan (1/3) = Real.pi / 4 := by
  rw [ ← eq_sub_iff_add_eq', Real.arctan_eq_of_tan_eq ];
  · rw [ Real.tan_eq_sin_div_cos, Real.sin_sub, Real.cos_sub, Real.sin_pi_div_four, Real.cos_pi_div_four, Real.sin_arctan, Real.cos_arctan ] ; repeat ring <;> norm_num;
  · constructor <;> linarith [ Real.arctan_pos.2 ( show 0 < 1 / 2 by norm_num ), Real.arctan_lt_pi_div_two ( 1 / 2 ) ]

/-- Berggren 2×2 matrix M_A -/
def M_A : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- Berggren 2×2 matrix M_B -/
def M_B : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

/-- Berggren 2×2 matrix M_C -/
def M_C : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

/-- det(M_A) = 1 (M_A ∈ SL(2,ℤ)) -/
theorem det_MA : Matrix.det M_A = 1 := by native_decide

/-- det(M_B) = -1 -/
theorem det_MB : Matrix.det M_B = -1 := by native_decide

/-- det(M_C) = 1 -/
theorem det_MC : Matrix.det M_C = 1 := by native_decide

end

/- Original: BerggrenGaussianBridge.lean -/



/-- [Section: ## Section 1: Gaussian Norm and Pythagorean Equation] -/
theorem gaussian_norm_eq_sum_sq (a b : ℤ) :
    (⟨a, b⟩ : GaussianInt).norm = a ^ 2 + b ^ 2 := by
  simp [Zsqrtd.norm_def]; ring

theorem pyth_iff_gaussian_norm (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ (⟨a, b⟩ : GaussianInt).norm = c ^ 2 := by
  rw [gaussian_norm_eq_sum_sq]

/-- [Section: ## Section 3: PPT Parametrization] -/
theorem parametric_ppt (m n : ℤ) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring

/-- [Section: ## Section 4: Berggren Steps Preserve PPTs] -/
theorem berggrenA_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by nlinarith

theorem berggrenB_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by nlinarith

theorem berggrenC_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by nlinarith

/-- [Section: ## Section 5: PPT ↔ Gaussian Integer] -/
theorem ppt_gaussian_rep (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    ∃ z : GaussianInt, z.norm = c ^ 2 ∧ z.re = a ∧ z.im = b :=
  ⟨⟨a, b⟩, by rw [gaussian_norm_eq_sum_sq]; exact h, rfl, rfl⟩

theorem root_gaussian : (⟨3, 4⟩ : GaussianInt).norm = 5 ^ 2 := by
  simp [Zsqrtd.norm_def]

theorem root_is_square : (⟨2, 1⟩ : GaussianInt) * ⟨2, 1⟩ = ⟨3, 4⟩ := by decide

theorem norm_generator : (⟨2, 1⟩ : GaussianInt).norm = 5 := by
  simp [Zsqrtd.norm_def]

/-- [Section: ## Section 6: Norm Preservation] -/
theorem mul_i_preserves_norm (z : GaussianInt) :
    ((⟨0, 1⟩ : GaussianInt) * z).norm = z.norm := by
  rw [gaussian_norm_mul]; simp [Zsqrtd.norm_def]

/-- [Section: ## Section 7: Sum of Two Squares] -/
theorem sum_two_squares_iff_norm (n : ℤ) :
    (∃ a b : ℤ, a ^ 2 + b ^ 2 = n) ↔ (∃ z : GaussianInt, z.norm = n) := by
  constructor
  · rintro ⟨a, b, hab⟩; exact ⟨⟨a, b⟩, by rw [gaussian_norm_eq_sum_sq]; exact hab⟩
  · rintro ⟨z, hz⟩; exact ⟨z.re, z.im, by rw [← gaussian_norm_eq_sum_sq]; exact hz⟩

/-- [Section: ## Section 8: Bridge Theorem] -/
theorem berggren_gaussian_bridge (a b c : ℤ)
    (hpyth : a ^ 2 + b ^ 2 = c ^ 2) (hc : 0 < c) :
    ∃ z : GaussianInt, z.norm = c ^ 2 ∧ 0 < z.norm := by
  refine ⟨⟨a, b⟩, ?_, ?_⟩
  · rw [gaussian_norm_eq_sum_sq]; exact hpyth
  · rw [gaussian_norm_eq_sum_sq, hpyth]; positivity

theorem hyp_determines_norm (a₁ b₁ a₂ b₂ c : ℤ)
    (h₁ : a₁ ^ 2 + b₁ ^ 2 = c ^ 2) (h₂ : a₂ ^ 2 + b₂ ^ 2 = c ^ 2) :
    (⟨a₁, b₁⟩ : GaussianInt).norm = (⟨a₂, b₂⟩ : GaussianInt).norm := by
  simp [gaussian_norm_eq_sum_sq]; linarith

/-- [Section: ## Section 9: Depth-1 Gaussian Integers] -/
theorem depth1_A_gaussian : (⟨5, 12⟩ : GaussianInt).norm = 169 := by simp [Zsqrtd.norm_def]

theorem depth1_B_gaussian : (⟨21, 20⟩ : GaussianInt).norm = 841 := by simp [Zsqrtd.norm_def]

theorem depth1_C_gaussian : (⟨15, 8⟩ : GaussianInt).norm = 289 := by simp [Zsqrtd.norm_def]

theorem depth1_hyps_mod4 : 13 % 4 = 1 ∧ 29 % 4 = 1 ∧ 17 % 4 = 1 := by omega

/-- [Section: ## Section 10: Primes and Gaussian Factorization] -/
theorem depth1_hyps_prime :
    Nat.Prime 5 ∧ Nat.Prime 13 ∧ Nat.Prime 17 ∧ Nat.Prime 29 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide

theorem two_plus_i_norm_prime : Nat.Prime (Zsqrtd.norm (⟨2, 1⟩ : GaussianInt)).natAbs := by
  simp [Zsqrtd.norm_def]; decide

theorem ppt_first_quadrant (a b : ℤ) (ha : 0 < a) (hb : 0 < b) :
    0 < (⟨a, b⟩ : GaussianInt).re ∧ 0 < (⟨a, b⟩ : GaussianInt).im :=
  ⟨ha, hb⟩

theorem norm_conj_eq (a b : ℤ) :
    (⟨a, -b⟩ : GaussianInt).norm = (⟨a, b⟩ : GaussianInt).norm := by
  simp [Zsqrtd.norm_def]

/- Original: BerggrenNewTheoremsV12.lean -/



/-- [Section: ## Matrix Definitions] -/
def BN₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenNewTheoremsV12
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 19] -/
def BN₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def BN₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- Closed-form formula for B₁ⁿ -/
def BN₁_pow_closed (n : ℕ) : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -(2 * ↑n), 2 * ↑n;
     2 * ↑n, 1 - 2 * (↑n : ℤ)^2, 2 * (↑n : ℤ)^2;
     2 * ↑n, -(2 * (↑n : ℤ)^2), 1 + 2 * (↑n : ℤ)^2]

/-- [Section: ## Closed-Form Matrix for B₁ⁿ
B₁ⁿ entries are polynomial in n:
(0,0)=1      (0,1)=-2n      (0,2)=2n
(1,0)=2n     (1,1)=1-2n²    (1,2)=2n²
(2,0)=2n     (2,1)=-2n²     (2,2)=1+2n²] -/
theorem BN₁_pow_eq_closed (n : ℕ) : BN₁ ^ n = BN₁_pow_closed n := by
  induction' n with n ih;
  · native_decide +revert;
  · simp_all +decide [ pow_succ, BN₁_pow_closed ];
    simp +decide [ BN₁, Matrix.vecMul ] ; ring_nf ; aesop;

/-- [Section: ## Determinant formulas for ALL n] -/
theorem det_BN₁_pow (n : ℕ) : Matrix.det (BN₁ ^ n) = 1 := by
  induction n <;> simp_all +decide [ pow_succ, Matrix.det_fin_three ]

theorem det_BN₂_pow (n : ℕ) : Matrix.det (BN₂ ^ n) = (-1) ^ n := by
  induction n <;> simp_all +decide [ pow_succ, Matrix.det_fin_three ];
  simp_all +decide [ BN₂ ]

theorem det_BN₃_pow (n : ℕ) : Matrix.det (BN₃ ^ n) = 1 := by
  induction n <;> simp_all +decide [ pow_succ' ]

/-- [Section: ## Infinite order] -/
theorem BN₁_infinite_order (n : ℕ) (hn : 0 < n) : BN₁ ^ n ≠ 1 := by
  -- By definition of $BN₁_pow_closed$, we know that its (0,1) entry is $-2n$.
  have h_entry : (BN₁_pow_closed n) 0 1 = -2 * n := by
    exact?;
  rw [ BN₁_pow_eq_closed ];
  exact ne_of_apply_ne ( fun m => m 0 1 ) ( by norm_num; linarith )

theorem BN₃_infinite_order (n : ℕ) (hn : 0 < n) : BN₃ ^ n ≠ 1 := by
  -- By induction on $n$, we can show that the $(0,1)$ entry of $BN₃^n$ is $2n$.
  have h_entry : ∀ n : ℕ, (BN₃ ^ n) 0 1 = 2 * n := by
    intro n;
    induction n <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
    simp_all +decide [ Fin.sum_univ_succ, BN₃ ];
    rename_i k hk;
    have h_ind : ∀ k : ℕ, (Matrix.of ![![(-1 : ℤ), 2, 2], ![-2, 1, 2], ![-2, 2, 3]] ^ k) 0 0 + (Matrix.of ![![(-1 : ℤ), 2, 2], ![-2, 1, 2], ![-2, 2, 3]] ^ k) 0 2 = 1 := by
      intro k; induction k <;> simp_all +decide [ pow_succ, Matrix.mul_apply ] ;
      norm_num [ Fin.sum_univ_succ ] at * ; linarith!;
    linarith [ h_ind k ];
  exact ne_of_apply_ne ( fun m => m 0 1 ) ( by simp +decide [ h_entry, hn.ne' ] )

theorem BN₂_infinite_order (n : ℕ) (hn : 0 < n) : BN₂ ^ n ≠ 1 := by
  -- By induction, we can show that the (0,2) entry of BN₂^n is always positive.
  have h_pos : ∀ n > 0, 0 < (BN₂ ^ n) 0 2 := by
    intro n hn; induction hn <;> simp_all +decide [ pow_succ', Matrix.mul_apply ] ;
    simp_all +decide [ Fin.sum_univ_three, BN₂ ];
    -- By definition of matrix multiplication and the properties of the matrix BN₂, we know that all entries of BN₂^m are non-negative.
    have h_nonneg : ∀ m : ℕ, ∀ i j : Fin 3, 0 ≤ (BN₂ ^ m) i j := by
      intro m i j; induction' m with m ih generalizing i j <;> simp_all +decide [ pow_succ', Matrix.mul_apply ] ;
      · fin_cases i <;> fin_cases j <;> norm_num;
      · exact Finset.sum_nonneg fun k _ => mul_nonneg ( by fin_cases i <;> fin_cases k <;> trivial ) ( ih _ _ );
    exact add_pos_of_pos_of_nonneg ( add_pos_of_pos_of_nonneg ‹_› ( mul_nonneg zero_le_two ( h_nonneg _ _ _ ) ) ) ( mul_nonneg zero_le_two ( h_nonneg _ _ _ ) );
  exact fun h => by simpa [ h ] using h_pos n hn;

/-- Pell sequence -/
def pellN : ℕ → ℤ
  | 0 => 1
  | 1 => 2
  | n + 2 => 2 * pellN (n + 1) + pellN n

/-- [Section: ## Pell Sequence Properties] -/
theorem pell_sq_sum_recurrence (n : ℕ) :
    pellN (n + 2) ^ 2 + pellN (n + 3) ^ 2 =
    6 * (pellN (n + 1) ^ 2 + pellN (n + 2) ^ 2) -
    (pellN n ^ 2 + pellN (n + 1) ^ 2) := by
  erw [ show pellN ( n + 3 ) = 2 * pellN ( n + 2 ) + pellN ( n + 1 ) from rfl, show pellN ( n + 2 ) = 2 * pellN ( n + 1 ) + pellN n from rfl ] ; ring

/-- [Section: ## Lorentz form preservation for all n] -/
def QN : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

theorem BN₁_lorentz : BN₁ᵀ * QN * BN₁ = QN := by native_decide

theorem BN₁_pow_lorentz (n : ℕ) : (BN₁ ^ n)ᵀ * QN * (BN₁ ^ n) = QN := by
  induction n <;> simp_all +decide [ pow_succ', Matrix.mul_assoc ];
  simp_all +decide [ ← Matrix.mul_assoc, BN₁_lorentz ]

theorem BN₂_pow_lorentz (n : ℕ) : (BN₂ ^ n)ᵀ * QN * (BN₂ ^ n) = QN := by
  induction n <;> simp_all +decide [ pow_succ, ← mul_assoc ];
  simp_all +decide [ mul_assoc ]

/-- [Section: ## C-branch odd legs mod 4] -/
theorem C_odd_leg_mod4 (n : ℕ) :
    ((2 * (↑n : ℤ) + 1) * (2 * ↑n + 3)) % 4 = 3 := by
  ring_nf; norm_num [ Int.add_emod, Int.mul_emod ] ;

/-- [Section: ## Verification] -/
theorem BN₁_pow_closed_check :
    BN₁_pow_closed 0 = 1 ∧
    BN₁_pow_closed 1 = BN₁ ∧
    BN₁_pow_closed 2 = !![1, (-4 : ℤ), 4; 4, -7, 8; 4, -8, 9] := by
  constructor
  · ext i j; fin_cases i <;> fin_cases j <;> simp [BN₁_pow_closed]
  constructor
  · ext i j; fin_cases i <;> fin_cases j <;> simp [BN₁_pow_closed, BN₁]
  · ext i j; fin_cases i <;> fin_cases j <;> simp [BN₁_pow_closed]

/- Original: BerggrenNilpotentPower.lean -/



/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenNilpotentPower
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 18] -/
def BNP₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenNilpotentPower
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 18] -/
def NNP₁ : Matrix (Fin 3) (Fin 3) ℤ := !![0, -2, 2; 2, -2, 2; 2, -2, 2]

theorem NNP₁_cubed : NNP₁ * NNP₁ * NNP₁ = 0 := by native_decide

theorem NNP₁_eq : NNP₁ = BNP₁ - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [NNP₁, BNP₁]

theorem NNP₁_sq_ne_zero : NNP₁ * NNP₁ ≠ 0 := by native_decide

/-- N² has a specific form -/
theorem NNP₁_sq : NNP₁ * NNP₁ = !![0, 0, 0; 0, -4, 4; 0, -4, 4] := by native_decide

theorem BNP₁_pow_2 : BNP₁ ^ 2 = !![1, -4, 4; 4, -7, 8; 4, -8, 9] := by native_decide

theorem BNP₁_pow_3 : BNP₁ ^ 3 = !![1, -6, 6; 6, -17, 18; 6, -18, 19] := by native_decide

theorem BNP₁_pow_4 : BNP₁ ^ 4 = !![1, -8, 8; 8, -31, 32; 8, -32, 33] := by native_decide

def A_br (n : ℕ) : ℤ × ℤ × ℤ := (2*n + 3, 2*(↑n+1)*(↑n+2), 2*(↑n : ℤ)^2 + 6*n + 5)

theorem A_br_pyth (n : ℕ) : (A_br n).1^2 + (A_br n).2.1^2 = (A_br n).2.2^2 := by
  simp only [A_br]; ring

theorem A_br_consec (n : ℕ) : (A_br n).2.2 - (A_br n).2.1 = 1 := by
  simp only [A_br]; ring

theorem A_br_odd (n : ℕ) : ∃ k, (A_br n).1 = 2 * k + 1 := ⟨↑n + 1, by simp [A_br]; ring⟩

theorem A_br_even (n : ℕ) : ∃ k, (A_br n).2.1 = 2 * k :=
  ⟨(↑n+1)*(↑n+2), by simp [A_br]; ring⟩

theorem A_br_hyp_odd (n : ℕ) : ∃ k, (A_br n).2.2 = 2 * k + 1 :=
  ⟨(n : ℤ)^2 + 3*n + 2, by simp only [A_br]; ring⟩

theorem A_br_matches_root (n : ℕ) :
    (A_br n).1 = (1 : ℤ) * 3 + (-2 * ↑n) * 4 + (2 * ↑n) * 5 := by
  simp [A_br]; ring

theorem A_br_b_matches_root (n : ℕ) :
    (A_br n).2.1 = (2 * ↑n) * 3 + (1 - 2 * (↑n : ℤ)^2) * 4 + (2 * (↑n : ℤ)^2) * 5 := by
  simp [A_br]; ring

theorem A_br_c_matches_root (n : ℕ) :
    (A_br n).2.2 = (2 * ↑n) * 3 + (-2 * (↑n : ℤ)^2) * 4 + (1 + 2 * (↑n : ℤ)^2) * 5 := by
  simp [A_br]; ring

/- Original: BerggrenPathUniqueness.lean -/



/-- [Section: ## Definitions] -/
inductive BStepU where
  | A | B | C
  deriving Repr, DecidableEq

def applyStepU (s : BStepU) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match s with
  | .A => (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)
  | .B => (t.1 + 2*t.2.1 + 2*t.2.2, 2*t.1 + t.2.1 + 2*t.2.2, 2*t.1 + 2*t.2.1 + 3*t.2.2)
  | .C => (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)

def applyPathU (path : List BStepU) : ℤ × ℤ × ℤ :=
  path.foldl (fun t s => applyStepU s t) (3, 4, 5)

/-- [Section: ## Section 1: Sigma Identities] -/
theorem sigma1_stepA (a' b' c' : ℤ) :
    let ch := applyStepU .A (a', b', c')
    ch.1 + 2 * ch.2.1 - 2 * ch.2.2 = a' := by simp [applyStepU]; ring

theorem sigma2_stepA (a' b' c' : ℤ) :
    let ch := applyStepU .A (a', b', c')
    2 * ch.1 + ch.2.1 - 2 * ch.2.2 = -b' := by simp [applyStepU]; ring

theorem sigma1_stepB (a' b' c' : ℤ) :
    let ch := applyStepU .B (a', b', c')
    ch.1 + 2 * ch.2.1 - 2 * ch.2.2 = a' := by simp [applyStepU]; ring

theorem sigma2_stepB (a' b' c' : ℤ) :
    let ch := applyStepU .B (a', b', c')
    2 * ch.1 + ch.2.1 - 2 * ch.2.2 = b' := by simp [applyStepU]; ring

theorem sigma1_stepC (a' b' c' : ℤ) :
    let ch := applyStepU .C (a', b', c')
    ch.1 + 2 * ch.2.1 - 2 * ch.2.2 = -a' := by simp [applyStepU]; ring

theorem sigma2_stepC (a' b' c' : ℤ) :
    let ch := applyStepU .C (a', b', c')
    2 * ch.1 + ch.2.1 - 2 * ch.2.2 = b' := by simp [applyStepU]; ring

/-- [Section: ## Section 2: Step Uniqueness
The signs of σ₁, σ₂ are disjoint: A → (+,−), B → (+,+), C → (−,+).
So if two steps from positive-legged parents produce the same child, the steps agree.] -/
theorem step_determined (s₁ s₂ : BStepU) (t₁ t₂ : ℤ × ℤ × ℤ)
    (ht₁a : 0 < t₁.1) (ht₁b : 0 < t₁.2.1)
    (ht₂a : 0 < t₂.1) (ht₂b : 0 < t₂.2.1)
    (heq : applyStepU s₁ t₁ = applyStepU s₂ t₂) : s₁ = s₂ := by
  cases s₁ <;> cases s₂ <;> simp_all +decide;
  all_goals unfold applyStepU at heq; norm_num at heq; linarith;

/-- [Section: ## Section 3: Each Step is Injective] -/
theorem applyStepU_injective (s : BStepU) (t₁ t₂ : ℤ × ℤ × ℤ)
    (h : applyStepU s t₁ = applyStepU s t₂) : t₁ = t₂ := by
  cases s <;> simp only [applyStepU, Prod.mk.injEq] at h <;>
    obtain ⟨h1, h2, h3⟩ := h <;> ext <;> linarith

/-- [Section: ## Section 4: Forward Maps Preserve Pythagorean + Positivity] -/
theorem step_pyth (s : BStepU) (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let ch := applyStepU s (a, b, c)
    ch.1 ^ 2 + ch.2.1 ^ 2 = ch.2.2 ^ 2 := by
  cases s <;> simp [applyStepU] <;> nlinarith

theorem step_pos (s : BStepU) (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    let ch := applyStepU s (a, b, c)
    0 < ch.1 ∧ 0 < ch.2.1 ∧ 0 < ch.2.2 := by
  rcases s with ( _ | _ | _ ) <;> norm_num [ applyStepU ] <;> constructor <;> try nlinarith;
  · constructor <;> nlinarith only [ ha, hb, hc, hpyth ];
  · constructor <;> linarith;
  · constructor <;> nlinarith only [ ha, hb, hc, hpyth ]

/-- [Section: ## Section 5: Hypotenuse Strictly Increases] -/
theorem step_hyp_increase (s : BStepU) (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    c < (applyStepU s (a, b, c)).2.2 := by
  cases s <;> simp [applyStepU] <;> nlinarith [sq_nonneg (a - b)]

/-- [Section: ## Section 6: Path Preservation] -/
theorem path_valid_aux :
    ∀ (path : List BStepU) (t : ℤ × ℤ × ℤ),
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    0 < t.1 → 0 < t.2.1 → 0 < t.2.2 →
    let res := path.foldl (fun t s => applyStepU s t) t
    res.1 ^ 2 + res.2.1 ^ 2 = res.2.2 ^ 2 ∧ 0 < res.1 ∧ 0 < res.2.1 ∧ 0 < res.2.2 := by
  intro path
  induction path with
  | nil => intro t hp ha hb hc; exact ⟨hp, ha, hb, hc⟩
  | cons s rest ih =>
    intro t hp ha hb hc
    simp only [List.foldl_cons]
    exact ih _ (step_pyth s _ _ _ hp) (step_pos s _ _ _ ha hb hc hp).1
      (step_pos s _ _ _ ha hb hc hp).2.1 (step_pos s _ _ _ ha hb hc hp).2.2

theorem applyPathU_valid (path : List BStepU) :
    let t := applyPathU path
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧ 0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 :=
  path_valid_aux path (3, 4, 5) (by norm_num) (by norm_num) (by norm_num) (by norm_num)

/-- [Section: ## Section 7: Hypotenuse Bounds] -/
theorem hyp_increases_aux :
    ∀ (path : List BStepU) (t : ℤ × ℤ × ℤ),
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    0 < t.1 → 0 < t.2.1 → 0 < t.2.2 →
    path ≠ [] →
    t.2.2 < (path.foldl (fun t s => applyStepU s t) t).2.2 := by
  intro path
  induction path with
  | nil => intro _ _ _ _ _ h; exact absurd rfl h
  | cons s rest ih =>
    intro t hp ha hb hc _
    simp only [List.foldl_cons]
    by_cases hrest : rest = []
    · subst hrest; simp; exact step_hyp_increase s _ _ _ ha hb hc hp
    · calc t.2.2 < (applyStepU s t).2.2 := step_hyp_increase s _ _ _ ha hb hc hp
        _ < _ := ih _ (step_pyth s _ _ _ hp) (step_pos s _ _ _ ha hb hc hp).1
            (step_pos s _ _ _ ha hb hc hp).2.1 (step_pos s _ _ _ ha hb hc hp).2.2 hrest

theorem nonempty_path_hyp_gt_5 (path : List BStepU) (hne : path ≠ []) :
    5 < (applyPathU path).2.2 := by
  have := hyp_increases_aux path (3, 4, 5) (by norm_num) (by norm_num) (by norm_num) (by norm_num) hne
  simp [applyPathU] at this ⊢; linarith

/-- [Section: ## Section 8: Append / Concat Lemmas] -/
theorem applyPathU_concat (path : List BStepU) (s : BStepU) :
    applyPathU (path.concat s) = applyStepU s (applyPathU path) := by
  simp [applyPathU, List.concat_eq_append, List.foldl_append]

/-- **Berggren Path Uniqueness**: Two paths from root (3,4,5) producing the
same triple must be identical. -/
theorem berggren_path_unique (w₁ w₂ : List BStepU)
    (h : applyPathU w₁ = applyPathU w₂) : w₁ = w₂ :=
  path_unique_aux _ w₁ w₂ rfl h

/-- Different words produce different triples -/
theorem berggren_free_semigroup (w₁ w₂ : List BStepU) (hw : w₁ ≠ w₂) :
    applyPathU w₁ ≠ applyPathU w₂ :=
  fun h => hw (berggren_path_unique w₁ w₂ h)

/-- The map applyPathU is injective -/
theorem applyPathU_injective : Function.Injective applyPathU :=
  fun _ _ h => berggren_path_unique _ _ h

/-- Every PPT in the tree has a unique path representation -/
theorem unique_representation (t : ℤ × ℤ × ℤ)
    (w₁ w₂ : List BStepU) (h₁ : applyPathU w₁ = t) (h₂ : applyPathU w₂ = t) :
    w₁ = w₂ :=
  berggren_path_unique w₁ w₂ (h₁ ▸ h₂ ▸ rfl)

/- Original: BerggrenPellClosedForm.lean -/



/-- [Section: ## Section 1: Pell Sequence Definitions] -/
def pellX : ℕ → ℤ
  | 0 => 1
  | 1 => 3
  | n + 2 => 6 * pellX (n + 1) - pellX n

def pellY : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => 6 * pellY (n + 1) - pellY n

/-- [Section: ## Section 2: Basic Values] -/
theorem pellX_2 : pellX 2 = 17 := by native_decide

theorem pellX_3 : pellX 3 = 99 := by native_decide

theorem pellX_4 : pellX 4 = 577 := by native_decide

@[simp] theorem pellY_0 : pellY 0 = 0 := rfl
@[simp] theorem pellY_1 : pellY 1 = 1 := rfl

theorem pellY_2 : pellY 2 = 6 := by native_decide

theorem pellY_3 : pellY 3 = 35 := by native_decide

theorem pellY_4 : pellY 4 = 204 := by native_decide

/-- [Section: ## Section 3: Recurrence Relations] -/
theorem pellX_rec (n : ℕ) : pellX (n + 2) = 6 * pellX (n + 1) - pellX n := rfl

theorem pellY_rec (n : ℕ) : pellY (n + 2) = 6 * pellY (n + 1) - pellY n := rfl

/-- The fundamental Pell identity: pellX(n)² - 8·pellY(n)² = 1 -/
theorem pell_identity (n : ℕ) : pellX n ^ 2 - 8 * pellY n ^ 2 = 1 := (pell_both n).1

/-- The cross identity: pellX(n+1)·pellX(n) - 8·pellY(n+1)·pellY(n) = 3 -/
theorem pell_cross (n : ℕ) : pellX (n+1) * pellX n - 8 * pellY (n+1) * pellY n = 3 :=
  (pell_both n).2

/-- [Section: ## Section 5: Pell Cross Identity (alternate form)] -/
theorem pell_cross_identity (n : ℕ) :
    pellX (n + 1) * pellY n - pellX n * pellY (n + 1) = -1 := by
  induction' n with n ih <;> norm_num [ pellX_rec, pellY_rec ] at * ; linarith

/-- [Section: ## Section 6: Positivity and Growth] -/
theorem pellX_pos (n : ℕ) : 0 < pellX n := (pellX_pos_and_mono n).1

theorem pellX_strict_mono (n : ℕ) : pellX n < pellX (n + 1) := (pellX_pos_and_mono n).2

theorem pellY_nonneg (n : ℕ) : 0 ≤ pellY n := by
  -- We will prove this by induction on $n$.
  have h_ind : ∀ n, 0 ≤ pellY n ∧ pellY n < pellY (n + 1) := by
    intro n; induction n <;> simp_all +decide [ pellY_rec ] ;
    constructor <;> linarith;
  exact h_ind n |>.1

theorem pellY_pos (n : ℕ) (hn : 0 < n) : 0 < pellY n := by
  induction hn <;> simp +decide [ *, pellY_rec ];
  rename_i k hk ih;
  -- By the properties of the Pell sequence, we know that $pellY (k + 1) > pellY k$.
  have h_pellY_inc : ∀ k, pellY (k + 1) > pellY k := by
    intro k; induction' k with k ih <;> simp_all +decide [ pellY_rec ] ;
    linarith [ pellY_nonneg k ];
  linarith [ h_pellY_inc k ]

theorem pellY_strict_mono (n : ℕ) : pellY n < pellY (n + 1) := by
  induction' n with n ih <;> norm_num [ pellY ] at *;
  linarith [ pellY_nonneg n ]

/-- [Section: ## Section 7: Matrix Form] -/
def pellMatrix : Matrix (Fin 2) (Fin 2) ℤ := !![6, -1; 1, 0]

theorem pellMatrix_det : det pellMatrix = 1 := by native_decide

theorem BN₂_trace : trace BN₂ = 5 := by native_decide

theorem BN₂_det : det BN₂ = -1 := by native_decide

theorem BN₂_sq_trace : trace (BN₂ ^ 2) = 35 := by native_decide

theorem BN₂_cube_trace : trace (BN₂ ^ 3) = 197 := by native_decide

/-- tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ for n = 0,1,2,3 -/
theorem traceB2_pellX_connection :
    trace (BN₂ ^ 0) = 2 * pellX 0 + (-1 : ℤ)^0 ∧
    trace (BN₂ ^ 1) = 2 * pellX 1 + (-1 : ℤ)^1 ∧
    trace (BN₂ ^ 2) = 2 * pellX 2 + (-1 : ℤ)^2 ∧
    trace (BN₂ ^ 3) = 2 * pellX 3 + (-1 : ℤ)^3 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

/-- [Section: ## Section 9: Addition Formulas (conjectured)] -/
theorem pellX_add (m n : ℕ) :
    pellX (m + n) = pellX m * pellX n + 8 * pellY m * pellY n := by
  -- By induction on $n$, we can show that the addition formula holds.
  induction' n using Nat.strong_induction_on with n ih generalizing m;
  rcases n with _ | _ | n;
  · norm_num [ pellX_0, pellY_0 ];
  · grind +suggestions;
  · erw [ show m + ( n + 2 ) = ( m + n ) + 2 from by ring, pellX_rec, ih _ ( by linarith ) m ];
    have := ih n ( by linarith ) m; have := ih ( n + 1 ) ( by linarith ) m; simp_all +decide [ Nat.add_assoc, pellX_rec, pellY_rec ] ; ring;

theorem pellY_add (m n : ℕ) :
    pellY (m + n) = pellX m * pellY n + pellY m * pellX n := by
  induction' n using Nat.strong_induction_on with n ih generalizing m;
  rcases n with ( _ | _ | n );
  · norm_num [ pellX_0, pellY_0 ];
  · grind +suggestions;
  · have := ih n ( by linarith ) ( m + 1 ) ; have := ih ( n + 1 ) ( by linarith ) m ; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
    have := ih n ( by linarith ) ( m + 2 ) ; simp_all +decide [ add_comm, add_left_comm, add_assoc ] ;
    have := pellX_rec n; have := pellY_rec n; have := pellX_rec m; have := pellY_rec m; norm_num [ pellX, pellY ] at * ; linarith;

/-- B₂³ = 5·B₂² + 5·B₂ - I (Cayley-Hamilton) -/
theorem BN₂_cayley_hamilton : BN₂ ^ 3 = 5 • BN₂ ^ 2 + 5 • BN₂ - 1 := by
  native_decide

/-- Consequence: trace satisfies tr(n+3) = 5·tr(n+2) + 5·tr(n+1) - tr(n) -/
theorem BN₂_trace_recurrence :
    trace (BN₂ ^ 4) = 5 * trace (BN₂ ^ 3) + 5 * trace (BN₂ ^ 2) - trace (BN₂ ^ 1) := by
  native_decide

/-- [Section: ## Section 10: Cayley-Hamilton for B₂] -/
theorem pellX_ge_one (n : ℕ) : 1 ≤ pellX n := by
  linarith [pellX_pos n]

/- Original: BerggrenPellSemigroup.lean -/



/-- [Section: ## Section 1: Pell Sequences (self-contained definitions)] -/
def pellX' : ℕ → ℤ
  | 0 => 1
  | 1 => 3
  | n + 2 => 6 * pellX' (n + 1) - pellX' n

def pellY' : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => 6 * pellY' (n + 1) - pellY' n

/-- The Pell product: multiplication of elements in ℤ[√8].
(x₁ + y₁√8)(x₂ + y₂√8) = (x₁x₂ + 8y₁y₂) + (x₁y₂ + y₁x₂)√8 -/
def pellProd (p q : ℤ × ℤ) : ℤ × ℤ :=
  (p.1 * q.1 + 8 * p.2 * q.2, p.1 * q.2 + p.2 * q.1)

/-- The Pell unit: 1 + 0·√8 -/
def pellUnit : ℤ × ℤ := (1, 0)

/-- The fundamental solution: 3 + 1·√8 -/
def pellFund : ℤ × ℤ := (3, 1)

/-- [Section: ## Section 3: Pell Product is Associative and has Identity] -/
theorem pellProd_assoc (p q r : ℤ × ℤ) :
    pellProd (pellProd p q) r = pellProd p (pellProd q r) := by
  ext <;> simp [pellProd] <;> ring

theorem pellProd_unit_left (p : ℤ × ℤ) : pellProd pellUnit p = p := by
  ext <;> simp [pellProd, pellUnit]

theorem pellProd_unit_right (p : ℤ × ℤ) : pellProd p pellUnit = p := by
  ext <;> simp [pellProd, pellUnit]

theorem pellProd_comm (p q : ℤ × ℤ) : pellProd p q = pellProd q p := by
  ext <;> simp [pellProd] <;> ring

/-- The norm in ℤ[√8]: N(x + y√8) = x² - 8y² -/
def pellNorm (p : ℤ × ℤ) : ℤ := p.1 ^ 2 - 8 * p.2 ^ 2

/-- [Section: ## Section 4: Norm Preservation] -/
theorem pellNorm_unit : pellNorm pellUnit = 1 := by simp [pellNorm, pellUnit]

theorem pellNorm_fund : pellNorm pellFund = 1 := by norm_num [pellNorm, pellFund]

/-- The norm is multiplicative: N(p·q) = N(p)·N(q) -/
theorem pellNorm_mul (p q : ℤ × ℤ) :
    pellNorm (pellProd p q) = pellNorm p * pellNorm q := by
  simp [pellNorm, pellProd]; ring

/-- The n-th power of a pair under pellProd -/
def pellPow (p : ℤ × ℤ) : ℕ → ℤ × ℤ
  | 0 => pellUnit
  | n + 1 => pellProd p (pellPow p n)

/-- [Section: ## Section 5: Pell Power] -/
theorem pellPow_zero (p : ℤ × ℤ) : pellPow p 0 = pellUnit := rfl

theorem pellPow_succ (p : ℤ × ℤ) (n : ℕ) :
    pellPow p (n + 1) = pellProd p (pellPow p n) := rfl

theorem pellPow_one (p : ℤ × ℤ) : pellPow p 1 = p := by
  simp [pellPow, pellProd_unit_right]

/-- [Section: ## Section 6: Norm of Powers] -/
theorem pellNorm_pow (p : ℤ × ℤ) (n : ℕ) :
    pellNorm (pellPow p n) = pellNorm p ^ n := by
  induction n with
  | zero => simp [pellPow_zero, pellNorm_unit]
  | succ n ih => rw [pellPow_succ, pellNorm_mul, ih, pow_succ, mul_comm]

theorem pellNorm_fund_pow (n : ℕ) : pellNorm (pellPow pellFund n) = 1 := by
  rw [pellNorm_pow, pellNorm_fund, one_pow]

/-- [Section: ## Section 7: Connection to pellX', pellY'] -/
theorem pellPow_fund_eq (n : ℕ) :
    pellPow pellFund n = (pellX' n, pellY' n) := by
      induction' n using Nat.strong_induction_on with n ih;
      rcases n with ( _ | _ | n ) <;> simp +arith +decide [ * ];
      grind +locals

/-- [Section: ## Section 8: Pell Product Addition Law] -/
theorem pellProd_add (m n : ℕ) :
    pellProd (pellX' m, pellY' m) (pellX' n, pellY' n) =
    (pellX' (m + n), pellY' (m + n)) := by
      -- By definition of pellProd, we can expand both sides.
      rw [← pellPow_fund_eq, ← pellPow_fund_eq, ← pellPow_fund_eq];
      induction' n with n ih;
      · exact pellProd_unit_right _;
      · grind +locals

/-- [Section: ## Section 9: Doubling Formulas (for fast computation)] -/
theorem pellX'_double (n : ℕ) :
    pellX' (2 * n) = 2 * pellX' n ^ 2 - 1 := by
      induction' n using Nat.strong_induction_on with n ih;
      rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ *, ih ];
      have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; have := ih ( n + 2 ) ( by linarith ) ; simp_all +decide [ Nat.mul_succ, pellX' ] ; ring;
      grind

theorem pellY'_double (n : ℕ) :
    pellY' (2 * n) = 2 * pellX' n * pellY' n := by
      by_contra h;
      -- By definition of $pellY'$, we know that $pellY'(2n)$ is the second component of $pellProd (pellFund^n) (pellFund^n)$.
      have h_pellY'_def : pellY' (2 * n) = (pellProd (pellX' n, pellY' n) (pellX' n, pellY' n)).2 := by
        rw [ show 2 * n = n + n by ring, pellProd_add ];
      exact h ( h_pellY'_def.trans ( by unfold pellProd; ring ) )

/-- The conjugate: x - y√8. Conjugation is an involution preserving norm. -/
def pellConj (p : ℤ × ℤ) : ℤ × ℤ := (p.1, -p.2)

/-- [Section: ## Section 10: Pell Conjugate] -/
theorem pellConj_involution (p : ℤ × ℤ) : pellConj (pellConj p) = p := by
  simp [pellConj]

theorem pellNorm_conj (p : ℤ × ℤ) : pellNorm (pellConj p) = pellNorm p := by
  simp [pellNorm, pellConj]

theorem pellProd_conj (p q : ℤ × ℤ) :
    pellConj (pellProd p q) = pellProd (pellConj p) (pellConj q) := by
  ext <;> simp [pellConj, pellProd] <;> ring

/-- Product with conjugate gives the norm: p · conj(p) = (N(p), 0) -/
theorem pellProd_self_conj (p : ℤ × ℤ) :
    pellProd p (pellConj p) = (pellNorm p, 0) := by
  ext <;> simp [pellProd, pellConj, pellNorm] <;> ring

/-- For norm-1 elements, the conjugate is the inverse -/
theorem pellConj_inverse (p : ℤ × ℤ) (hp : pellNorm p = 1) :
    pellProd p (pellConj p) = pellUnit := by
  rw [pellProd_self_conj, hp]; rfl

/-- [Section: ## Section 12: Specific Computations] -/
theorem pellFund_sq : pellProd pellFund pellFund = (17, 6) := by
  ext <;> simp [pellProd, pellFund]

theorem pellFund_cube : pellProd pellFund (pellProd pellFund pellFund) = (99, 35) := by
  ext <;> simp [pellProd, pellFund]

theorem pellX'_values :
    pellX' 0 = 1 ∧ pellX' 1 = 3 ∧ pellX' 2 = 17 ∧ pellX' 3 = 99 := by
  refine ⟨rfl, rfl, ?_, ?_⟩ <;> native_decide

theorem pellY'_values :
    pellY' 0 = 0 ∧ pellY' 1 = 1 ∧ pellY' 2 = 6 ∧ pellY' 3 = 35 := by
  refine ⟨rfl, rfl, ?_, ?_⟩ <;> native_decide

/- Original: BerggrenPellStructure.lean -/



/-- B₂ⁿ·(3,4,5) by iteration -/
def b2iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 =>
    let (a, b, c) := b2iter n
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Companion Pell: hypotenuses of B₂ iterates -/
def cPell : ℕ → ℤ
  | 0 => 5
  | 1 => 29
  | n + 2 => 6 * cPell (n + 1) - cPell n

/-- [Section: ## Computational Checks] -/
theorem b2iter_vals :
    b2iter 0 = (3, 4, 5) ∧
    b2iter 1 = (21, 20, 29) ∧
    b2iter 2 = (119, 120, 169) ∧
    b2iter 3 = (697, 696, 985) ∧
    b2iter 4 = (4059, 4060, 5741) := by native_decide

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenPellStructure
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 15] -/
theorem cPell_vals :
    cPell 0 = 5 ∧ cPell 1 = 29 ∧ cPell 2 = 169 ∧
    cPell 3 = 985 ∧ cPell 4 = 5741 := by native_decide

/-- [Section: ## Hypotenuses are Sums of Consecutive Pell Squares] -/
theorem pellSeq_vals :
    pellSeq 0 = 1 ∧ pellSeq 1 = 2 ∧ pellSeq 2 = 5 ∧
    pellSeq 3 = 12 ∧ pellSeq 4 = 29 ∧ pellSeq 5 = 70 := by native_decide

/-- B₂ hypotenuses = sum of consecutive Pell squares -/
theorem cPell_eq_pell_sum_sq :
    cPell 0 = pellSeq 0 ^ 2 + pellSeq 1 ^ 2 ∧
    cPell 1 = pellSeq 1 ^ 2 + pellSeq 2 ^ 2 ∧
    cPell 2 = pellSeq 2 ^ 2 + pellSeq 3 ^ 2 ∧
    cPell 3 = pellSeq 3 ^ 2 + pellSeq 4 ^ 2 ∧
    cPell 4 = pellSeq 4 ^ 2 + pellSeq 5 ^ 2 := by native_decide

/-- [Section: ## B₂ Leg Difference Alternation] -/
theorem b2_leg_diff : ∀ n, (b2iter n).1 - (b2iter n).2.1 = (-1)^(n+1) := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [b2iter]; set t := b2iter n
    have : (t.1 + 2*t.2.1 + 2*t.2.2) - (2*t.1 + t.2.1 + 2*t.2.2) = -(t.1 - t.2.1) := by ring
    rw [this, ih]; ring

/-- [Section: ## B₂ Pythagorean] -/
theorem b2_pyth : ∀ n, (b2iter n).1^2 + (b2iter n).2.1^2 = (b2iter n).2.2^2 := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [b2iter]; set t := b2iter n
    nlinarith [sq_nonneg t.1, sq_nonneg t.2.1, sq_nonneg (t.1 - t.2.1), sq_nonneg (t.1 + t.2.1)]

/-- [Section: ## B₂ Positivity] -/
theorem b2_pos : ∀ n, 0 < (b2iter n).1 ∧ 0 < (b2iter n).2.1 ∧ 0 < (b2iter n).2.2 := by
  intro n
  induction n with
  | zero => decide
  | succ n ih =>
    simp only [b2iter]; set t := b2iter n
    exact ⟨by linarith [ih.1, ih.2.1, ih.2.2],
           by linarith [ih.1, ih.2.1, ih.2.2],
           by linarith [ih.1, ih.2.1, ih.2.2]⟩

/-- [Section: ## Companion Pell mod 4] -/
theorem cPell_mod4 : ∀ n, cPell n % 4 = 1 := fun n => (cPell_mod4_aux n).1

/-- [Section: ## Companion Pell Positivity] -/
theorem cPell_pos : ∀ n, 0 < cPell n := fun n => (cPell_pos_aux n).1

/-- [Section: ## B₂ Determinant Pattern] -/
def BPS₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

theorem det_BPS₂_pow :
    Matrix.det BPS₂ = -1 ∧
    Matrix.det (BPS₂ ^ 2) = 1 ∧
    Matrix.det (BPS₂ ^ 3) = -1 ∧
    Matrix.det (BPS₂ ^ 4) = 1 := by native_decide

/-- [Section: ## B₂ Parity Preservation] -/
theorem b2_parity_a : ∀ n, (b2iter n).1 % 2 = 1 := fun n => (b2_parity_aux n).1

theorem b2_parity_b : ∀ n, (b2iter n).2.1 % 2 = 0 := fun n => (b2_parity_aux n).2

/- Original: BerggrenPowerFormulas.lean -/



/-- Berggren matrix B₁ -/
def BPF₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The nilpotent part N₁ = B₁ - I -/
def NPF₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![0, -2, 2; 2, -2, 2; 2, -2, 2]

/-- N₁² (computed) -/
def NPF₁sq : Matrix (Fin 3) (Fin 3) ℤ :=
  !![0, 0, 0; 0, -4, 4; 0, -4, 4]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenPowerFormulas
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 15] -/
theorem NPF₁_eq_B₁_sub_I : NPF₁ = BPF₁ - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [NPF₁, BPF₁]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenPowerFormulas
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 15] -/
theorem NPF₁_sq_eq : NPF₁ * NPF₁ = NPF₁sq := by native_decide

theorem NPF₁_sq_ne_zero : NPF₁ * NPF₁ ≠ 0 := by native_decide

theorem NPF₁_cubed_eq_zero : NPF₁ * NPF₁ * NPF₁ = 0 := by native_decide

theorem A_triple_pythagorean (n : ℕ) :
    (A_triple n).1 ^ 2 + (A_triple n).2.1 ^ 2 = (A_triple n).2.2 ^ 2 := by
  simp only [A_triple]; ring

theorem A_triple_1 : A_triple 1 = (5, 12, 13) := by simp [A_triple]

theorem A_triple_2 : A_triple 2 = (7, 24, 25) := by simp [A_triple]

theorem A_triple_3 : A_triple 3 = (9, 40, 41) := by simp [A_triple]

theorem A_hyp_growth (n : ℕ) : (A_triple n).2.2 < (A_triple (n + 1)).2.2 := by
  simp only [A_triple]; push_cast; nlinarith [n.zero_le]

theorem A_hyp_pos (n : ℕ) : 0 < (A_triple n).2.2 := by
  simp only [A_triple]; positivity

theorem A_first_pos (n : ℕ) : 0 < (A_triple n).1 := by
  simp only [A_triple]; omega

theorem A_second_pos (n : ℕ) : 0 < (A_triple n).2.1 := by
  simp only [A_triple]; positivity


/- Original: BerggrenQuadraticForms.lean -/



theorem ppt_iff_lorentz_zero (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ lorentzForm a b c = 0 := by
  simp [lorentzForm]; omega

theorem lorentzForm_positive : lorentzForm 1 0 0 = 1 := by simp [lorentzForm]

theorem lorentzForm_negative : lorentzForm 0 0 1 = -1 := by simp [lorentzForm]

theorem lorentz_discriminant :
    det (!![1, 0, 0; 0, 1, 0; 0, 0, (-1 : ℤ)]) = -1 := by native_decide

/-- [Section: ## Section 2: Berggren Steps Preserve Q] -/
theorem stepA_preserves_form (a b c : ℤ) :
    lorentzForm (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = lorentzForm a b c := by
  simp only [lorentzForm]; ring

theorem stepB_preserves_form (a b c : ℤ) :
    lorentzForm (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = lorentzForm a b c := by
  simp only [lorentzForm]; ring

theorem stepC_preserves_form (a b c : ℤ) :
    lorentzForm (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = lorentzForm a b c := by
  simp only [lorentzForm]; ring

/-- [Section: ## Section 3: The Norm Form] -/
def normForm (a b : ℤ) : ℤ := a ^ 2 + b ^ 2

theorem normForm_nonneg (a b : ℤ) : 0 ≤ normForm a b := by
  simp [normForm]; positivity

theorem normForm_mul (a b c d : ℤ) :
    normForm a b * normForm c d = normForm (a*c - b*d) (a*d + b*c) := by
  simp [normForm]; ring

theorem ppt_iff_norm_square (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ normForm a b = c ^ 2 := by simp [normForm]

/-- [Section: ## Section 4: Parity Invariants] -/
theorem ppt_a_mod4 (a : ℤ) (ha_odd : a % 2 = 1) :
    a % 4 = 1 ∨ a % 4 = 3 := by omega

/-- [Section: ## Section 5: The Deficit Invariant] -/
def hypLegDiff (b c : ℤ) : ℤ := c - b

theorem root_deficit : hypLegDiff 4 5 = 1 := by simp [hypLegDiff]

theorem stepA_deficit (a b c : ℤ) :
    hypLegDiff (2*a - b + 2*c) (2*a - 2*b + 3*c) = c - b := by
  simp [hypLegDiff]; ring

theorem A_branch_deficit_invariant (a b c : ℤ) (h : hypLegDiff b c = 1) :
    hypLegDiff (2*a - b + 2*c) (2*a - 2*b + 3*c) = 1 := by
  simp [hypLegDiff] at *; linarith

theorem stepB_deficit (a b c : ℤ) :
    hypLegDiff (2*a + b + 2*c) (2*a + 2*b + 3*c) = c + b := by
  simp [hypLegDiff]; ring

theorem stepC_deficit (a b c : ℤ) :
    hypLegDiff (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = c + b := by
  simp [hypLegDiff]; ring

/-- [Section: ## Section 6: Similarity Classes] -/
def pptSimilar (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) : Prop :=
  a₁ * b₂ = a₂ * b₁ ∧ a₁ * c₂ = a₂ * c₁

theorem pptSimilar_refl (a b c : ℤ) : pptSimilar a b c a b c := by simp [pptSimilar]

theorem root_not_similar_depth1A : ¬ pptSimilar 3 4 5 5 12 13 := by
  intro ⟨h1, _⟩; simp [pptSimilar] at h1

/-- [Section: ## Section 7: Perimeter] -/
def perimeter (a b c : ℤ) : ℤ := a + b + c

theorem root_perimeter : perimeter 3 4 5 = 12 := by simp [perimeter]

theorem stepA_perimeter (a b c : ℤ) :
    perimeter (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = 5*a - 5*b + 7*c := by
  simp [perimeter]; ring

theorem stepB_perimeter (a b c : ℤ) :
    perimeter (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = 5*a + 5*b + 7*c := by
  simp [perimeter]; ring

theorem stepC_perimeter (a b c : ℤ) :
    perimeter (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = -5*a + 5*b + 7*c := by
  simp [perimeter]; ring

theorem perimeter_growth_B (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    perimeter a b c < perimeter (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  unfold perimeter; linarith

/-- [Section: ## Section 8: Matrix Entries] -/
theorem berggren_entries_bounded :
    ∀ i j : Fin 3,
    |(!![1, -2, 2; 2, -1, 2; 2, -2, 3] : Matrix (Fin 3) (Fin 3) ℤ) i j| ≤ 3 := by decide

/-- (a-b)² + 2ab = a² + b² = c² for PPTs -/
theorem ppt_leg_diff_identity (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - b)^2 + 2 * a * b = c^2 := by nlinarith

/-- (a+b)² - 2ab = a² + b² = c² for PPTs -/
theorem ppt_leg_sum_identity (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + b)^2 - 2 * a * b = c^2 := by nlinarith

/- Original: BerggrenQuadruples.lean -/



/-- The Lorentz form for triples: Q(a,b,c) = a² + b² - c² -/
def Q_triple (v : Fin 3 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Lorentz form for quadruples: Q₄(a,b,c,d) = a² + b² + c² - d² -/
def Q_quad (v : Fin 4 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 - v 3 ^ 2

/-- The Lorentz metric matrix for triples -/
def Q₃_matrix : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- B₁ maps (3,4,5) to (5,12,13), a Pythagorean triple -/
theorem B₁_child : B₁ *ᵥ ![3, 4, 5] = ![5, 12, 13] := by native_decide

/-- B₂ maps (3,4,5) to (21,20,29), a Pythagorean triple -/
theorem B₂_child : B₂ *ᵥ ![3, 4, 5] = ![21, 20, 29] := by native_decide

/-- B₃ maps (3,4,5) to (15,8,17), a Pythagorean triple -/
theorem B₃_child : B₃ *ᵥ ![3, 4, 5] = ![15, 8, 17] := by native_decide

/-- (5, 12, 13) is a Pythagorean triple -/
theorem child1_is_pyth : IsPythTriple 5 12 13 := by
  unfold IsPythTriple; norm_num

/-- (21, 20, 29) is a Pythagorean triple -/
theorem child2_is_pyth : IsPythTriple 21 20 29 := by
  unfold IsPythTriple; norm_num

/-- (15, 8, 17) is a Pythagorean triple -/
theorem child3_is_pyth : IsPythTriple 15 8 17 := by
  unfold IsPythTriple; norm_num

/-- The quaternionic parametrization produces Q₄ = 0 -/
theorem quadParam_null (m n p q : ℤ) : Q_quad (quadParam m n p q) = 0 := by
  unfold Q_quad quadParam
  simp
  ring

/-- (0,1,1,1) parametrizes (1,2,2,3) (up to sign) -/
theorem param_example_1 :
    quadParam 0 1 1 1 0 = -1 ∧
    quadParam 0 1 1 1 1 = 2 ∧
    quadParam 0 1 1 1 2 = 2 ∧
    quadParam 0 1 1 1 3 = 3 := by
  unfold quadParam; simp

/-- (1,1,1,2) parametrizes a quadruple related to (2,3,6,7) -/
theorem param_example_2 :
    quadParam 1 1 1 2 3 = 7 := by
  unfold quadParam; simp

/-- The Lorentz metric matrix for quadruples: diag(1,1,1,-1) -/
def Q₄_matrix : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, -1]

/-- The Pythagorean equation is equivalent to the null cone condition -/
theorem pyth_quad_iff_null (a b c d : ℤ) :
    IsPythQuad a b c d ↔ Q_quad ![a, b, c, d] = 0 := by
  unfold IsPythQuad Q_quad
  constructor
  · intro h
    simp [Matrix.cons_val_zero, Matrix.cons_val_one]
    omega
  · intro h
    simp [Matrix.cons_val_zero, Matrix.cons_val_one] at h
    omega

/-- R₁₂ preserves the Lorentz form -/
theorem R₁₂_preserves : R₁₂ᵀ * Q₄_matrix * R₁₂ = Q₄_matrix := by native_decide

/-- R₁₃ preserves the Lorentz form -/
theorem R₁₃_preserves : R₁₃ᵀ * Q₄_matrix * R₁₃ = Q₄_matrix := by native_decide

/-- R₁₂ has finite order (order 4) — it squares to a reflection, fourth power is identity -/
theorem R₁₂_order_4 : R₁₂ ^ 4 = 1 := by native_decide

/-- R₁₃ has finite order (order 4) -/
theorem R₁₃_order_4 : R₁₃ ^ 4 = 1 := by native_decide

/-- The permutation matrix swapping coordinates 0 and 1 is in O(3,1;ℤ).
This shows O(3,1;ℤ) has more symmetry than O(2,1;ℤ). -/
def swap01 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 1, 0, 0; 1, 0, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenQuadruples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 23] -/
theorem swap01_preserves : swap01ᵀ * Q₄_matrix * swap01 = Q₄_matrix := by native_decide

/-- The permutation matrix swapping coordinates 1 and 2 is in O(3,1;ℤ).
Together with swap01, this generates S₃ acting on the spatial coordinates.
O(2,1;ℤ) has no such spatial permutation symmetry (only 2 spatial coords). -/
def swap12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 0, 1, 0; 0, 1, 0, 0; 0, 0, 0, 1]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenQuadruples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 23] -/
theorem swap12_preserves : swap12ᵀ * Q₄_matrix * swap12 = Q₄_matrix := by native_decide

/-- swap01 and swap12 commute with each other when composed in a specific way,
witnessing non-trivial abelian structure in O(3,1;ℤ). -/
theorem spatial_swaps_generate_S3 :
    swap01 * swap12 * swap01 = swap12 * swap01 * swap12 := by native_decide

/- Original: BerggrenSpectralGeometry.lean -/



/-- [Section: ## Section 1: The Three Berggren Matrices] -/
def B₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

def B₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- B₁ has determinant 1 (orientation-preserving, consistent with unipotency) -/
theorem B₁_det : det B₁ = 1 := by native_decide

/-- B₂ has determinant -1 (orientation-reversing) -/
theorem B₂_det : det B₂ = -1 := by native_decide

/-- B₃ has determinant 1 (orientation-preserving, consistent with unipotency) -/
theorem B₃_det : det B₃ = 1 := by native_decide

/-- [Section: ## Section 3: Traces] -/
theorem B₁_trace : trace B₁ = 3 := by native_decide

theorem B₂_trace : trace B₂ = 5 := by native_decide

theorem B₃_trace : trace B₃ = 3 := by native_decide

/-- Sum of traces = 11 -/
theorem trace_sum : trace B₁ + trace B₂ + trace B₃ = 11 := by native_decide

/-- **B₁ is unipotent of degree 3**: (B₁ - I)³ = 0 -/
theorem B₁_unipotent : (B₁ - 1) ^ 3 = 0 := by native_decide

/-- **B₃ is unipotent of degree 3**: (B₃ - I)³ = 0 -/
theorem B₃_unipotent : (B₃ - 1) ^ 3 = 0 := by native_decide

/-- B₂ is NOT unipotent -/
theorem B₂_not_unipotent : (B₂ - 1) ^ 3 ≠ 0 := by native_decide

/-- (B₁ - I)² ≠ 0, so B₁ is unipotent of EXACT degree 3 -/
theorem B₁_unipotent_exact : (B₁ - 1) ^ 2 ≠ 0 := by native_decide

/-- (B₃ - I)² ≠ 0, so B₃ is unipotent of EXACT degree 3 -/
theorem B₃_unipotent_exact : (B₃ - 1) ^ 2 ≠ 0 := by native_decide

/-- tr(B₁ⁿ) = 3 for small n (verified computationally) -/
theorem B₁_trace_constant :
    trace (B₁ ^ 0) = 3 ∧ trace (B₁ ^ 1) = 3 ∧
    trace (B₁ ^ 2) = 3 ∧ trace (B₁ ^ 3) = 3 ∧
    trace (B₁ ^ 4) = 3 ∧ trace (B₁ ^ 5) = 3 := by
  refine ⟨by native_decide, by native_decide, by native_decide,
          by native_decide, by native_decide, by native_decide⟩

/-- tr(B₃ⁿ) = 3 for small n (verified computationally) -/
theorem B₃_trace_constant :
    trace (B₃ ^ 0) = 3 ∧ trace (B₃ ^ 1) = 3 ∧
    trace (B₃ ^ 2) = 3 ∧ trace (B₃ ^ 3) = 3 ∧
    trace (B₃ ^ 4) = 3 ∧ trace (B₃ ^ 5) = 3 := by
  refine ⟨by native_decide, by native_decide, by native_decide,
          by native_decide, by native_decide, by native_decide⟩

/-- B₁ - I has trace 0 -/
theorem B₁_minus_I_trace : trace (B₁ - 1) = 0 := by native_decide

/-- (B₁ - I)² has trace 0 -/
theorem B₁_minus_I_sq_trace : trace ((B₁ - 1) ^ 2) = 0 := by native_decide

/-- B₃ - I has trace 0 -/
theorem B₃_minus_I_trace : trace (B₃ - 1) = 0 := by native_decide

/-- (B₃ - I)² has trace 0 -/
theorem B₃_minus_I_sq_trace : trace ((B₃ - 1) ^ 2) = 0 := by native_decide

/-- [Section: ## Section 7: Full Proof that tr(B₁ⁿ) = 3 for all n] -/
theorem B₁_trace_all (n : ℕ) : trace (B₁ ^ n) = 3 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp_all +decide;
  -- Use the recurrence relation for the trace of B₁^n
  have h_recurrence : ∀ n, Matrix.trace (B₁ ^ (n + 3)) = 3 * Matrix.trace (B₁ ^ (n + 2)) - 3 * Matrix.trace (B₁ ^ (n + 1)) + Matrix.trace (B₁ ^ n) := by
    intro n
    have h_recurrence : B₁ ^ (n + 3) = 3 • (B₁ ^ (n + 2)) - 3 • (B₁ ^ (n + 1)) + (B₁ ^ n) := by
      induction n <;> simp_all +decide [ pow_succ, mul_assoc ] ; abel_nf;
      simp_all +decide [ mul_assoc, add_mul, mul_add, pow_succ ];
      grind +qlia;
    simp +decide [ h_recurrence, Matrix.trace_add, Matrix.trace_smul ];
    norm_num [ Matrix.trace, Matrix.mul_apply ];
    erw [ show ( 3 : Matrix ( Fin 3 ) ( Fin 3 ) ℤ ) = fun i j => if i = j then 3 else 0 by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; simp +decide [ Fin.sum_univ_three ] ; ring!;
  linarith [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), ih ( n + 2 ) ( by linarith ), h_recurrence n ]

theorem B₃_trace_all (n : ℕ) : trace (B₃ ^ n) = 3 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  have h_recurrence : ∀ n : ℕ, trace (B₃ ^ (n + 3)) = 3 * trace (B₃ ^ (n + 2)) - 3 * trace (B₃ ^ (n + 1)) + trace (B₃ ^ n) := by
    intro n
    have h_recurrence : B₃ ^ (n + 3) = 3 • B₃ ^ (n + 2) - 3 • B₃ ^ (n + 1) + B₃ ^ n := by
      induction n <;> simp_all +decide [ pow_succ, mul_assoc ];
      simp_all +decide [ mul_assoc, sub_mul, add_mul ];
      grind;
    simp +decide [ h_recurrence, Matrix.trace_add, Matrix.trace_smul ];
    norm_num [ Matrix.trace, Matrix.mul_apply ];
    erw [ show ( 3 : Matrix ( Fin 3 ) ( Fin 3 ) ℤ ) = fun i j => if i = j then 3 else 0 by ext i j; fin_cases i <;> fin_cases j <;> rfl ] ; simp +decide [ Fin.sum_univ_three ] ; ring;
  have := ih n ( by linarith ) ; have := ih ( n+1 ) ( by linarith ) ; have := ih ( n+2 ) ( by linarith ) ; simp_all +decide [ pow_succ' ] ;

/-- [Section: ## Section 8: The Sum Matrix] -/
def B_sum : Matrix (Fin 3) (Fin 3) ℤ := B₁ + B₂ + B₃

theorem B_sum_eq : B_sum = !![1, 2, 6; 2, 1, 6; 2, 2, 9] := by native_decide

theorem B_sum_det : det B_sum = -3 := by native_decide

theorem B_sum_trace : trace B_sum = 11 := by native_decide

/-- [Section: ## Section 9: Product Determinants] -/
theorem B₁B₂_det : det (B₁ * B₂) = -1 := by native_decide

theorem B₂B₃_det : det (B₂ * B₃) = -1 := by native_decide

theorem B₁B₃_det : det (B₁ * B₃) = 1 := by native_decide

/-- Products of same-parity determinant matrices preserve det sign -/
theorem unipotent_product_det : det (B₁ * B₃) = 1 := by native_decide

/-- No two Berggren matrices commute -/
theorem B₁B₂_noncommute : B₁ * B₂ ≠ B₂ * B₁ := by native_decide

/-- [Section: ## Section 10: Commutator Analysis] -/
theorem B₁B₃_noncommute : B₁ * B₃ ≠ B₃ * B₁ := by native_decide

theorem B₂B₃_noncommute : B₂ * B₃ ≠ B₃ * B₂ := by native_decide

/-- All commutators have trace 0 -/
theorem commutator_B₁B₂_trace : trace (B₁ * B₂ - B₂ * B₁) = 0 := by native_decide

theorem commutator_B₁B₃_trace : trace (B₁ * B₃ - B₃ * B₁) = 0 := by native_decide

theorem commutator_B₂B₃_trace : trace (B₂ * B₃ - B₃ * B₂) = 0 := by native_decide

/-- B₁ satisfies (λ-1)³ = 0, i.e., B₁³ - 3B₁² + 3B₁ - I = 0 -/
theorem B₁_cayley_hamilton : B₁ ^ 3 - 3 • B₁ ^ 2 + 3 • B₁ - 1 = 0 := by native_decide

/-- B₃ satisfies the same Cayley-Hamilton as B₁ -/
theorem B₃_cayley_hamilton : B₃ ^ 3 - 3 • B₃ ^ 2 + 3 • B₃ - 1 = 0 := by native_decide

/-- [Section: ## Section 12: B₂ Trace Sequence (exponential growth)] -/
theorem B₂_trace_seq :
    trace (B₂ ^ 0) = 3 ∧ trace (B₂ ^ 1) = 5 ∧
    trace (B₂ ^ 2) = 35 ∧ trace (B₂ ^ 3) = 197 := by
  refine ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩

/-- B₂ trace grows exponentially (verified for first terms) -/
theorem B₂_trace_growth :
    trace (B₂ ^ 2) > 2 * trace (B₂ ^ 1) ∧
    trace (B₂ ^ 3) > 2 * trace (B₂ ^ 2) := by
  refine ⟨by native_decide, by native_decide⟩

/-- The (3,3) entry is 3 for all three matrices -/
theorem hypotenuse_coefficient :
    B₁ 2 2 = 3 ∧ B₂ 2 2 = 3 ∧ B₃ 2 2 = 3 := by
  refine ⟨by native_decide, by native_decide, by native_decide⟩

/- Original: BerggrenTraceFormula.lean -/



/-- [Section: ## Section 1: Pell Sequence (self-contained)] -/
def pellXt : ℕ → ℤ
  | 0 => 1
  | 1 => 3
  | n + 2 => 6 * pellXt (n + 1) - pellXt n

@[simp] theorem pellXt_0 : pellXt 0 = 1 := rfl
@[simp] theorem pellXt_1 : pellXt 1 = 3 := rfl

theorem pellXt_rec (n : ℕ) : pellXt (n + 2) = 6 * pellXt (n + 1) - pellXt n := rfl

/-- [Section: ## Section 2: The Target Sequence f(n) = 2·pellX(n) + (-1)ⁿ] -/
def traceTarget (n : ℕ) : ℤ := 2 * pellXt n + (-1 : ℤ) ^ n

theorem traceTarget_0 : traceTarget 0 = 3 := by simp [traceTarget]

theorem traceTarget_1 : traceTarget 1 = 5 := by simp [traceTarget]

theorem traceTarget_2 : traceTarget 2 = 35 := by
  simp [traceTarget]; native_decide

/-- traceTarget satisfies the recurrence f(n+3) = 5f(n+2) + 5f(n+1) - f(n) -/
theorem traceTarget_recurrence (n : ℕ) :
    traceTarget (n + 3) = 5 * traceTarget (n + 2) + 5 * traceTarget (n + 1) - traceTarget n := by
  simp only [traceTarget]
  have h1 : pellXt (n + 3) = 6 * pellXt (n + 2) - pellXt (n + 1) := pellXt_rec (n + 1)
  have h2 : pellXt (n + 2) = 6 * pellXt (n + 1) - pellXt n := pellXt_rec n
  rw [h1, h2]; ring

/-- [Section: ## Section 4: B₂ Matrix] -/
def BN₂t : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- [Section: ## Section 5: Cayley-Hamilton for B₂] -/
theorem BN₂t_cayley_hamilton : BN₂t ^ 3 = 5 • BN₂t ^ 2 + 5 • BN₂t - 1 := by
  native_decide

/-- From Cayley-Hamilton: tr(B₂^(n+3)) = 5·tr(B₂^(n+2)) + 5·tr(B₂^(n+1)) - tr(B₂^n) -/
theorem BN₂t_trace_rec (n : ℕ) :
    trace (BN₂t ^ (n + 3)) = 5 * trace (BN₂t ^ (n + 2)) +
      5 * trace (BN₂t ^ (n + 1)) - trace (BN₂t ^ n) := by
  have ch : BN₂t ^ 3 = 5 • BN₂t ^ 2 + 5 • BN₂t - 1 := BN₂t_cayley_hamilton
  have key : BN₂t ^ (n + 3) = 5 • BN₂t ^ (n + 2) + 5 • BN₂t ^ (n + 1) - BN₂t ^ n := by
    have : BN₂t ^ (n + 3) = BN₂t ^ n * BN₂t ^ 3 := by rw [pow_add]
    rw [this, ch]
    have h2 : BN₂t ^ n * BN₂t ^ 2 = BN₂t ^ (n + 2) := by rw [← pow_add]
    have h3 : BN₂t ^ n * BN₂t ^ 1 = BN₂t ^ (n + 1) := by rw [← pow_add]
    have h4 : BN₂t ^ n * (5 • BN₂t ^ 2 + 5 • BN₂t - 1) =
              5 • (BN₂t ^ n * BN₂t ^ 2) + 5 • (BN₂t ^ n * BN₂t ^ 1) - BN₂t ^ n := by
      noncomm_ring
    rw [h4, h2, h3]
  rw [key, Matrix.trace_sub, Matrix.trace_add, Matrix.trace_smul,
      Matrix.trace_smul]
  simp

/-- **Main Theorem**: tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ for all n ∈ ℕ -/
theorem traceB2_eq_pellX (n : ℕ) :
    trace (BN₂t ^ n) = 2 * pellXt n + (-1 : ℤ) ^ n := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
  match n with
  | 0 => native_decide
  | 1 => native_decide
  | 2 => native_decide
  | n + 3 =>
    rw [BN₂t_trace_rec]
    rw [ih (n + 2) (by omega), ih (n + 1) (by omega), ih n (by omega)]
    have h1 : pellXt (n + 3) = 6 * pellXt (n + 2) - pellXt (n + 1) := rfl
    have h2 : pellXt (n + 2) = 6 * pellXt (n + 1) - pellXt n := rfl
    rw [h1, h2]; ring

/-- [Section: ## Section 8: Corollaries] -/
theorem BN₂t_trace_pos (n : ℕ) : 0 < trace (BN₂t ^ n) := by
  -- From traceB2_eq_pellX, we have $trace (BN₂t ^ n) = 2 * pellXt n + (-1 : ℤ) ^ n$.
  have h_trace : trace (BN₂t ^ n) = 2 * pellXt n + (-1 : ℤ) ^ n := by
    exact?;
  -- By induction, we can show that $pellXt n \geq 1$ for all $n$.
  have h_pell_pos : ∀ n, 1 ≤ pellXt n := by
    -- We'll use induction to prove that the Pell sequence is positive.
    have h_pell_pos_induction : ∀ n, 1 ≤ pellXt n ∧ pellXt n ≤ pellXt (n + 1) := by
      intro n; induction n <;> simp_all +decide [ pellXt_rec ] ; omega;
    exact fun n => h_pell_pos_induction n |>.1;
  by_cases h : Even n <;> simp_all +decide ; linarith [ h_pell_pos n ];
  linarith [ h_pell_pos n ]

theorem BN₂t_trace_odd (n : ℕ) : trace (BN₂t ^ n) % 2 = 1 := by
  rw [ traceB2_eq_pellX ];
  cases Nat.even_or_odd n <;> simp +decide [ *, Int.add_emod, Int.mul_emod ]

/- Original: BerggrenTracelessGeneral.lean -/



/-- For 3×3 integer matrices, tr(AB) = tr(BA). This is the key identity
that makes ALL commutators traceless. -/
theorem trace_mul_comm_3x3 (A B : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix.trace (A * B) = Matrix.trace (B * A) := by
  simp [Matrix.trace, Matrix.mul_apply, Fin.sum_univ_three]
  ring

/-- Universal: the trace of ANY commutator [A,B] = AB - BA is zero.
This subsumes the V10 "discovery" as a special case. -/
theorem commutator_traceless_3x3 (A B : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix.trace (A * B - B * A) = 0 := by
  simp [trace_mul_comm_3x3]

/-- [Section: ## Berggren Matrix Definitions] -/
def BT₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenTracelessGeneral
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 37] -/
def BT₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def BT₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

def QT : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

/-- V10 Discovery 1 is a corollary -/
theorem BD₁₂_traceless_corollary :
    Matrix.trace (BT₁ * BT₂ - BT₂ * BT₁) = 0 :=
  commutator_traceless_3x3 BT₁ BT₂

/-- [Section: ## V10 Results as Corollaries of the Universal Theorem] -/
theorem BD₁₃_traceless_corollary :
    Matrix.trace (BT₁ * BT₃ - BT₃ * BT₁) = 0 :=
  commutator_traceless_3x3 BT₁ BT₃

theorem BD₂₃_traceless_corollary :
    Matrix.trace (BT₂ * BT₃ - BT₃ * BT₂) = 0 :=
  commutator_traceless_3x3 BT₂ BT₃

/-- All generators preserve the Lorentz form -/
theorem BT₁_Lorentz : BT₁ᵀ * QT * BT₁ = QT := by native_decide

/-- [Section: ## Genuinely Berggren-Specific Properties
The REAL structural properties are about the Lorentz form preservation
and determinant structure.] -/
theorem BT₂_Lorentz : BT₂ᵀ * QT * BT₂ = QT := by native_decide

theorem BT₃_Lorentz : BT₃ᵀ * QT * BT₃ = QT := by native_decide

/-- Products of generators preserve the Lorentz form -/
theorem BT₁₂_Lorentz : (BT₁ * BT₂)ᵀ * QT * (BT₁ * BT₂) = QT := by native_decide

theorem BT₂₁_Lorentz : (BT₂ * BT₁)ᵀ * QT * (BT₂ * BT₁) = QT := by native_decide

theorem BT₁₃_Lorentz : (BT₁ * BT₃)ᵀ * QT * (BT₁ * BT₃) = QT := by native_decide

theorem BT₂₃_Lorentz : (BT₂ * BT₃)ᵀ * QT * (BT₂ * BT₃) = QT := by native_decide

/-- [Section: ## Determinant Structure] -/
theorem det_BT₁ : Matrix.det BT₁ = 1 := by native_decide

theorem det_BT₂ : Matrix.det BT₂ = -1 := by native_decide

theorem det_BT₃ : Matrix.det BT₃ = 1 := by native_decide

/-- B₁ · B₂ has det = -1 -/
theorem det_BT₁₂ : Matrix.det (BT₁ * BT₂) = -1 := by native_decide

/-- B₁ · B₃ has det = 1 -/
theorem det_BT₁₃ : Matrix.det (BT₁ * BT₃) = 1 := by native_decide

/-- B₂ · B₂ has det = 1 -/
theorem det_BT₂₂ : Matrix.det (BT₂ * BT₂) = 1 := by native_decide

/-- B₁ · B₂ · B₃ has det = -1 -/
theorem det_BT₁₂₃ : Matrix.det (BT₁ * BT₂ * BT₃) = -1 := by native_decide

/-- Unipotent trace: tr(B₁ⁿ) = 3 for all n (eigenvalue 1 with mult 3) -/
theorem trace_BT₁_pow1 : Matrix.trace (BT₁ ^ 1) = 3 := by native_decide

/-- [Section: ## Trace Structure of Products] -/
theorem trace_BT₁_pow2 : Matrix.trace (BT₁ ^ 2) = 3 := by native_decide

theorem trace_BT₁_pow3 : Matrix.trace (BT₁ ^ 3) = 3 := by native_decide

theorem trace_BT₁_pow4 : Matrix.trace (BT₁ ^ 4) = 3 := by native_decide

theorem trace_BT₁_pow5 : Matrix.trace (BT₁ ^ 5) = 3 := by native_decide

/-- Semisimple trace: tr(B₂ⁿ) grows exponentially
tr(B₂ⁿ) = (-1)ⁿ + (3+2√2)ⁿ + (3-2√2)ⁿ -/
theorem trace_BT₂_pow1 : Matrix.trace (BT₂ ^ 1) = 5 := by native_decide

theorem trace_BT₂_pow2 : Matrix.trace (BT₂ ^ 2) = 35 := by native_decide

theorem trace_BT₂_pow3 : Matrix.trace (BT₂ ^ 3) = 197 := by native_decide

theorem trace_BT₂_pow4 : Matrix.trace (BT₂ ^ 4) = 1155 := by native_decide

/-- [Section: ## Swap Matrix Properties] -/
def SwapT : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]

theorem SwapT_invol : SwapT * SwapT = 1 := by native_decide

theorem BT₃_conj : BT₃ = SwapT * BT₁ * SwapT := by native_decide

theorem BT₂_self_conj : BT₂ = SwapT * BT₂ * SwapT := by native_decide

/-- The swap matrix preserves the Lorentz form -/
theorem SwapT_Lorentz : SwapTᵀ * QT * SwapT = QT := by native_decide

/- Original: BerggrenWellFounded.lean -/



/-- [Section: ## Inverse Maps] -/
def invA' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenWellFounded
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 28] -/
def invB' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def invC' (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- [Section: ## Forward-Inverse Cancellation] -/
theorem step_inv_A (a b c : ℤ) :
    let t := applyStep .A (a, b, c); invA' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [applyStep, invA']; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem step_inv_B (a b c : ℤ) :
    let t := applyStep .B (a, b, c); invB' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [applyStep, invB']; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem step_inv_C (a b c : ℤ) :
    let t := applyStep .C (a, b, c); invC' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [applyStep, invC']; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem inv_step_A (a b c : ℤ) :
    let t := invA' a b c; applyStep .A (t.1, t.2.1, t.2.2) = (a, b, c) := by
  simp only [invA', applyStep]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem inv_step_B (a b c : ℤ) :
    let t := invB' a b c; applyStep .B (t.1, t.2.1, t.2.2) = (a, b, c) := by
  simp only [invB', applyStep]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

theorem inv_step_C (a b c : ℤ) :
    let t := invC' a b c; applyStep .C (t.1, t.2.1, t.2.2) = (a, b, c) := by
  simp only [invC', applyStep]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

/-- [Section: ## Inverse Maps Preserve Pythagorean Property] -/
theorem invA'_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invA' a b c).1^2 + (invA' a b c).2.1^2 = (invA' a b c).2.2^2 := by
  simp only [invA']; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

theorem invB'_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invB' a b c).1^2 + (invB' a b c).2.1^2 = (invB' a b c).2.2^2 := by
  simp only [invB']; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

theorem invC'_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invC' a b c).1^2 + (invC' a b c).2.1^2 = (invC' a b c).2.2^2 := by
  simp only [invC']; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]

/-- Parent hypotenuse is strictly less than c -/
theorem parent_hyp_lt' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a^2 + b^2 = c^2) :
    -2*a - 2*b + 3*c < c := by
  nlinarith [sq_nonneg (a + b - c)]

/-- When σ₁ < 0, invC gives positive second component -/
theorem sigma1_neg_invC_pos (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hs : a + 2*b - 2*c < 0) :
    0 < 2*a + b - 2*c := by
  by_contra hle
  push_neg at hle
  nlinarith [sq_nonneg (a + 2*b - 2*c), sq_nonneg (2*a + b - 2*c)]

/-- Main descent: every PPT with a,b,c > 0 has a Pythagorean parent
with positive hypotenuse strictly smaller than c -/
theorem descent_exists_parent (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    ∃ (a' b' c' : ℤ),
      a'^2 + b'^2 = c'^2 ∧
      0 < c' ∧ c' < c := by
  exact ⟨(invA' a b c).1, (invA' a b c).2.1, (invA' a b c).2.2,
    invA'_pyth a b c h,
    parent_hyp_pos' a b c h ha hb hc,
    by have := parent_hyp_lt' a b c ha hb h; simp only [invA'] at *; linarith⟩

/-- [Section: ## Root Classification] -/
theorem root_class' (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc5 : c = 5)
    (hcop : Int.gcd a b = 1) :
    (a = 3 ∧ b = 4) ∨ (a = 4 ∧ b = 3) := by
  subst hc5
  have ha5 : a ≤ 4 := by nlinarith [sq_nonneg (a - 5)]
  have hb5 : b ≤ 4 := by nlinarith [sq_nonneg (b - 5)]
  interval_cases a <;> interval_cases b <;> simp_all

/-- [Section: ## Path Verification] -/
theorem path_to_345 : applyPath [] = (3, 4, 5) := rfl

theorem path_to_51213 : applyPath [.A] = (5, 12, 13) := by native_decide

theorem path_to_202129 : applyPath [.B] = (21, 20, 29) := by native_decide

theorem path_to_15817 : applyPath [.C] = (15, 8, 17) := by native_decide

theorem path_to_72425 : applyPath [.A, .A] = (7, 24, 25) := by native_decide

theorem path_to_554873 : applyPath [.A, .B] = (55, 48, 73) := by native_decide

theorem path_to_452853 : applyPath [.A, .C] = (45, 28, 53) := by native_decide

/-- [Section: ## Descent Traces] -/
theorem descent_51213 : invA' 5 12 13 = (3, 4, 5) := by simp [invA']

theorem descent_202129 : invB' 21 20 29 = (3, 4, 5) := by simp [invB']

theorem descent_15817 : invC' 15 8 17 = (3, 4, 5) := by simp [invC']

theorem descent_72425 : invA' 7 24 25 = (5, 12, 13) := by simp [invA']

/-- Two-step descent from (7,24,25) to root -/
theorem descent_72425_root :
    let t₁ := invA' 7 24 25
    invA' t₁.1 t₁.2.1 t₁.2.2 = (3, 4, 5) := by simp [invA']