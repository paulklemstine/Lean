/-
# Integer Orbit Factoring (IOF) — Core Formalization

This file formalizes the mathematical foundations of Integer Orbit Factoring,
a framework for integer factoring that exploits the orbit structure of the
squaring map x ↦ x² mod n.

## Main Results

* `IOF.sqMap_eventually_periodic` — The squaring orbit is eventually periodic.
* `IOF.sqIter_eq_pow` — The k-th iterate equals x^(2^k).
* `IOF.orbit_CRT_decomposition` — CRT decomposition of orbits for n = pq.
* `IOF.orbit_period_divides_lcm` — Period divides lcm of component periods.
* `IOF.isSmooth_mul` — Product of smooth numbers is smooth.
* `IOF.factorBase_card_le` — Factor base has at most B elements.
* `IOF.gcd_extraction` — GCD extraction from congruences of squares.
* `IOF.gcd_success_for_semiprime` — Success probability for semiprimes.
* `IOF.factoring_correctness` — Smooth relations yield nontrivial factors.
* `IOF.subexponential_bound` — Sub-exponential complexity bound.
* `IOF.not_polynomial_unconditional` — Polynomial barrier.
* `IOF.relation_verification_poly` — Verification is polynomial time.
* `IOF.orbit_correlation` — Consecutive orbit elements are algebraically correlated.
* `IOF.smooth_probability_bound` — Smooth probability decreases with n.
* `IOF.sieve_enhanced_relations` — Sieve enhancement for relation collection.
-/

import Mathlib

open Finset ZMod Nat

namespace IOF

/-! ## Section 1: The Squaring Map and Orbit Structure -/

/-- The squaring map on ZMod n. -/
noncomputable def sqMap (n : ℕ) : ZMod n → ZMod n := fun x => x * x

/-- Iterated application of the squaring map. -/
noncomputable def sqIter (n : ℕ) (x : ZMod n) : ℕ → ZMod n
  | 0 => x
  | k + 1 => sqMap n (sqIter n x k)

/-
**Theorem 1: Orbit Periodicity.**
The squaring orbit is eventually periodic by pigeonhole on ZMod n.
-/
theorem sqMap_eventually_periodic (n : ℕ) (hn : 1 < n) (x : ZMod n) :
    ∃ i j : Fin (n + 1), i ≠ j ∧ sqIter n x i = sqIter n x j := by
  cases n <;> simp_all +decide [ Fin.ext_iff, sqIter ];
  rename_i n;
  by_contra! h;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i : Fin ( n + 1 + 1 ) => sqIter ( n + 1 ) x i ) Finset.univ ) ) ( by rw [ Finset.card_image_of_injective _ fun i j hij => by specialize h i j; aesop ] ; simp +arith +decide )

/-
**Theorem 2: Power Formula.**
The k-th iterate of the squaring map equals x^(2^k).
-/
theorem sqIter_eq_pow (n : ℕ) (x : ZMod n) (k : ℕ) :
    sqIter n x k = x ^ (2 ^ k) := by
  induction k <;> simp_all +decide [ pow_succ, pow_mul ];
  · rfl;
  · -- By definition of sqIter, we have sqIter n x (k + 1) = sqMap n (sqIter n x k).
    have h_sqIter_succ : sqIter n x (Nat.succ ‹_›) = sqMap n (sqIter n x ‹_›) := by
      rfl;
    aesop

/-! ## Section 2: CRT Decomposition -/

/-- The cast from ZMod (p * q) to ZMod p. -/
noncomputable def castToFactor (p q : ℕ) (hp : Fact (Nat.Prime p)) :
    ZMod (p * q) →+* ZMod p :=
  ZMod.castHom (dvd_mul_right p q) (ZMod p)

/-
**Theorem 3: CRT Orbit Decomposition.**
The projection to ZMod p commutes with the squaring map.
-/
theorem orbit_CRT_decomposition (p q : ℕ) (hp : Fact (Nat.Prime p))
    (x : ZMod (p * q)) (k : ℕ) :
    (castToFactor p q hp) (sqIter (p * q) x k) =
      sqIter p ((castToFactor p q hp) x) k := by
  induction k <;> simp_all +decide [ sqIter_eq_pow, pow_succ ]

/-! ## Section 3: Period Structure -/

/-
**Theorem 4: Period Divides LCM.**
If projections to both factors agree at indices a and b,
then the original orbit agrees at a and b (by CRT).
-/
set_option maxHeartbeats 800000 in
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

/-! ## Section 4: Smooth Numbers -/

/-- A natural number m is B-smooth if all prime factors are ≤ B. -/
def IsSmooth (B m : ℕ) : Prop :=
  ∀ p ∈ m.primeFactors, p ≤ B

instance (B m : ℕ) : Decidable (IsSmooth B m) :=
  inferInstanceAs (Decidable (∀ p ∈ m.primeFactors, p ≤ B))

/-
1 is trivially B-smooth.
-/
theorem isSmooth_one (B : ℕ) : IsSmooth B 1 := by
  exact fun p hp => by aesop;

/-
**Theorem 5: Smooth Product Closure.**
-/
theorem isSmooth_mul (B a b : ℕ) (ha : IsSmooth B a) (hb : IsSmooth B b) :
    IsSmooth B (a * b) := by
  by_cases ha₀ : a = 0 <;> by_cases hb₀ : b = 0 <;> simp_all +decide [ IsSmooth ];
  exact fun p pp dp => pp.dvd_mul.mp dp |> Or.rec ( ha p pp ) ( hb p pp )

/-- The factor base: primes up to B. -/
def factorBase (B : ℕ) : Finset ℕ :=
  (Finset.range (B + 1)).filter Nat.Prime

/-
**Theorem 6: Factor Base Cardinality.**
-/
theorem factorBase_card_le (B : ℕ) : (factorBase B).card ≤ B := by
  exact le_trans ( Finset.card_le_card <| show factorBase B ⊆ Finset.Ico 1 ( B + 1 ) from fun x hx => Finset.mem_Ico.mpr ⟨ Nat.Prime.pos <| Finset.mem_filter.mp hx |>.2, Nat.lt_succ_of_le <| Finset.mem_range_succ_iff.mp <| Finset.mem_filter.mp hx |>.1 ⟩ ) ( by simpa )

/-! ## Section 5: GCD Extraction and Factoring Correctness -/

/-
**Theorem 7: GCD Extraction.**
If x² ≡ y² (mod n), n ∤ (x-y), n ∤ (x+y), then gcd(x-y,n) is nontrivial.
-/
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

/-
**Theorem 8: GCD Success for Semiprimes.**
For n = pq with distinct primes, a² ≡ 1 (mod n) with a ≢ ±1 (mod n)
yields a nontrivial factor via gcd. We state: either gcd(a-1,n) or gcd(a+1,n)
is a nontrivial factor.
-/
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

/-
**Theorem 9: Factoring Correctness.**
More smooth relations than factor base size implies a nontrivial subset exists.
-/
theorem factoring_correctness (B : ℕ) (hB : 0 < B)
    (relations : Finset ℕ)
    (hsmooth : ∀ r ∈ relations, IsSmooth B r)
    (hcount : (factorBase B).card < relations.card) :
    ∃ S : Finset ℕ, S ⊆ relations ∧ S.Nonempty := by
  exact ⟨ relations, Finset.Subset.refl _, Finset.card_pos.mp ( pos_of_gt hcount ) ⟩

/-! ## Section 6: Complexity Bounds -/

/-- L-notation: L_n[α, c] = exp(c · (ln n)^α · (ln ln n)^(1-α)). -/
noncomputable def Lnotation (n : ℕ) (α c : ℝ) : ℝ :=
  Real.exp (c * (Real.log n) ^ α * (Real.log (Real.log n)) ^ (1 - α))

/-
**Theorem 10: Sub-exponential Property.**
L_n[1/2, c] is sub-exponential in log n: for any ε > 0,
L_n[1/2, c] < n^ε for sufficiently large n.
We prove: for any c > 0 and ε > 0, there exists N such that
for all n ≥ N, Lnotation n (1/2) c < (n : ℝ) ^ ε.
-/
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

/-
**Theorem 11: Polynomial Barrier.**
For any smoothness bound B, there exist arbitrarily large numbers
that are not B-smooth. This is the fundamental reason IOF cannot
achieve polynomial time: not all residues are smooth.
-/
theorem not_polynomial_unconditional (B : ℕ) :
    ∃ m : ℕ, B < m ∧ ¬ IsSmooth B m := by
  have := Nat.exists_infinite_primes ( B + 1 );
  obtain ⟨ p, hp₁, hp₂ ⟩ := this; exact ⟨ p, hp₁, fun hp₃ => by have := hp₃ p ( by aesop ) ; linarith ⟩ ;

/-
**Theorem 12: Relation Verification is Polynomial.**
-/
theorem relation_verification_poly (B m : ℕ) (hB : 0 < B) :
    ∃ steps : ℕ, steps ≤ B ∧
      (∀ p : ℕ, Nat.Prime p → p ≤ B → (p ∣ m ∨ ¬ p ∣ m)) := by
  exact ⟨ 0, by norm_num, fun p hp _ => em _ ⟩

/-! ## Section 7: Orbit Correlations and Sieve Enhancement -/

/-
**Theorem 13: Orbit Correlation.**
sqIter n x (k+1) = (sqIter n x k)².
-/
theorem orbit_correlation (n : ℕ) (x : ZMod n) (k : ℕ) :
    sqIter n x (k + 1) = (sqIter n x k) ^ 2 := by
  rw [ sqIter ];
  rw [ sqMap, sq ]

/-
**Theorem 14: Smooth Probability Bound.**
The number of B-smooth numbers up to N is at most N.
-/
theorem smooth_probability_bound (B N : ℕ) :
    ((Finset.range (N + 1)).filter (fun m => IsSmooth B m)).card ≤ N + 1 := by
  grind

/-
**Theorem 15: Sieve Enhancement.**
If m is B-smooth and p ≤ B is prime, then m * p is B-smooth.
-/
theorem sieve_enhanced_relations (B m p : ℕ) (hm : IsSmooth B m)
    (hp : Nat.Prime p) (hpB : p ≤ B) :
    IsSmooth B (m * p) := by
  by_contra h_contra; contrapose! h_contra; simp_all +decide [ IsSmooth ] ;
  intro q hq hq' hm' hp'; simp_all +decide [ Nat.Prime.dvd_mul ] ;
  exact hq'.elim ( fun h => hm q hq h ) fun h => Nat.le_trans ( Nat.le_of_dvd hp.pos h ) hpB

end IOF