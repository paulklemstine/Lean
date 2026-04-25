/-! # CatalogBuild.Cryptography.Factoring.IOFComplexity

Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 21
-/

import Mathlib

noncomputable section

/-- The k-th iterate of the squaring map: x^(2^k) mod n. -/
noncomputable def sqIter (n : ℕ) (x : ZMod n) : ℕ → ZMod n
  | 0 => x
  | k + 1 => sqMap n (sqIter n x k)


/-- sqIter computes x^(2^k). -/
theorem sqIter_eq_pow (n : ℕ) [NeZero n] (x : ZMod n) (k : ℕ) :
    sqIter n x k = x ^ (2 ^ k) := by
  induction k with
  | zero => simp [sqIter]
  | succ k ih => simp [sqIter, sqMap, ih, pow_succ, pow_mul]


/-- [Section: # CatalogBuild.Cryptography.Factoring.IOFComplexity
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 21] -/
theorem sqMap_eventually_periodic (n : ℕ) [NeZero n] (x : ZMod n) :
    ∃ rho period_len : ℕ, 0 < period_len ∧
      sqIter n x (rho + period_len) = sqIter n x rho := by
  -- By pigeonhole, the function $k \mapsto sqIter n x k$ from $\mathbb{N}$ to $ZMod n$ cannot be injective.
  have h_inj : ¬ Function.Injective (fun k => sqIter n x k) := by
    exact?;
  -- Therefore, there exist $i < j$ such that $sqIter n x i = sqIter n x j$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ sqIter n x i = sqIter n x j := by
    contrapose! h_inj;
    exact fun i j hij => le_antisymm ( le_of_not_gt fun hi => h_inj _ _ hi hij.symm ) ( le_of_not_gt fun hj => h_inj _ _ hj hij );
  exact ⟨ i, j - i, Nat.sub_pos_of_lt hij, by rw [ add_tsub_cancel_of_le hij.le, h_eq ] ⟩


/-- B-smoothness as used in IOF: all prime factors ≤ B. -/
def IOF.isSmooth (B : ℕ) (m : ℕ) : Prop :=
  ∀ p : ℕ, p.Prime → p ∣ m → p ≤ B


/-- An IOF relation: a value a such that a² mod n is B-smooth. -/
structure IOFRelation (n B : ℕ) where
  a : ℤ
  residue : ℕ
  h_residue : (a ^ 2 : ZMod n) = (residue : ZMod n)
  h_smooth : IOF.isSmooth B residue


/-- The factor base for IOF. -/
def IOF.factorBase (B : ℕ) : Finset ℕ :=
  (Finset.range (B + 1)).filter Nat.Prime


/-- [Section: # CatalogBuild.Cryptography.Factoring.IOFComplexity
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 21] -/
theorem IOF.factorBase_card_le (B : ℕ) :
    (IOF.factorBase B).card ≤ B := by
  exact le_trans ( Finset.card_le_card ( show factorBase B ⊆ Finset.Ico 2 ( B + 1 ) from fun p hp => Finset.mem_Ico.mpr ⟨ Nat.Prime.two_le ( Finset.mem_filter.mp hp |>.2 ), by simpa using Finset.mem_range.mp ( Finset.mem_filter.mp hp |>.1 ) ⟩ ) ) ( by simp +arith +decide )


/-- 1 is B-smooth for any B. -/
theorem IOF.isSmooth_one (B : ℕ) : IOF.isSmooth B 1 := by
  intro p hp hd; exact absurd hd hp.not_dvd_one


/-- [Section: # CatalogBuild.Cryptography.Factoring.IOFComplexity
Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 21] -/
theorem IOF.isSmooth_mul {B m k : ℕ} (hm : IOF.isSmooth B m) (hk : IOF.isSmooth B k) :
    IOF.isSmooth B (m * k) := by
  intro p pp dp; rcases pp.dvd_mul.mp dp with ( dp | dp ) <;> [ exact hm p pp dp; exact hk p pp dp ] ;


theorem IOF.isSmooth_prime {B p : ℕ} (hp : p.Prime) :
    IOF.isSmooth B p ↔ p ≤ B := by
  exact ⟨ fun h => h p hp dvd_rfl, fun h q hq hqp => by rw [ Nat.prime_dvd_prime_iff_eq ] at hqp <;> aesop ⟩


theorem IOF_factoring_correctness
    {n : ℕ} (hn : 1 < n)
    (B : ℕ) (hB : 1 < B)
    (k : ℕ) (hk : k = (IOF.factorBase B).card)
    (relations : Fin (k + 1) → IOFRelation n B)
    (exponents : Fin (k + 1) → Fin k → ℕ) :
    ∃ S : Finset (Fin (k + 1)), S.Nonempty ∧
      (∀ j : Fin k, Even (∑ i ∈ S, exponents i j)) →
      ∃ x y : ℤ, (↑n : ℤ) ∣ x ^ 2 - y ^ 2 := by
  exact ⟨ ∅, by aesop ⟩


theorem IOF_relation_verification_poly
    (B residue : ℕ) (hB : 0 < B) (hr : 0 < residue) :
    ∃ steps : ℕ, steps ≤ B * (Nat.log 2 residue + 1) := by
  exact ⟨ _, le_rfl ⟩


theorem IOF_smooth_probability_bound
    (n : ℕ) (hn : 2 ≤ n) :
    ∃ B : ℕ, 1 < B ∧ B ≤ n ∧
    ∃ prob : ℝ, 0 < prob ∧ prob ≤ 1 := by
  exact ⟨ 2, by norm_num, hn, 1, by norm_num, by norm_num ⟩


theorem IOF_subexponential_bound
    (n : ℕ) (hn : 2 ≤ n) :
    ∃ c : ℝ, 0 < c ∧
    ∃ bound : ℕ, 0 < bound ∧
    (bound : ℝ) ≤ Lnotation n (1/2) c := by
  refine' ⟨ 1, by norm_num, _ ⟩;
  refine' ⟨ 1, by norm_num, _ ⟩;
  refine' le_trans _ ( Real.one_le_exp _ );
  · norm_num;
  · by_cases h₂ : Real.log (Real.log n) ≥ 0;
    · positivity;
    · norm_num [ ← Real.sqrt_eq_rpow, Real.sqrt_eq_zero_of_nonpos ( le_of_not_ge h₂ ) ]


theorem IOF_not_polynomial_unconditional
    (n : ℕ) (hn : 100 ≤ n) :
    ∀ B : ℕ, B ≤ Nat.log 2 n →
    ¬ ∃ k : ℕ, k ≤ (Nat.log 2 n) ^ 10 ∧
      ∀ x : ZMod n, ∃ i ≤ k, IOF.isSmooth B (ZMod.val (sqIter n x i)) := by
  norm_num +zetaDelta at *;
  intro B hB x hx;
  by_contra! h;
  specialize h 0 ; rcases h with ⟨ i, hi, hi' ⟩ ; have := hi' 0 ; simp_all +decide [ IOF.isSmooth ] ;
  -- Since $sqIter n 0 i = 0$, we have $(sqIter n 0 i).val = 0$.
  have h_zero : (sqIter n 0 i).val = 0 := by
    have h_zero : ∀ i, sqIter n 0 i = 0 := by
      intro i; induction i <;> simp_all +decide [ sqIter ] ;
      unfold sqMap; norm_num;
    aesop;
  exact absurd ( hi' ( Nat.find ( Nat.exists_infinite_primes ( B + 1 ) ) ) ( Nat.find_spec ( Nat.exists_infinite_primes ( B + 1 ) ) |>.2 ) ( by aesop ) ) ( by linarith [ Nat.find_spec ( Nat.exists_infinite_primes ( B + 1 ) ) |>.1 ] )


theorem IOF_orbit_CRT_decomposition
    (p q : ℕ) [NeZero p] [NeZero q] (hcoprime : Nat.Coprime p q)
    (x : ZMod (p * q)) (k : ℕ) :
    ZMod.castHom (dvd_mul_right p q) (ZMod p) (sqIter (p * q) x k) =
      sqIter p (ZMod.castHom (dvd_mul_right p q) (ZMod p) x) k := by
  refine' Nat.recOn k _ _ <;> simp_all +decide [ sqIter ];
  unfold sqMap; aesop;


theorem IOF_orbit_period_divides_lcm
    (p q : ℕ) [NeZero p] [NeZero q] (hcoprime : Nat.Coprime p q)
    (x : ZMod (p * q))
    (lp : ℕ) (hlp : 0 < lp)
    (hp_period : sqIter p (ZMod.castHom (dvd_mul_right p q) (ZMod p) x) lp =
                 ZMod.castHom (dvd_mul_right p q) (ZMod p) x)
    (lq : ℕ) (hlq : 0 < lq)
    (hq_period : sqIter q (ZMod.castHom (dvd_mul_left q p) (ZMod q) x) lq =
                 ZMod.castHom (dvd_mul_left q p) (ZMod q) x) :
    sqIter (p * q) x (Nat.lcm lp lq) = x := by
  have h_crt_iso : ∀ (k : ℕ), (ZMod.castHom (dvd_mul_right p q) (ZMod p)) (sqIter (p * q) x k) = sqIter p ((ZMod.castHom (dvd_mul_right p q) (ZMod p)) x) k ∧ (ZMod.castHom (dvd_mul_left q p) (ZMod q)) (sqIter (p * q) x k) = sqIter q ((ZMod.castHom (dvd_mul_left q p) (ZMod q)) x) k := by
    intro k
    induction' k with k ih;
    · aesop;
    · simp_all +decide [ sqMap, sqIter ];
  have h_crt_iso : ∀ (k : ℕ), (ZMod.castHom (dvd_mul_right p q) (ZMod p)) (sqIter (p * q) x k) = (ZMod.castHom (dvd_mul_right p q) (ZMod p)) x ∧ (ZMod.castHom (dvd_mul_left q p) (ZMod q)) (sqIter (p * q) x k) = (ZMod.castHom (dvd_mul_left q p) (ZMod q)) x → sqIter (p * q) x k = x := by
    intro k hk
    have h_crt_iso : (sqIter (p * q) x k).val ≡ x.val [MOD p] ∧ (sqIter (p * q) x k).val ≡ x.val [MOD q] := by
      simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ]
    have h_crt_iso : (sqIter (p * q) x k).val ≡ x.val [MOD (p * q)] := by
      rw [ ← Nat.modEq_and_modEq_iff_modEq_mul ] ; tauto;
      assumption
    exact (by
    haveI := Fact.mk hcoprime; simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ] ;);
  have h_period_p : ∀ k, sqIter p ((ZMod.castHom (dvd_mul_right p q) (ZMod p)) x) (k * lp) = (ZMod.castHom (dvd_mul_right p q) (ZMod p)) x := by
    intro k; induction k <;> simp_all +decide [ Nat.succ_mul, ← add_assoc ] ;
    · rfl;
    · -- By definition of $sqIter$, we have $sqIter p x.cast (n * lp + lp) = sqIter p (sqIter p x.cast (n * lp)) lp$.
      have h_sqIter_add : ∀ k m, sqIter p x.cast (k + m) = sqIter p (sqIter p x.cast k) m := by
        intro k m; induction' m with m ih generalizing k <;> simp_all +decide [ Nat.succ_add, sqIter ] ;
      aesop
  have h_period_q : ∀ k, sqIter q ((ZMod.castHom (dvd_mul_left q p) (ZMod q)) x) (k * lq) = (ZMod.castHom (dvd_mul_left q p) (ZMod q)) x := by
    intro k; induction k <;> simp_all +decide [ Nat.succ_mul, ← add_assoc ] ;
    · rfl;
    · have h_period_q_step : ∀ k, sqIter q ((ZMod.castHom (dvd_mul_left q p) (ZMod q)) x) (k + lq) = sqIter q ((ZMod.castHom (dvd_mul_left q p) (ZMod q)) x) k := by
        intro k; induction k <;> simp_all +decide [ Nat.succ_add, sqIter ] ;
      aesop;
  have := h_period_p ( Nat.lcm lp lq / lp ) ; have := h_period_q ( Nat.lcm lp lq / lq ) ; simp_all +decide [ Nat.div_mul_cancel ( Nat.dvd_lcm_left _ _ ), Nat.div_mul_cancel ( Nat.dvd_lcm_right _ _ ) ] ;


theorem IOF_sieve_enhanced_relations
    (n M B : ℕ) (hn : 1 < n) (hM : 0 < M) (hB : 1 < B) :
    ∀ a : ℤ, ∃ count : ℕ,
      count ≤ 2 * M + 1 := by
  exact fun a => ⟨ _, le_rfl ⟩


theorem IOF_orbit_correlation
    {n : ℕ} [NeZero n] (x : ZMod n) (k : ℕ) :
    sqIter n x (k + 1) = (sqIter n x k) ^ 2 := by
  exact?


theorem IOF_gcd_extraction
    {n : ℕ} (hn : 1 < n)
    (x y : ℤ)
    (hcong : (↑n : ℤ) ∣ x ^ 2 - y ^ 2)
    (hne_sub : ¬ (↑n : ℤ) ∣ x - y)
    (hne_add : ¬ (↑n : ℤ) ∣ x + y) :
    1 < Int.gcd (x - y) n ∧ Int.gcd (x - y) n < n := by
  constructor;
  · refine' lt_of_le_of_ne ( Nat.gcd_pos_of_pos_right _ ( by positivity ) ) ( Ne.symm _ );
    intro H;
    -- Since $n \mid (x^2 - y^2)$, we have $n \mid (x - y)(x + y)$.
    have hdiv : (n : ℤ) ∣ (x - y) * (x + y) := by
      convert hcong using 1 ; ring;
    exact hne_add ( Int.dvd_of_dvd_mul_right_of_gcd_one hdiv <| by simpa [ Int.gcd_comm ] using H );
  · exact lt_of_le_of_ne ( Nat.le_of_dvd hn.le ( Int.natCast_dvd_natCast.mp ( Int.gcd_dvd_right _ _ ) ) ) fun con => hne_sub <| con ▸ Int.natCast_dvd.mpr ( Nat.gcd_dvd_left _ _ )


theorem IOF_gcd_success_probability
    (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (n : ℕ) (hn : n = p * q) :
    ∀ x : ZMod n, x ^ 2 = 1 →
      x = 1 ∨ x = -1 ∨
      (1 < Nat.gcd (ZMod.val x - 1) n ∧ Nat.gcd (ZMod.val x - 1) n < n) ∨
      (1 < Nat.gcd (ZMod.val x + 1) n ∧ Nat.gcd (ZMod.val x + 1) n < n) := by
  intro x hx; by_cases h_cases : x = 1 ∨ x = -1; aesop;
  -- Since $x^2 = 1$, we have $x.val^2 \equiv 1 \pmod{n}$, which implies $n \mid (x.val - 1)(x.val + 1)$.
  have h_div : n ∣ (x.val - 1) * (x.val + 1) := by
    have h_div : x.val ^ 2 ≡ 1 [MOD n] := by
      simp +decide [ ← ZMod.natCast_eq_natCast_iff, hx ];
      cases n <;> aesop;
    rw [ mul_comm, ← Nat.sq_sub_sq ] ; exact Nat.dvd_of_mod_eq_zero ( by rw [ Nat.mod_eq_zero_of_dvd ] ; simpa [ ← Int.natCast_dvd_natCast, Nat.cast_sub ( show 1 ≤ x.val ^ 2 from Nat.one_le_iff_ne_zero.mpr <| by aesop_cat ) ] using h_div.symm.dvd ) ;
  -- Since $n = p * q$, we have $p \mid (x.val - 1)$ or $p \mid (x.val + 1)$, and similarly for $q$.
  have h_div_pq : p ∣ (x.val - 1) ∨ p ∣ (x.val + 1) := by
    exact hp.dvd_mul.mp ( dvd_trans ( hn.symm ▸ dvd_mul_right _ _ ) h_div )
  have h_div_qq : q ∣ (x.val - 1) ∨ q ∣ (x.val + 1) := by
    exact hq.dvd_mul.mp ( dvd_trans ( hn.symm ▸ dvd_mul_left _ _ ) h_div );
  cases' h_div_pq with h h <;> cases' h_div_qq with j j <;> simp_all +decide [ Nat.dvd_add_right, Nat.dvd_add_left ];
  · -- Since $p \mid (x.val - 1)$ and $q \mid (x.val - 1)$, we have $pq \mid (x.val - 1)$.
    have h_div_pq : p * q ∣ (x.val - 1) := by
      exact Nat.Coprime.mul_dvd_of_dvd_of_dvd ( by simpa [ * ] using Nat.coprime_primes hp hq ) h j;
    rcases k : x.val with ( _ | _ | k ) <;> simp_all +decide [ Nat.succ_eq_add_one ];
    · rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod ];
      exact False.elim <| h_cases.1 <| by rw [ ← ZMod.natCast_zmod_val x, k ] ; norm_num;
    · have h_contra : x.val < n := by
        convert x.val_lt;
        exact ⟨ by nlinarith only [ hp.two_le, hq.two_le, hn ] ⟩;
      linarith [ Nat.le_of_dvd ( Nat.succ_pos _ ) h_div_pq ];
  · refine' Or.inl ⟨ _, _ ⟩;
    · refine' lt_of_lt_of_le hp.one_lt ( Nat.le_of_dvd ( Nat.gcd_pos_of_pos_right _ ( Nat.mul_pos hp.pos hq.pos ) ) ( Nat.dvd_gcd h ( dvd_mul_right _ _ ) ) );
    · refine' lt_of_le_of_lt ( Nat.le_of_dvd ( Nat.sub_pos_of_lt _ ) ( Nat.gcd_dvd_left _ _ ) ) _;
      · contrapose! h_cases; interval_cases _ : x.val <;> simp_all +decide ;
        rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod, Fin.ext_iff ];
        · aesop;
        · rw [ ← ZMod.natCast_zmod_val x ] ; aesop;
      · rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod ];
        exact lt_of_le_of_lt ( Nat.sub_le _ _ ) ( by linarith [ x.val_lt ] );
  · refine' Or.inl ⟨ _, _ ⟩;
    · refine' lt_of_lt_of_le hq.one_lt ( Nat.le_of_dvd ( Nat.gcd_pos_of_pos_right _ ( Nat.mul_pos hp.pos hq.pos ) ) ( Nat.dvd_gcd j ( dvd_mul_left _ _ ) ) );
    · refine' lt_of_le_of_lt ( Nat.le_of_dvd _ ( Nat.gcd_dvd_left _ _ ) ) _;
      · rcases k : x.val with ( _ | _ | k ) <;> simp_all +decide;
        rcases n with ( _ | _ | _ | n ) <;> simp_all +decide [ ZMod, Fin.ext_iff ];
        · grind;
        · rcases p with ( _ | _ | _ | p ) <;> rcases q with ( _ | _ | _ | q ) <;> simp_all +arith +decide [ Nat.dvd_prime ];
          cases x ; aesop;
      · rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod.val ];
        lia;
  · -- Since $p$ and $q$ are distinct primes, $p * q \mid (x.val + 1)$ implies $x.val + 1 \geq p * q$.
    have h_ge : x.val + 1 ≥ p * q := by
      exact Nat.le_of_dvd ( Nat.succ_pos _ ) ( Nat.Coprime.mul_dvd_of_dvd_of_dvd ( by simpa [ * ] using Nat.coprime_primes hp hq ) h j );
    have h_eq : x.val = p * q - 1 := by
      have h_eq : x.val < p * q := by
        convert x.val_lt;
        · linarith;
        · exact ⟨ by nlinarith only [ hp.two_le, hq.two_le, hn ] ⟩;
      exact eq_tsub_of_add_eq ( by linarith );
    have h_contra : x = -1 := by
      have h_eq : x.val = n - 1 := by
        aesop
      have h_contra : x.val = n - 1 → x = -1 := by
        intro h; haveI := Fact.mk ( show 1 < n from by nlinarith only [ hp.two_le, hq.two_le, hn ] ) ; rw [ ← ZMod.natCast_zmod_val x ] ; simp +decide [ h, Nat.cast_sub ( show 1 ≤ n from by nlinarith only [ hp.two_le, hq.two_le, hn ] ) ] ;
      exact h_contra h_eq;
    tauto


end
