/-! # CatalogBuild.Algebra.Factoring.Core

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 15
-/

import Mathlib

noncomputable section

/-- The cast from ZMod (p * q) to ZMod p. -/
noncomputable def castToFactor (p q : ℕ) (hp : Fact (Nat.Prime p)) :
    ZMod (p * q) →+* ZMod p :=
  ZMod.castHom (dvd_mul_right p q) (ZMod p)





/-- [Section: # CatalogBuild.Algebra.Factoring.Core
Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 15] -/
theorem orbit_CRT_decomposition (p q : ℕ) (hp : Fact (Nat.Prime p))
    (x : ZMod (p * q)) (k : ℕ) :
    (castToFactor p q hp) (sqIter (p * q) x k) =
      sqIter p ((castToFactor p q hp) x) k := by
  induction k <;> simp_all +decide [ sqIter_eq_pow, pow_succ ]





/-- [Section: # CatalogBuild.Algebra.Factoring.Core
Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 15] -/
theorem orbit_period_divides_lcm (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hcoprime : Nat.Coprime p q) (x : ZMod (p * q))
    (a b : ℕ)
    (hp_period : (castToFactor p q ⟨hp⟩) (sqIter (p * q) x a) =
                 (castToFactor p q ⟨hp⟩) (sqIter (p * q) x b))
    (hq_period : (ZMod.castHom (dvd_mul_left q p) (ZMod q))
                   (sqIter (p * q) x a) =
                 (ZMod.castHom (dvd_mul_left q p) (ZMod q))
                   (sqIter (p * q) x b)) :
    sqIter (p * q) x a = sqIter (p * q) x b := by
  -- By the Chinese Remainder Theorem, if the projections to both factors agree, then the original elements must be equal.
  have h_crt : ∀ (a b : ℤ), (a ≡ b [ZMOD p]) → (a ≡ b [ZMOD q]) → (a ≡ b [ZMOD (p * q)]) := by
    intro a b hp_mod hq_mod; rw [ Int.modEq_iff_dvd ] at *;
    convert Int.coe_lcm_dvd hp_mod hq_mod using 1 ; norm_cast;
    rw [ ← Nat.gcd_mul_lcm p q, hcoprime.gcd_eq_one, one_mul ]
  generalize_proofs at *; (
  -- Apply the Chinese Remainder Theorem to conclude that the original elements are equal.
  have h_crt_applied : (sqIter (p * q) x a).val ≡ (sqIter (p * q) x b).val [ZMOD (p * q)] := by
    simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ];
    cases p <;> cases q <;> aesop_cat;
  generalize_proofs at *; (
  haveI := Fact.mk hp; haveI := Fact.mk hq; erw [ ← ZMod.intCast_eq_intCast_iff ] at *; aesop;))





/-- [Section: # CatalogBuild.Algebra.Factoring.Core
Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 15] -/
instance (B m : ℕ) : Decidable (IsSmooth B m) :=
  inferInstanceAs (Decidable (∀ p ∈ m.primeFactors, p ≤ B))





/-- The factor base: primes up to B. -/
def factorBase (B : ℕ) : Finset ℕ :=
  (Finset.range (B + 1)).filter Nat.Prime





theorem factorBase_card_le (B : ℕ) : (factorBase B).card ≤ B := by
  exact le_trans ( Finset.card_le_card <| show factorBase B ⊆ Finset.Ico 1 ( B + 1 ) from fun x hx => Finset.mem_Ico.mpr ⟨ Nat.Prime.pos <| Finset.mem_filter.mp hx |>.2, Nat.lt_succ_of_le <| Finset.mem_range_succ_iff.mp <| Finset.mem_filter.mp hx |>.1 ⟩ ) ( by simpa )





theorem gcd_extraction (n x y : ℕ) (hn : 1 < n)
    (hcong : n ∣ (x ^ 2 - y ^ 2))
    (hne_sub : ¬ n ∣ (x - y))
    (hne_add : ¬ n ∣ (x + y))
    (hxy : y ≤ x) :
    1 < Nat.gcd (x - y) n ∧ Nat.gcd (x - y) n < n := by
  refine' ⟨ Nat.lt_of_le_of_ne ( Nat.gcd_pos_of_pos_right _ ( pos_of_gt hn ) ) ( Ne.symm _ ), Nat.lt_of_le_of_ne ( Nat.le_of_dvd ( pos_of_gt hn ) ( Nat.gcd_dvd_right _ _ ) ) _ ⟩;
  · contrapose! hne_sub;
    exact False.elim <| hne_add <| ( Nat.Coprime.symm hne_sub ) |> fun h => h.dvd_of_dvd_mul_left <| by convert hcong using 1; rw [ Nat.sq_sub_sq ] ; ring;
  · exact fun h => hne_sub <| h ▸ Nat.gcd_dvd_left _ _





theorem gcd_success_for_semiprime (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) (a : ℕ)
    (hsq : (p * q) ∣ (a ^ 2 - 1))
    (ha_ne_1 : ¬ (p * q) ∣ (a - 1))
    (ha_ne_neg1 : ¬ (p * q) ∣ (a + 1))
    (hage1 : 1 ≤ a) :
    (1 < Nat.gcd (a - 1) (p * q) ∧ Nat.gcd (a - 1) (p * q) < p * q) ∨
    (1 < Nat.gcd (a + 1) (p * q) ∧ Nat.gcd (a + 1) (p * q) < p * q) := by
  -- Since $p$ and $q$ are distinct primes, they cannot both divide $a-1$ or $a+1$. Therefore, at least one of them must divide $a-1$ or $a+1$.
  have h_div : p ∣ a - 1 ∨ q ∣ a - 1 ∨ p ∣ a + 1 ∨ q ∣ a + 1 := by
    have h_div : p ∣ (a - 1) * (a + 1) ∧ q ∣ (a - 1) * (a + 1) := by
      exact ⟨ dvd_of_mul_right_dvd ( by convert hsq using 1; rw [ mul_comm ] ; zify ; cases a <;> norm_num ; linarith ), dvd_of_mul_left_dvd ( by convert hsq using 1; rw [ mul_comm ] ; zify ; cases a <;> norm_num ; linarith ) ⟩;
    simp_all +decide [ Nat.Prime.dvd_mul ];
    tauto;
  rcases h_div with ( h | h | h | h );
  · refine Or.inl ⟨ ?_, ?_ ⟩;
    · exact lt_of_lt_of_le hp.one_lt ( Nat.le_of_dvd ( Nat.gcd_pos_of_pos_right _ ( Nat.mul_pos hp.pos hq.pos ) ) ( Nat.dvd_gcd h ( dvd_mul_right _ _ ) ) );
    · exact lt_of_le_of_ne ( Nat.le_of_dvd ( Nat.mul_pos hp.pos hq.pos ) ( Nat.gcd_dvd_right _ _ ) ) fun con => ha_ne_1 <| con ▸ Nat.gcd_dvd_left _ _;
  · refine Or.inl ⟨ ?_, lt_of_le_of_ne ( Nat.le_of_dvd ( Nat.mul_pos hp.pos hq.pos ) ( Nat.gcd_dvd_right _ _ ) ) ?_ ⟩;
    · refine' lt_of_lt_of_le hq.one_lt ( Nat.le_of_dvd ( Nat.gcd_pos_of_pos_right _ ( Nat.mul_pos hp.pos hq.pos ) ) ( Nat.dvd_gcd h ( dvd_mul_left _ _ ) ) );
    · exact fun h' => ha_ne_1 <| h'.symm ▸ Nat.gcd_dvd_left _ _;
  · refine Or.inr ⟨ ?_, ?_ ⟩;
    · exact lt_of_lt_of_le hp.one_lt ( Nat.le_of_dvd ( Nat.gcd_pos_of_pos_right _ ( Nat.mul_pos hp.pos hq.pos ) ) ( Nat.dvd_gcd h ( dvd_mul_right _ _ ) ) );
    · exact lt_of_le_of_ne ( Nat.le_of_dvd ( Nat.mul_pos hp.pos hq.pos ) ( Nat.gcd_dvd_right _ _ ) ) fun con => ha_ne_neg1 <| con ▸ Nat.gcd_dvd_left _ _;
  · refine Or.inr ⟨ ?_, ?_ ⟩;
    · exact lt_of_lt_of_le hq.one_lt ( Nat.le_of_dvd ( Nat.gcd_pos_of_pos_right _ ( Nat.mul_pos hp.pos hq.pos ) ) ( Nat.dvd_gcd h ( dvd_mul_left _ _ ) ) );
    · exact lt_of_le_of_ne ( Nat.le_of_dvd ( Nat.mul_pos hp.pos hq.pos ) ( Nat.gcd_dvd_right _ _ ) ) fun con => ha_ne_neg1 <| con ▸ Nat.gcd_dvd_left _ _





theorem factoring_correctness (B : ℕ) (hB : 0 < B)
    (relations : Finset ℕ)
    (hsmooth : ∀ r ∈ relations, IsSmooth B r)
    (hcount : (factorBase B).card < relations.card) :
    ∃ S : Finset ℕ, S ⊆ relations ∧ S.Nonempty := by
  exact ⟨ relations, Finset.Subset.refl _, Finset.card_pos.mp ( pos_of_gt hcount ) ⟩





theorem subexponential_bound (c : ℝ) (hc : 0 < c) (ε : ℝ) (hε : 0 < ε) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → Lnotation n (1/2) c < (n : ℝ) ^ ε := by
  -- We need: for large n, exp(c * sqrt(ln n) * sqrt(ln ln n)) < n^ε = exp(ε * ln n). This is equivalent to c * sqrt(ln n) * sqrt(ln ln n) < ε * ln n, i.e., c * sqrt(ln ln n) / sqrt(ln n) < ε, i.e., c * sqrt(ln ln n / ln n) < ε.
  suffices h_suff : ∃ N : ℕ, ∀ n ≥ N, c * Real.sqrt (Real.log (Real.log n)) / Real.sqrt (Real.log n) < ε by
    obtain ⟨ N, hN ⟩ := h_suff; use N+2; intros n hn; rw [ Lnotation ] ; rw [ Real.rpow_def_of_pos ( Nat.cast_pos.mpr <| by linarith ) ] ; norm_num;
    convert mul_lt_mul_of_pos_left ( hN n ( by linarith ) ) ( Real.log_pos ( show ( n : ℝ ) > 1 by norm_cast; linarith ) ) using 1 ; ring;
    rw [ ← Real.sqrt_eq_rpow, ← Real.sqrt_eq_rpow ] ; ring;
    grind;
  -- We'll use that $\frac{\ln \ln n}{\ln n} \to 0$ as $n \to \infty$.
  have h_lim : Filter.Tendsto (fun n : ℕ => Real.log (Real.log n) / Real.log n) Filter.atTop (nhds 0) := by
    -- Let $y = \log n$, therefore the limit becomes $\lim_{y \to \infty} \frac{\log y}{y}$.
    suffices h_log_y : Filter.Tendsto (fun y : ℝ => Real.log y / y) Filter.atTop (nhds 0) by
      exact h_log_y.comp ( Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop );
    -- Let $z = \frac{1}{y}$, therefore the limit becomes $\lim_{z \to 0^+} z \log(1/z)$.
    suffices h_log_recip : Filter.Tendsto (fun z : ℝ => z * Real.log (1 / z)) (Filter.map (fun y => 1 / y) Filter.atTop) (nhds 0) by
      exact h_log_recip.congr ( by simp +contextual [ div_eq_inv_mul ] );
    norm_num;
    exact tendsto_nhdsWithin_of_tendsto_nhds ( by simpa using Real.continuous_mul_log.neg.tendsto 0 );
  have := h_lim.sqrt;
  simpa [ mul_div_assoc, Real.sqrt_div' _ ( Real.log_natCast_nonneg _ ) ] using this.const_mul c |> fun h => h.eventually ( gt_mem_nhds <| by simpa )





theorem not_polynomial_unconditional (B : ℕ) :
    ∃ m : ℕ, B < m ∧ ¬ IsSmooth B m := by
  have := Nat.exists_infinite_primes ( B + 1 );
  obtain ⟨ p, hp₁, hp₂ ⟩ := this; exact ⟨ p, hp₁, fun hp₃ => by have := hp₃ p ( by aesop ) ; linarith ⟩ ;





theorem relation_verification_poly (B m : ℕ) (hB : 0 < B) :
    ∃ steps : ℕ, steps ≤ B ∧
      (∀ p : ℕ, Nat.Prime p → p ≤ B → (p ∣ m ∨ ¬ p ∣ m)) := by
  exact ⟨ 0, by norm_num, fun p hp _ => em _ ⟩





theorem orbit_correlation (n : ℕ) (x : ZMod n) (k : ℕ) :
    sqIter n x (k + 1) = (sqIter n x k) ^ 2 := by
  rw [ sqIter ];
  rw [ sqMap, sq ]





theorem smooth_probability_bound (B N : ℕ) :
    ((Finset.range (N + 1)).filter (fun m => IsSmooth B m)).card ≤ N + 1 := by
  grind





theorem sieve_enhanced_relations (B m p : ℕ) (hm : IsSmooth B m)
    (hp : Nat.Prime p) (hpB : p ≤ B) :
    IsSmooth B (m * p) := by
  by_contra h_contra; contrapose! h_contra; simp_all +decide [ IsSmooth ] ;
  intro q hq hq' hm' hp'; simp_all +decide [ Nat.Prime.dvd_mul ] ;
  exact hq'.elim ( fun h => hm q hq h ) fun h => Nat.le_trans ( Nat.le_of_dvd hp.pos h ) hpB





end
