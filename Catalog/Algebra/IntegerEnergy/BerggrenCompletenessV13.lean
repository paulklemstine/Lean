import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenCompletenessV13

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 30
-/

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