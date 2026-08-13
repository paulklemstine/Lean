import MachineLearning.HalfPlaneClosedForm

/-!
# Cycle 5: Hensel lifting for the modular circle

The conic `x² + y² = 1` is smooth over `F_p` for odd `p` (its gradient `(2x, 2y)`
never vanishes on the curve), so every solution modulo `M` lifts to exactly `p`
solutions modulo `pM` whenever `p ∣ M`.  Formally:

* `card_lift_solutions` : a non-degenerate linear congruence in two unknowns over
  `F_p` has exactly `p` solutions;
* `circleCount_mul_of_prime_dvd` : `C(pM) = p·C(M)` for `p` an odd prime dividing `M`;
* `circleCount_prime_pow` : `C(p^k) = p^{k-1}(p - χ_p(-1))`;
* `circleCount_odd` : the completely explicit formula
  `C(N) = ∏_{p ∣ N} p^{v_p(N)-1}(p - χ_p(-1))` for every odd `N ≥ 1`.

This closes the separable baseline: `C` is a closed-form function of the
factorisation of `N`, in stark contrast with the half-plane count `H`, which is not
multiplicative at all.
-/

namespace HalfPlane

open Finset

/-! ### Counting the lifts -/

/-- A non-degenerate linear equation in two unknowns over `F_p` has `p` solutions. -/
theorem card_linear_solutions (p : ℕ) [Fact (Nat.Prime p)] (α β γ : ZMod p)
    (h : α ≠ 0 ∨ β ≠ 0) :
    (Finset.univ.filter (fun st : ZMod p × ZMod p => α * st.1 + β * st.2 = γ)).card = p := by
  classical
  rcases h with ha | hb
  · have hcard : (Finset.univ.filter (fun st : ZMod p × ZMod p => α * st.1 + β * st.2 = γ)).card
        = (Finset.univ : Finset (ZMod p)).card := by
      refine Finset.card_bij (fun st _ => st.2) (fun st _ => Finset.mem_univ _) ?_ ?_
      · intro s hs t ht hst
        simp only [Finset.mem_filter] at hs ht
        have h2 : s.2 = t.2 := hst
        have h1 : α * s.1 = α * t.1 := by linear_combination hs.2 - ht.2 - β * h2
        exact Prod.ext (mul_left_cancel₀ ha h1) h2
      · intro b _
        refine ⟨((γ - β * b) / α, b), ?_, rfl⟩
        simp only [Finset.mem_filter, Finset.mem_univ, true_and]
        field_simp
        ring
    rw [hcard]; simp [ZMod.card p]
  · have hcard : (Finset.univ.filter (fun st : ZMod p × ZMod p => α * st.1 + β * st.2 = γ)).card
        = (Finset.univ : Finset (ZMod p)).card := by
      refine Finset.card_bij (fun st _ => st.1) (fun st _ => Finset.mem_univ _) ?_ ?_
      · intro s hs t ht hst
        simp only [Finset.mem_filter] at hs ht
        have h1 : s.1 = t.1 := hst
        have h2 : β * s.2 = β * t.2 := by linear_combination hs.2 - ht.2 - α * h1
        exact Prod.ext h1 (mul_left_cancel₀ hb h2)
      · intro a _
        refine ⟨(a, (γ - α * a) / β), ?_, rfl⟩
        simp only [Finset.mem_filter, Finset.mem_univ, true_and]
        field_simp
        ring
    rw [hcard]; simp [ZMod.card p]

/-- The lifting condition `c + 2(as + bt) ≡ 0 (mod p)` has exactly `p` solutions
`(s,t) ∈ [0,p)²` as soon as `p` does not divide both `a` and `b`. -/
theorem card_lift_solutions (p a b c : ℕ) [Fact (Nat.Prime p)] (hp2 : p ≠ 2)
    (hab : ¬ (p ∣ a ∧ p ∣ b)) :
    (((Finset.range p) ×ˢ (Finset.range p)).filter
      (fun st => p ∣ (c + 2 * (a * st.1 + b * st.2)))).card = p := by
  classical
  haveI : NeZero p := ⟨(Fact.out (p := Nat.Prime p)).ne_zero⟩
  have h2 : (2 : ZMod p) ≠ 0 := by
    apply Ring.two_ne_zero
    rw [ZMod.ringChar_zmod_n p]
    exact_mod_cast hp2
  have hnz : (2 * (a : ZMod p)) ≠ 0 ∨ (2 * (b : ZMod p)) ≠ 0 := by
    rcases not_and_or.mp hab with h | h
    · exact Or.inl (mul_ne_zero h2 (fun hc => h ((ZMod.natCast_eq_zero_iff a p).mp hc)))
    · exact Or.inr (mul_ne_zero h2 (fun hc => h ((ZMod.natCast_eq_zero_iff b p).mp hc)))
  have hbij : (((Finset.range p) ×ˢ (Finset.range p)).filter
      (fun st => p ∣ (c + 2 * (a * st.1 + b * st.2)))).card
      = (Finset.univ.filter (fun st : ZMod p × ZMod p =>
          (2 * (a : ZMod p)) * st.1 + (2 * (b : ZMod p)) * st.2 = -(c : ZMod p))).card := by
    refine Finset.card_bij (fun st _ => ((st.1 : ZMod p), (st.2 : ZMod p))) ?_ ?_ ?_
    · intro st hst
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hst
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      have hz := (ZMod.natCast_eq_zero_iff (c + 2 * (a * st.1 + b * st.2)) p).mpr hst.2
      push_cast at hz
      linear_combination hz
    · intro s hs t ht hst
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hs ht
      have e1 : (s.1 : ZMod p) = (t.1 : ZMod p) := congrArg Prod.fst hst
      have e2 : (s.2 : ZMod p) = (t.2 : ZMod p) := congrArg Prod.snd hst
      have f1 : s.1 = t.1 := by
        have hv := congrArg ZMod.val e1
        rwa [ZMod.val_natCast_of_lt hs.1.1, ZMod.val_natCast_of_lt ht.1.1] at hv
      have f2 : s.2 = t.2 := by
        have hv := congrArg ZMod.val e2
        rwa [ZMod.val_natCast_of_lt hs.1.2, ZMod.val_natCast_of_lt ht.1.2] at hv
      exact Prod.ext f1 f2
    · intro ST hST
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hST
      refine ⟨(ST.1.val, ST.2.val), ?_, by simp⟩
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range]
      refine ⟨⟨ZMod.val_lt _, ZMod.val_lt _⟩, ?_⟩
      rw [← ZMod.natCast_eq_zero_iff]
      push_cast
      simp only [ZMod.natCast_val, ZMod.cast_id]
      linear_combination hST
  rw [hbij, card_linear_solutions p _ _ _ hnz]

/-! ### The lifting criterion -/

lemma add_one_mod_iff {n W : ℕ} : (W + 1) % n = 1 % n ↔ n ∣ W := by
  constructor
  · intro h
    have h1 : (W + 1) ≡ (0 + 1) [MOD n] := by simpa [Nat.ModEq] using h
    exact (Nat.modEq_zero_iff_dvd).mp (Nat.ModEq.add_right_cancel' 1 h1)
  · intro h
    have h1 : W ≡ 0 [MOD n] := (Nat.modEq_zero_iff_dvd).mpr h
    simpa [Nat.ModEq] using h1.add_right 1

/-- **The Hensel criterion.**  With `a² + b² = Mc + 1` and `p ∣ M`, the lifted point
`(a + sM, b + tM)` lies on the circle modulo `pM` exactly when
`c + 2(as + bt) ≡ 0 (mod p)`. -/
lemma circle_lift_iff {M p a b s t c : ℕ} (hM : 0 < M) (hpM : p ∣ M)
    (hc : a ^ 2 + b ^ 2 = M * c + 1) :
    (((a + s * M) ^ 2 + (b + t * M) ^ 2) % (p * M) = 1 % (p * M))
      ↔ p ∣ (c + 2 * (a * s + b * t)) := by
  have expand : (a + s * M) ^ 2 + (b + t * M) ^ 2
      = M * (c + 2 * (a * s + b * t) + M * (s ^ 2 + t ^ 2)) + 1 := by
    have h0 : (a + s * M) ^ 2 + (b + t * M) ^ 2
        = (a ^ 2 + b ^ 2) + M * (2 * (a * s + b * t) + M * (s ^ 2 + t ^ 2)) := by ring
    rw [h0, hc]; ring
  rw [expand, add_one_mod_iff, show p * M = M * p by ring, Nat.mul_dvd_mul_iff_left hM]
  exact Nat.dvd_add_left (Dvd.dvd.mul_right hpM _)

/-- Every circle point modulo `M ≥ 2` has `a² + b² = Mc + 1` for some `c`. -/
lemma exists_quotient_of_mem_circle {M a b : ℕ} (hM : 2 ≤ M)
    (hc : (a ^ 2 + b ^ 2) % M = 1 % M) : ∃ c, a ^ 2 + b ^ 2 = M * c + 1 := by
  have h1 : 1 % M = 1 := Nat.mod_eq_of_lt (by omega)
  rw [h1] at hc
  have hdm := Nat.div_add_mod (a ^ 2 + b ^ 2) M
  exact ⟨(a ^ 2 + b ^ 2) / M, by omega⟩

/-- On the circle modulo `M`, `p ∣ M` implies that `p` cannot divide both coordinates. -/
lemma not_both_dvd {M p a b c : ℕ} (hp : 2 ≤ p) (hpM : p ∣ M)
    (hc : a ^ 2 + b ^ 2 = M * c + 1) : ¬ (p ∣ a ∧ p ∣ b) := by
  rintro ⟨ha, hb⟩
  have h1 : p ∣ a ^ 2 + b ^ 2 := Nat.dvd_add (Dvd.dvd.pow ha (by norm_num))
    (Dvd.dvd.pow hb (by norm_num))
  rw [hc] at h1
  have h2 : p ∣ M * c := Dvd.dvd.mul_right hpM c
  have : p ∣ 1 := (Nat.dvd_add_right h2).mp h1
  have := Nat.le_of_dvd (by norm_num) this
  omega

/-! ### The lifting bijection -/

/-- **Each circle point modulo `M` has exactly `p` lifts modulo `pM`.** -/
theorem card_fiber (p M a b : ℕ) [Fact (Nat.Prime p)] (hp2 : p ≠ 2) (hM : 2 ≤ M)
    (hpM : p ∣ M) (ha : a < M) (hb : b < M) (hcirc : (a ^ 2 + b ^ 2) % M = 1 % M) :
    ((circleFinset (p * M)).filter (fun q => (q.1 % M, q.2 % M) = (a, b))).card = p := by
  classical
  have hp : 2 ≤ p := (Fact.out (p := Nat.Prime p)).two_le
  obtain ⟨c, hc⟩ := exists_quotient_of_mem_circle hM hcirc
  have hab := not_both_dvd hp hpM hc
  have hM0 : 0 < M := by omega
  have hbij : ((circleFinset (p * M)).filter (fun q => (q.1 % M, q.2 % M) = (a, b))).card
      = (((Finset.range p) ×ˢ (Finset.range p)).filter
          (fun st => p ∣ (c + 2 * (a * st.1 + b * st.2)))).card := by
    refine Finset.card_bij' (fun q _ => (q.1 / M, q.2 / M))
      (fun st _ => (a + st.1 * M, b + st.2 * M)) ?_ ?_ ?_ ?_
    · -- forward map lands in the solution set
      intro q hq
      simp only [Finset.mem_filter, mem_circleFinset, Prod.mk.injEq] at hq
      obtain ⟨⟨h1, h2, hcq⟩, hr1, hr2⟩ := hq
      have hd1 : q.1 = a + (q.1 / M) * M := by
        calc q.1 = M * (q.1 / M) + q.1 % M := (Nat.div_add_mod _ _).symm
          _ = a + (q.1 / M) * M := by rw [hr1]; ring
      have hd2 : q.2 = b + (q.2 / M) * M := by
        calc q.2 = M * (q.2 / M) + q.2 % M := (Nat.div_add_mod _ _).symm
          _ = b + (q.2 / M) * M := by rw [hr2]; ring
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range]
      refine ⟨⟨?_, ?_⟩, ?_⟩
      · exact Nat.div_lt_of_lt_mul (by rw [mul_comm] at h1; exact h1)
      · exact Nat.div_lt_of_lt_mul (by rw [mul_comm] at h2; exact h2)
      · rw [← circle_lift_iff (s := q.1 / M) (t := q.2 / M) hM0 hpM hc]
        rw [← hd1, ← hd2]
        exact hcq
    · -- backward map lands in the fiber
      intro st hst
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hst
      obtain ⟨⟨hs1, hs2⟩, hcond⟩ := hst
      have hlt1 : a + st.1 * M < p * M := by
        calc a + st.1 * M < M + st.1 * M := by omega
          _ = (st.1 + 1) * M := by ring
          _ ≤ p * M := Nat.mul_le_mul_right M (by omega)
      have hlt2 : b + st.2 * M < p * M := by
        calc b + st.2 * M < M + st.2 * M := by omega
          _ = (st.2 + 1) * M := by ring
          _ ≤ p * M := Nat.mul_le_mul_right M (by omega)
      simp only [Finset.mem_filter, mem_circleFinset, Prod.mk.injEq]
      refine ⟨⟨hlt1, hlt2, ?_⟩, ?_, ?_⟩
      · rw [circle_lift_iff hM0 hpM hc]
        exact hcond
      · show (a + st.1 * M) % M = a
        rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt ha]
      · show (b + st.2 * M) % M = b
        rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hb]
    · -- left inverse
      intro q hq
      simp only [Finset.mem_filter, mem_circleFinset, Prod.mk.injEq] at hq
      obtain ⟨⟨h1, h2, hcq⟩, hr1, hr2⟩ := hq
      have hd1 : q.1 = a + (q.1 / M) * M := by
        calc q.1 = M * (q.1 / M) + q.1 % M := (Nat.div_add_mod _ _).symm
          _ = a + (q.1 / M) * M := by rw [hr1]; ring
      have hd2 : q.2 = b + (q.2 / M) * M := by
        calc q.2 = M * (q.2 / M) + q.2 % M := (Nat.div_add_mod _ _).symm
          _ = b + (q.2 / M) * M := by rw [hr2]; ring
      exact Prod.ext hd1.symm hd2.symm
    · -- right inverse
      intro st hst
      simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hst
      have e1 : (a + st.1 * M) / M = st.1 := by
        rw [Nat.add_mul_div_right _ _ hM0, Nat.div_eq_of_lt ha, Nat.zero_add]
      have e2 : (b + st.2 * M) / M = st.2 := by
        rw [Nat.add_mul_div_right _ _ hM0, Nat.div_eq_of_lt hb, Nat.zero_add]
      exact Prod.ext e1 e2
  rw [hbij, card_lift_solutions p a b c hp2 hab]

/-- **Hensel lifting for the circle count**: `C(pM) = p · C(M)` for an odd prime `p`
dividing `M`. -/
theorem circleCount_mul_of_prime_dvd (p M : ℕ) [Fact (Nat.Prime p)] (hp2 : p ≠ 2)
    (hM : 2 ≤ M) (hpM : p ∣ M) :
    circleCount (p * M) = p * circleCount M := by
  classical
  have hM0 : 0 < M := by omega
  have hmaps : ∀ q ∈ circleFinset (p * M), ((q.1 % M, q.2 % M) : ℕ × ℕ) ∈ circleFinset M := by
    intro q hq
    rw [mem_circleFinset] at hq ⊢
    obtain ⟨h1, h2, hc⟩ := hq
    refine ⟨Nat.mod_lt _ hM0, Nat.mod_lt _ hM0, ?_⟩
    have hmod : (q.1 % M) ^ 2 + (q.2 % M) ^ 2 ≡ q.1 ^ 2 + q.2 ^ 2 [MOD M] :=
      Nat.ModEq.add (Nat.ModEq.pow 2 (Nat.mod_modEq _ _)) (Nat.ModEq.pow 2 (Nat.mod_modEq _ _))
    have hdvd : M ∣ p * M := ⟨p, by ring⟩
    have h3 : q.1 ^ 2 + q.2 ^ 2 ≡ 1 [MOD M] := Nat.ModEq.of_dvd hdvd hc
    exact hmod.trans h3
  have hsum := Finset.card_eq_sum_card_fiberwise hmaps
  rw [circleCount, hsum]
  have hconst : ∀ ab ∈ circleFinset M,
      ((circleFinset (p * M)).filter (fun q => (q.1 % M, q.2 % M) = ab)).card = p := by
    intro ab hab
    rw [mem_circleFinset] at hab
    obtain ⟨h1, h2, hc⟩ := hab
    have := card_fiber p M ab.1 ab.2 hp2 hM hpM h1 h2 hc
    simpa using this
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, smul_eq_mul, circleCount, mul_comm]

/-! ### The prime-power formula -/

/-- **The circle count at an odd prime power**: `C(p^k) = p^{k-1}(p - χ_p(-1))`. -/
theorem circleCount_prime_pow (p : ℕ) [Fact (Nat.Prime p)] (hp2 : p ≠ 2) :
    ∀ k : ℕ, 1 ≤ k → circleCount (p ^ k) = p ^ (k - 1) * circleCount p := by
  have hp : 2 ≤ p := (Fact.out (p := Nat.Prime p)).two_le
  have hp3 : 3 ≤ p := by
    rcases Nat.lt_or_ge p 3 with h | h
    · interval_cases p
      · exact absurd rfl hp2
    · exact h
  intro k
  induction k with
  | zero => intro h; omega
  | succ n ih =>
    intro _
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have hMle : 2 ≤ p ^ n := by
        calc 2 ≤ p := hp
          _ = p ^ 1 := (pow_one p).symm
          _ ≤ p ^ n := Nat.pow_le_pow_right (by omega) hn
      have hdvd : p ∣ p ^ n := dvd_pow_self p (by omega)
      have hstep : circleCount (p ^ (n + 1)) = p * circleCount (p ^ n) := by
        rw [pow_succ, mul_comm (p ^ n) p]
        exact circleCount_mul_of_prime_dvd p (p ^ n) hp2 hMle hdvd
      rw [hstep, ih hn]
      have : n + 1 - 1 = n := by omega
      rw [this]
      have hn1 : n - 1 + 1 = n := by omega
      calc p * (p ^ (n - 1) * circleCount p) = (p ^ (n - 1) * p) * circleCount p := by ring
        _ = p ^ (n - 1 + 1) * circleCount p := by rw [pow_succ]
        _ = p ^ n * circleCount p := by rw [hn1]

/-- **The circle count of an arbitrary odd modulus, in closed form.**
`C(N) = ∏_{p ∣ N} p^{v_p(N) - 1}(p - χ_p(-1))`. -/
theorem circleCount_odd {N : ℕ} (hN : N ≠ 0) (hodd : ¬ 2 ∣ N) :
    circleCount N
      = ∏ p ∈ N.primeFactors,
          p ^ (N.factorization p - 1) * (if p % 4 = 1 then p - 1 else p + 1) := by
  have hmul := circleArith_isMultiplicative.multiplicative_factorization circleArith hN
  rw [Finsupp.prod, Nat.support_factorization] at hmul
  simp only [circleArith_apply] at hmul
  rw [hmul]
  refine Finset.prod_congr rfl ?_
  intro q hq
  have hpq : q.Prime := Nat.prime_of_mem_primeFactors hq
  haveI : Fact q.Prime := ⟨hpq⟩
  have hq2 : q ≠ 2 := by
    rintro rfl
    exact hodd (Nat.dvd_of_mem_primeFactors hq)
  have hk : 1 ≤ N.factorization q :=
    hpq.factorization_pos_of_dvd hN (Nat.dvd_of_mem_primeFactors hq)
  rw [circleCount_prime_pow q hq2 _ hk, circleCount_prime hq2]

/-! ### Lab notes (cycle 5)

```
p^k :  9   27   81   25   125   49   121
C   : 12   36  108   20   100   56   132
p^{k-1}(p ∓ 1) : 3·4  9·4  27·4  5·4  25·4  7·8  11·12
```
-/

example : circleCount 9 = 12 := by decide
example : circleCount 27 = 36 := by decide
example : circleCount 25 = 20 := by decide

end HalfPlane