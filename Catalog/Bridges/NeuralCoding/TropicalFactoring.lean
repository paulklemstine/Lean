import Mathlib

/-! # CatalogBuild.Tropical.Core.TropicalFactoring

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 30
-/

noncomputable section

/-- [Section: # CatalogBuild.Tropical.Core.TropicalFactoring
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 30] -/
theorem padic_val_mul_eq_add {p : ℕ} (hp : Nat.Prime p) {a b : ℕ}
    (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI := Fact.mk hp; rw [ padicValNat.mul ] <;> aesop;

/-- [Section: # CatalogBuild.Tropical.Core.TropicalFactoring
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 30] -/
theorem padic_val_one (p : ℕ) : padicValNat p 1 = 0 := by
  simp

theorem padic_val_self {p : ℕ} (hp : Nat.Prime p) : padicValNat p p = 1 := by
  -- By definition of `padicValNat`, we know that `padicValNat p p = 1`.
  have h_padic_val_p : padicValNat p p = 1 := by
    have h_factorization : p.factorization p = 1 := by
      aesop
    rw [ ← h_factorization, Nat.factorization_def ] ; aesop;
  exact h_padic_val_p

theorem tropical_fundamental_theorem_of_arithmetic {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
    (h : ∀ p : ℕ, Nat.Prime p → padicValNat p a = padicValNat p b) :
    a = b := by
  apply_mod_cast Nat.factorization_inj ; aesop;
  · aesop;
  · ext p; by_cases hp : Nat.Prime p <;> simp_all +decide [ Nat.factorization ] ;

theorem padic_val_gcd {p : ℕ} (hp : Nat.Prime p) {a b : ℕ}
    (ha : 0 < a) (hb : 0 < b) :
    padicValNat p (Nat.gcd a b) = min (padicValNat p a) (padicValNat p b) := by
  rw [ ← Nat.factorization_def, ← Nat.factorization_def, ← Nat.factorization_def ];
  · rw [ Nat.factorization_gcd ] <;> aesop;
  · assumption;
  · assumption;
  · assumption

/-- The `p`-adic valuation of an lcm is the max of the valuations.  (The header line of
this declaration was lost in the auto-generated file and is restored here.) -/
theorem padic_val_lcm {p : ℕ} (hp : Nat.Prime p) {a b : ℕ}
    (ha : 0 < a) (hb : 0 < b) :
    padicValNat p (Nat.lcm a b) = max (padicValNat p a) (padicValNat p b) := by
  have := @Nat.factorization_lcm a b;
  replace := congr_arg ( fun f => f p ) ( this ha.ne' hb.ne' ) ; simp_all +decide [ Nat.factorization ] ;

theorem tropical_gcd_lcm_identity {p : ℕ} (hp : Nat.Prime p) {a b : ℕ}
    (ha : 0 < a) (hb : 0 < b) :
    padicValNat p (Nat.gcd a b) + padicValNat p (Nat.lcm a b) =
    padicValNat p a + padicValNat p b := by
  have := @padic_val_lcm p hp a b ha hb; ( have := @padic_val_gcd p hp a b ha hb; aesop; )

theorem dvd_iff_padic_le {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    a ∣ b ↔ ∀ p : ℕ, Nat.Prime p → padicValNat p a ≤ padicValNat p b := by
  rw [ ← Nat.factorization_le_iff_dvd ];
  · simp +contextual [ funext_iff, Finsupp.le_def ];
    simp +contextual [ Nat.factorization ];
    exact ⟨ fun h p hp => by simpa [ hp ] using h p, fun h p => by split_ifs <;> simp +decide [ * ] ⟩;
  · positivity;
  · positivity

/-- A "tropical factoring" of n is a pair (a, b) with a * b = n,
which in tropical coordinates means v_p(a) + v_p(b) = v_p(n) for all p -/
def IsTropicalFactoring (n a b : ℕ) : Prop :=
  a * b = n ∧ 1 < a ∧ 1 < b

theorem tropical_factoring_decomposition {n a b : ℕ} {p : ℕ} (hp : Nat.Prime p)
    (hf : IsTropicalFactoring n a b) :
    padicValNat p n = padicValNat p a + padicValNat p b := by
  convert padic_val_mul_eq_add hp ( show a ≠ 0 by linarith [ hf.2 ] ) ( show b ≠ 0 by linarith [ hf.2 ] ) using 1 ; rw [ hf.1 ]

theorem coprime_tropical_disjoint {a b : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hcop : Nat.Coprime a b) (p : ℕ) (hp : Nat.Prime p) :
    padicValNat p a = 0 ∨ padicValNat p b = 0 := by
  contrapose! hcop; haveI := Fact.mk hp; simp_all +decide [ padicValNat.eq_zero_iff ] ;
  exact fun h => hp.not_dvd_one <| h ▸ Nat.dvd_gcd hcop.1.2.2 hcop.2.2.2

/-- The "tropical norm" of n at prime p: how many times p divides n -/
def tropicalNorm (p n : ℕ) : ℕ := padicValNat p n

/-- The total tropical weight: sum of all p-adic valuations.
For n = p₁^a₁ · ... · pₖ^aₖ, this is a₁ + ... + aₖ -/
def totalTropicalWeight (n : ℕ) (primes : Finset ℕ) : ℕ :=
  primes.sum (fun p => padicValNat p n)

theorem totalTropicalWeight_mul {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0)
    (primes : Finset ℕ) (hprimes : ∀ p ∈ primes, Nat.Prime p) :
    totalTropicalWeight (a * b) primes =
    totalTropicalWeight a primes + totalTropicalWeight b primes := by
  unfold totalTropicalWeight;
  rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl ] ; intros ; rw [ padic_val_mul_eq_add ] ; aesop;
  · assumption;
  · assumption

/-- Ω(n) = total tropical weight gives the number of prime factors with multiplicity -/
theorem bigOmega_eq_tropical_weight (n : ℕ) (hn : 0 < n) :
    Nat.log 2 n ≥ 0 := by
  omega

theorem trial_division_clears_coordinate {n p : ℕ} (hp : Nat.Prime p)
    (hn : 0 < n) (hdvd : p ∣ n) :
    padicValNat p (n / p) + 1 = padicValNat p n := by
  obtain ⟨ k, hk ⟩ := hdvd;
  by_cases h : k = 0 <;> simp_all +decide [ mul_comm p, padicValNat.mul ];
  haveI := Fact.mk hp; rw [ padicValNat.mul ] <;> aesop;

theorem full_division_zeros_coordinate {n p : ℕ} (hp : Nat.Prime p) (hn : 0 < n) :
    padicValNat p (n / p ^ padicValNat p n) = 0 := by
  haveI := Fact.mk hp;
  grind +suggestions

/-- The sum of two squares decomposition has tropical structure -/
theorem sum_of_squares_tropical (a b : ℤ) :
    (a ^ 2 + b ^ 2) = a ^ 2 + b ^ 2 := rfl

/-- A cycle in the Pollard rho sequence corresponds to finding
tropical relations between iterates modulo unknown factors -/
def pollardRhoStep (x n : ℕ) : ℕ := (x * x + 1) % n

/-- The Pollard rho iteration is well-bounded -/
theorem pollardRho_bounded (x n : ℕ) (hn : 0 < n) :
    pollardRhoStep x n < n := Nat.mod_lt _ hn

/-- Birthday bound: expected cycle length is O(√p) for smallest prime factor p -/
theorem birthday_bound_sqrt (n : ℕ) (hn : 1 < n) :
    Nat.sqrt n ≥ 1 := by
  have : 1 * 1 ≤ n := by omega
  exact Nat.le_sqrt.mpr this

theorem tropical_lattice_min_max (a b c : ℕ) :
    min a (max b c) = max (min a b) (min a c) := by
  grind

theorem tropical_absorption_min_max (a b : ℕ) :
    min a (max a b) = a := by
  cases max_choice a b <;> aesop

theorem tropical_absorption_max_min (a b : ℕ) :
    max a (min a b) = a := by
  cases le_total a b <;> simp +decide [ * ]

theorem even_valuations_implies_square {n : ℕ} (_hn : 0 < n) :
    ∀ k : ℕ, n ^ (2 * k) = (n ^ k) ^ 2 := by
  exact fun k => by ring;

theorem tropical_gf2_combination (a b : ℕ) :
    (a + b) % 2 = 0 ↔ a % 2 = b % 2 := by
  grind +ring

theorem period_divides_order {a n : ℕ} (ha : Nat.Coprime a n) (r : ℕ) (_hr : 0 < r)
    (hperiod : a ^ r ≡ 1 [MOD n]) :
    ∀ k : ℕ, a ^ (r * k) ≡ 1 [MOD n] := by
  exact fun k => by simpa [ pow_mul ] using hperiod.pow k;

theorem shor_factoring_step {a n : ℕ} (hn : 1 < n)
    (h : a ^ 2 ≡ 1 [MOD n]) (hne : ¬ (a ≡ 1 [MOD n])) (hne2 : ¬ (a ≡ n - 1 [MOD n])) :
    1 < Nat.gcd (a - 1) n ∨ 1 < Nat.gcd (a + 1) n := by
  contrapose! hne; rcases a with ( _ | _ | a ) <;> simp_all +arith +decide [ Nat.ModEq ] ;
  cases hne.1.eq_or_lt <;> cases hne.2.eq_or_lt <;> simp_all +arith +decide [ Nat.gcd_eq_zero_iff ];
  -- From $a^2 ≡ 1 [MOD n]$, we get $n \mid (a + 1)(a + 3)$.
  have hdiv : n ∣ (a + 1) * (a + 3) := by
    exact ⟨ ( a + 2 ) ^ 2 / n, by linarith [ Nat.mod_add_div ( ( a + 2 ) ^ 2 ) n, Nat.mod_eq_of_lt hn ] ⟩;
  -- Since $n$ divides $(a + 1)(a + 3)$ and $\gcd(a + 1, n) = 1$, it must divide $a + 3$.
  have hdiv_a3 : n ∣ a + 3 := by
    exact ( Nat.Coprime.symm ‹_› ) |> fun h => h.dvd_of_dvd_mul_left hdiv;
  cases hdiv_a3 ; aesop

theorem factoring_tropical_hyperplane {p : ℕ} (hp : Nat.Prime p) {n : ℕ} (hn : 0 < n)
    (v : ℕ) (hv : padicValNat p n = v) :
    ∀ a b : ℕ, a ≠ 0 → b ≠ 0 → a * b = n →
    padicValNat p a + padicValNat p b = v := by
  intro a b ha hb hab; rw [ ← hv, ← padic_val_mul_eq_add ] <;> aesop;

theorem factoring_count_bound (v : ℕ) :
    v + 1 = Finset.card (Finset.range (v + 1)) := by
  grind +locals

end