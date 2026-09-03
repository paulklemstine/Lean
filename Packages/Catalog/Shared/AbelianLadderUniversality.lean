/-
# Universality of the abelian pinning law, and the decay of the ladder

The degree-11 file (`Shared.AbelianLadderRealCyclotomic`) establishes the eleventh
rung of the abelian splitting-type ladder.  This file removes the "one rung at a
time" character of that statement in three directions.

1. **Pinning is a theorem, not an observation.**  `abelian_full_pinning` shows
   that for *any* finite abelian Galois group `G` and *any* subgroup `H`, the
   splitting type read off in `G/H` is a function of the Artin class, so the
   conditional entropy vanishes identically and the mutual information equals
   `H(T)` — at every degree, with no exceptions.

2. **The whole real-cyclotomic ladder of prime degree at once.**
   `realCyclotomic_prime_degree` proves, for every prime `f` whose real degree
   `q = (f-1)/2` is again prime, the complete rung: the Galois group has order
   `q`, the residue degree is `1` on exactly the two classes `±1` and `q`
   elsewhere (density `1/q` against `(q-1)/q`), and the Frobenius entropy is
   `binEnt q 1 = typeEntropy q`.  Degrees `2, 3, 5, 11` — the fields
   `Q(ζ₅)⁺, Q(ζ₇)⁺, Q(ζ₁₁)⁺, Q(ζ₂₃)⁺` — are then instances, not new work.

3. **The rungs decay like `log₂ q / q`.**  `typeEntropy_prime_sandwich` brackets
   the prime-degree entropy between `log₂ q / q` and `(log₂ q + 1/ln 2)/q`, and
   `typeEntropy_prime_lt_one` shows that degree `2` is the *only* rung of the
   prime ladder that reaches a full bit.
-/
import Shared.AbelianLadderRealCyclotomic

namespace AbelianLadder

open Finset CyclicTypeChannel

/-! ## 1. Universal pinning for abelian Galois groups -/

/-- **UNIVERSAL FULL PINNING.**  Let `G` be a finite abelian Galois group and `H`
the decomposition subgroup cut out by a subfield.  The splitting type of a
Frobenius element in the subfield — the order of its class in `G/H` — is a
function of that class, so the conditional entropy is identically `0` and the
class channel carries the *entire* entropy of the type.  Every rung of the
abelian ladder, at every degree, is an instance of this statement. -/
theorem abelian_full_pinning {G : Type*} [CommGroup G] [Fintype G] (H : Subgroup G)
    [DecidableEq (G ⧸ H)] :
    condEnt (univ : Finset G) (fun u => orderOf (QuotientGroup.mk' H u))
        (fun u => QuotientGroup.mk' H u) = 0 ∧
      mutInfo (univ : Finset G) (fun u => orderOf (QuotientGroup.mk' H u))
        (fun u => QuotientGroup.mk' H u)
        = uEnt (univ : Finset G) (fun u => orderOf (QuotientGroup.mk' H u)) := by
  have hcond : condEnt (univ : Finset G) (fun u => orderOf (QuotientGroup.mk' H u))
      (fun u => QuotientGroup.mk' H u) = 0 :=
    condEnt_eq_zero_of_determines fun x _ y _ hxy => by simp only [hxy]
  exact ⟨hcond, by rw [mutInfo, hcond, sub_zero]⟩

/-! ## 2. The real-cyclotomic ladder at every prime degree -/

section PrimeDegree

variable {f q : ℕ}

/-- For an odd prime `f` the class `-1` is a genuine involution of `(Z/f)ˣ`. -/
theorem neg_one_ne_one_units (hf2 : 2 < f) : (-1 : (ZMod f)ˣ) ≠ 1 := by
  haveI : Fact (2 < f) := ⟨hf2⟩
  intro h
  exact ZMod.neg_one_ne_one (congrArg Units.val h)

/-- The sign subgroup of an odd prime modulus has order `2`. -/
theorem card_signSub (hf2 : 2 < f) : Nat.card (signSub f) = 2 := by
  rw [signSub, Nat.card_zpowers]
  exact orderOf_eq_prime (by simp) (neg_one_ne_one_units hf2)

/-- **The Galois group of `Q(ζ_f)⁺` has order `(f-1)/2`.** -/
theorem card_quot_signSub (hf : f.Prime) (hf2 : 2 < f) :
    2 * Nat.card ((ZMod f)ˣ ⧸ signSub f) = f - 1 := by
  haveI : Fact f.Prime := ⟨hf⟩
  have hcard : Nat.card (ZMod f)ˣ = f - 1 := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient, Nat.totient_prime hf]
  have h := Subgroup.card_eq_card_quotient_mul_card_subgroup (signSub f)
  rw [hcard, card_signSub hf2] at h
  omega

/-- **The prime-degree dichotomy.** If the real degree `q = (f-1)/2` is prime,
every Frobenius is either totally split or of full residue degree `q`. -/
theorem realDeg_eq_one_or (hf : f.Prime) (hf2 : 2 < f) (hq : q.Prime) (hfq : f = 2 * q + 1)
    (u : (ZMod f)ˣ) : realDeg f u = 1 ∨ realDeg f u = q := by
  have hcard : Nat.card ((ZMod f)ˣ ⧸ signSub f) = q := by
    have := card_quot_signSub hf hf2
    omega
  have hdvd : realDeg f u ∣ q := by
    rw [realDeg, ← hcard]
    exact orderOf_dvd_natCard _
  exact hq.eq_one_or_self_of_dvd _ hdvd

/-- The split classes are exactly `{1, -1}`: density `2/(f-1) = 1/q`. -/
theorem card_filter_realDeg_eq_one [NeZero f] (hf2 : 2 < f) :
    #{u ∈ (univ : Finset (ZMod f)ˣ) | realDeg f u = 1} = 2 := by
  classical
  have hset : {u ∈ (univ : Finset (ZMod f)ˣ) | realDeg f u = 1}
      = ({1, -1} : Finset (ZMod f)ˣ) := by
    ext u; simp [realDeg_eq_one_iff]
  rw [hset, card_insert_of_notMem (by
    simpa using fun h => neg_one_ne_one_units hf2 h.symm), card_singleton]

/-- **The rung of the real-cyclotomic ladder at prime degree `q`.**  For a prime
`f = 2q + 1` with `q` prime, the Frobenius entropy of `Q(ζ_f)⁺` is exactly the
entropy of the abstract `C_q` type channel. -/
theorem realCyclotomic_prime_degree [NeZero f] (hf : f.Prime) (hf2 : 2 < f) (hq : q.Prime)
    (hfq : f = 2 * q + 1) :
    uEnt (univ : Finset (ZMod f)ˣ) (realDeg f) = typeEntropy q := by
  classical
  haveI : Fact f.Prime := ⟨hf⟩
  have hcardu : (univ : Finset (ZMod f)ˣ).card = 2 * q := by
    have : Fintype.card (ZMod f)ˣ = f - 1 := by
      rw [ZMod.card_units_eq_totient, Nat.totient_prime hf]
    simpa [Finset.card_univ, this] using (by omega : f - 1 = 2 * q)
  have hbin := uEnt_binary (s := (univ : Finset (ZMod f)ˣ)) (g := realDeg f)
    (v := 1) (w := q) (Ne.symm hq.one_lt.ne')
    (fun u _ => realDeg_eq_one_or hf hf2 hq hfq u)
  rw [hbin, card_filter_realDeg_eq_one hf2, hcardu,
    show (2 : ℕ) = 2 * 1 from rfl, binEnt_scale (by norm_num) (by norm_num) hq.one_lt,
    typeEntropy_prime_eq_binEnt hq]

end PrimeDegree

/-! ### The prime rungs of the ladder: degrees 2, 3, 5, 11 -/

/-- Degree 2: `Q(ζ₅)⁺ = Q(√5)`. -/
theorem ladder_rung_two : uEnt (univ : Finset (ZMod 5)ˣ) (realDeg 5) = typeEntropy 2 :=
  realCyclotomic_prime_degree (f := 5) (q := 2) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)

/-- Degree 3: `Q(ζ₇)⁺`. -/
theorem ladder_rung_three : uEnt (univ : Finset (ZMod 7)ˣ) (realDeg 7) = typeEntropy 3 :=
  realCyclotomic_prime_degree (f := 7) (q := 3) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)

/-- Degree 5: `Q(ζ₁₁)⁺`. -/
theorem ladder_rung_five : uEnt (univ : Finset (ZMod 11)ˣ) (realDeg 11) = typeEntropy 5 :=
  realCyclotomic_prime_degree (f := 11) (q := 5) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)

/-- Degree 11: `Q(ζ₂₃)⁺` — the eleventh rung, now a corollary of the general
prime-degree law rather than a separate computation. -/
theorem ladder_rung_eleven : uEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) = typeEntropy 11 :=
  realCyclotomic_prime_degree (f := 23) (q := 11) (by norm_num) (by norm_num) (by norm_num)
    (by norm_num)

/-! ## 3. How the rungs decay: `H(T_q) ≍ log₂ q / q` -/

/-- `1 / log 2 < 1.4427`. -/
theorem one_div_log_two_lt : 1 / Real.log 2 < 1.4427 := by
  have h : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hpos : (0 : ℝ) < Real.log 2 := by linarith
  rw [div_lt_iff₀ hpos]
  nlinarith

/-- **Lower rung bound**: `log₂ q / q ≤ H(T_q)`. -/
theorem typeEntropy_prime_lower {q : ℕ} (hq : q.Prime) :
    Real.logb 2 q / q ≤ typeEntropy q := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hq1 : (1 : ℝ) ≤ (q : ℝ) - 1 + 1 := by
    have : (1 : ℝ) ≤ q := by exact_mod_cast hq.one_lt.le
    linarith
  have hD : 0 ≤ Real.logb 2 q - Real.logb 2 ((q : ℝ) - 1) := by
    rcases eq_or_lt_of_le (show (1 : ℕ) ≤ q from hq.one_lt.le) with h | h
    · simp [← h]
    have h1 : (0 : ℝ) < (q : ℝ) - 1 := by
      have : (2 : ℝ) ≤ q := by exact_mod_cast hq.two_le
      linarith
    have : Real.logb 2 ((q : ℝ) - 1) ≤ Real.logb 2 q :=
      Real.logb_le_logb_of_le (by norm_num) h1 (by linarith)
    linarith
  rw [typeEntropy_prime_formula hq]
  have hsplit : Real.logb 2 q - ((q : ℝ) - 1) / q * Real.logb 2 ((q : ℝ) - 1)
      = Real.logb 2 q / q + (((q : ℝ) - 1) / q) * (Real.logb 2 q - Real.logb 2 ((q : ℝ) - 1)) := by
    field_simp
    ring
  rw [hsplit]
  have hnn : 0 ≤ ((q : ℝ) - 1) / q := by
    have h1 : (1 : ℝ) ≤ q := by exact_mod_cast hq.one_lt.le
    exact div_nonneg (by linarith) hq0.le
  nlinarith

/-- **Upper rung bound**: `H(T_q) ≤ (log₂ q + 1/ln 2)/q`. -/
theorem typeEntropy_prime_upper {q : ℕ} (hq : q.Prime) :
    typeEntropy q ≤ (Real.logb 2 q + 1 / Real.log 2) / q := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hq2 : (2 : ℝ) ≤ q := by exact_mod_cast hq.two_le
  have hx1 : (1 : ℝ) ≤ (q : ℝ) - 1 := by linarith
  have hkey : Real.logb 2 q - Real.logb 2 ((q : ℝ) - 1) ≤ 1 / (((q : ℝ) - 1) * Real.log 2) := by
    have h := CyclicTypeChannel.logb_sub_logb_le hx1
    have hq' : (q : ℝ) - 1 + 1 = (q : ℝ) := by ring
    rwa [hq'] at h
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hxpos : (0 : ℝ) < (q : ℝ) - 1 := by linarith
  rw [typeEntropy_prime_formula hq]
  have hsplit : Real.logb 2 q - ((q : ℝ) - 1) / q * Real.logb 2 ((q : ℝ) - 1)
      = Real.logb 2 q / q + (((q : ℝ) - 1) / q) * (Real.logb 2 q - Real.logb 2 ((q : ℝ) - 1)) := by
    field_simp
    ring
  rw [hsplit]
  have hbound : (((q : ℝ) - 1) / q) * (Real.logb 2 q - Real.logb 2 ((q : ℝ) - 1))
      ≤ 1 / (q * Real.log 2) := by
    calc (((q : ℝ) - 1) / q) * (Real.logb 2 q - Real.logb 2 ((q : ℝ) - 1))
        ≤ (((q : ℝ) - 1) / q) * (1 / (((q : ℝ) - 1) * Real.log 2)) := by
          apply mul_le_mul_of_nonneg_left hkey (by positivity)
      _ = 1 / (q * Real.log 2) := by field_simp
  have : Real.logb 2 q / q + 1 / (q * Real.log 2)
      = (Real.logb 2 q + 1 / Real.log 2) / q := by field_simp
  linarith [hbound, this.le, this.ge]

/-- **The decay sandwich for the abelian ladder**: every prime rung satisfies
`log₂ q / q ≤ H(T_q) ≤ (log₂ q + 1/ln 2) / q`. -/
theorem typeEntropy_prime_sandwich {q : ℕ} (hq : q.Prime) :
    Real.logb 2 q / q ≤ typeEntropy q ∧
      typeEntropy q ≤ (Real.logb 2 q + 1 / Real.log 2) / q :=
  ⟨typeEntropy_prime_lower hq, typeEntropy_prime_upper hq⟩

/-- `n² ≤ 2ⁿ` for `n ≥ 4`. -/
theorem sq_le_two_pow {n : ℕ} (hn : 4 ≤ n) : n ^ 2 ≤ 2 ^ n := by
  induction n with
  | zero => omega
  | succ k ih =>
    rcases Nat.lt_or_ge k 4 with hk | hk
    · have hk3 : k = 3 := by omega
      subst hk3; norm_num
    · have hks := ih (by omega)
      have hexp : 2 ^ (k + 1) = 2 * 2 ^ k := by ring
      have hk2 : 2 * k + 1 ≤ k ^ 2 := by nlinarith
      calc (k + 1) ^ 2 = k ^ 2 + (2 * k + 1) := by ring
        _ ≤ k ^ 2 + k ^ 2 := by omega
        _ = 2 * k ^ 2 := by ring
        _ ≤ 2 * 2 ^ k := by omega
        _ = 2 ^ (k + 1) := hexp.symm

/-- `log₂ n ≤ n / 2` for `n ≥ 4`. -/
theorem logb_two_le_half {n : ℕ} (hn : 4 ≤ n) : Real.logb 2 n ≤ (n : ℝ) / 2 := by
  have hn0 : (0 : ℝ) < n := by
    have : (0 : ℕ) < n := by omega
    exact_mod_cast this
  have hpow : ((n : ℝ)) ^ 2 ≤ (2 : ℝ) ^ n := by
    have := sq_le_two_pow hn
    exact_mod_cast this
  have h := Real.logb_le_logb_of_le (b := 2) (by norm_num) (by positivity) hpow
  rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one] at h
  push_cast at h
  linarith

/-- **Only degree 2 reaches a full bit.**  For every prime degree `q ≥ 3` the
Frobenius entropy is strictly below one bit; at `q = 2` it equals one bit
(`CyclicTypeChannel.typeEntropy_val_2`). -/
theorem typeEntropy_prime_lt_one {q : ℕ} (hq : q.Prime) (hq2 : q ≠ 2) : typeEntropy q < 1 := by
  have hq3 : 3 ≤ q := by
    rcases hq.two_le.lt_or_eq with h | h
    · omega
    · omega
  rcases eq_or_lt_of_le hq3 with h3 | h3
  · -- `q = 3` : `H = log₂ 3 - 2/3 < 1` because `27 < 32`.
    have hq3' : q = 3 := h3.symm
    subst hq3'
    rw [typeEntropy_prime_formula hq]
    have h27 : Real.logb 2 3 < 5 / 3 := by
      have hlt : (3 : ℝ) ^ 3 < (2 : ℝ) ^ 5 := by norm_num
      have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hlt
      rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one] at h
      push_cast at h
      linarith
    norm_num
    linarith
  · -- `q ≥ 4` : use the decay bound and `log₂ q ≤ q/2`.
    have hq4 : 4 ≤ q := by omega
    have hq0 : (0 : ℝ) < q := by
      have : (0 : ℕ) < q := by omega
      exact_mod_cast this
    have hup := typeEntropy_prime_upper hq
    have hhalf := logb_two_le_half hq4
    have hlog : 1 / Real.log 2 < 1.4427 := one_div_log_two_lt
    have hqR : (4 : ℝ) ≤ q := by exact_mod_cast hq4
    have : (Real.logb 2 q + 1 / Real.log 2) / q < 1 := by
      rw [div_lt_one hq0]
      linarith
    linarith

/-- The degree-11 rung obeys the decay law, and stays strictly below one bit. -/
theorem ladder_eleven_below_cap : typeEntropy 11 < 1 :=
  typeEntropy_prime_lt_one (by norm_num) (by norm_num)

end AbelianLadder