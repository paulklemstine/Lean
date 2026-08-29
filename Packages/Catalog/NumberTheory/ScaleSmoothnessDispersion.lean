import Catalog.NumberTheory.QRDialLocalStatistics

/-!
# Global structure correction for `x² − N`: mean one, and uniformly bounded dispersion

This is the global half of the round-73 #4 (exp 562) **RANDOM-AT-SCALE** finding.
`Catalog.NumberTheory.QRDialLocalStatistics` computed, prime by prime, the exact
distribution of the local correction

  `localFactor p N = (p − dial p N)/(p − 1)`

by which the `p`-part of the smoothness density of `x² − N` differs from that of
a random integer.  Multiplying over the primes `p ≤ B` gives the *structure
correction*

  `structureCorrection a N = ∏_{i} localFactor (a i) (N i)`,

the full multiplicative factor relating the (Dickman-type) heuristic smoothness
probability of `x² − N` to that of a size-matched random integer.

## Main results

* `sum_structureCorrection` — **mean exactly one**.  Averaged over the residue
  data `N`, the structure correction is exactly `1`, for *every* finite family
  of odd primes.  Formalises the experimental null `r(u) = 1`: quadratic-sieve
  polynomials carry no ensemble-level smoothness edge, at any `u`.
* `sum_structureCorrection_crt` — the same statement genuinely averaged over
  `N mod ∏ p` via the Chinese remainder theorem.
* `sum_structureCorrection_sq`, `sum_structureCorrection_centred_sq` — the
  variance is exactly `dispersionBound a − 1` with
  `dispersionBound a = ∏_p (1 + 1/(p(p−1)))`.
* `dispersionBound_le_two` — **uniform dispersion bound**: for any finite set of
  distinct odd primes, `dispersionBound a ≤ 2`, however large the smoothness
  bound `B`.  The measured per-`N` overdispersion `D = 1.61 [1.50,1.73]` sits
  inside this a-priori ceiling; the numerical value of the infinite product over
  all odd primes is ≈ `1.30`.
* `chebyshev_structureCorrection` — a finite Chebyshev inequality: the fraction
  of `N` whose structure correction deviates from `1` by at least `t` is at most
  `(dispersionBound a − 1)/t² ≤ 1/t²`.
* `no_first_order_smoothness_edge` — the packaged null statement: mean exactly
  one *and* deviation mass controlled uniformly in the prime family.

Everything is exact and rational; no analytic estimate is used anywhere.
-/

namespace ScaleSmoothness

open Finset

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The **structure correction**: the product over the primes of the family of the
local corrections.  A random integer has `structureCorrection = 1` identically. -/
def structureCorrection (a : ι → ℕ) [∀ i, NeZero (a i)] (N : ∀ i, ZMod (a i)) : ℚ :=
  ∏ i, localFactor (a i) (N i)

/-- The **dispersion ceiling** `∏_p (1 + 1/(p(p−1)))`: the exact second moment of the
structure correction. -/
def dispersionBound (a : ι → ℕ) : ℚ :=
  ∏ i, (1 + 1 / ((a i : ℚ) * ((a i : ℚ) - 1)))

section Family

variable (a : ι → ℕ) [∀ i, Fact (a i).Prime] (hodd : ∀ i, a i ≠ 2)

include hodd

omit [Fintype ι] [DecidableEq ι] in
theorem three_le_a (i : ι) : (3 : ℚ) ≤ (a i : ℚ) := by
  have := three_le_of_ne_two (a i) (hodd i)
  exact_mod_cast this

/-- **Mean exactly one.**  Summed over all residue data, the structure correction
equals the number of residue data.  Equivalently: the average structure
correction is exactly `1`.  This is the exact form of the experimental null
`r(u) = 1` — the quadratic shape of `x² − N` produces no ensemble-level
smoothness bias at any smoothness bound. -/
theorem sum_structureCorrection :
    ∑ N : (∀ i, ZMod (a i)), structureCorrection a N = ∏ i, (a i : ℚ) := by
  have key := Finset.prod_univ_sum (fun i => (univ : Finset (ZMod (a i))))
    (fun i (N : ZMod (a i)) => localFactor (a i) N)
  rw [Fintype.piFinset_univ] at key
  simp only [structureCorrection]
  rw [← key]
  exact Finset.prod_congr rfl fun i _ => sum_localFactor (a i) (hodd i)

/-- **Second moment.**  `∑_N C(N)² = ∏_p (p + 1/(p−1))`. -/
theorem sum_structureCorrection_sq :
    ∑ N : (∀ i, ZMod (a i)), (structureCorrection a N) ^ 2 =
      ∏ i, ((a i : ℚ) + 1 / ((a i : ℚ) - 1)) := by
  have key := Finset.prod_univ_sum (fun i => (univ : Finset (ZMod (a i))))
    (fun i (N : ZMod (a i)) => (localFactor (a i) N) ^ 2)
  rw [Fintype.piFinset_univ] at key
  simp only [structureCorrection, ← Finset.prod_pow]
  rw [← key]
  exact Finset.prod_congr rfl fun i _ => sum_localFactor_sq (a i) (hodd i)

omit hodd in
theorem card_pi_zmod : (Fintype.card (∀ i, ZMod (a i)) : ℚ) = ∏ i, (a i : ℚ) := by
  rw [Fintype.card_pi]
  push_cast
  exact Finset.prod_congr rfl fun i _ => by rw [ZMod.card]

omit [DecidableEq ι] in
/-- The second moment factorises as `(number of residue data) × dispersionBound`. -/
theorem prod_second_moment_eq :
    ∏ i, ((a i : ℚ) + 1 / ((a i : ℚ) - 1)) = (∏ i, (a i : ℚ)) * dispersionBound a := by
  rw [dispersionBound, ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun i _ => ?_
  have h3 := three_le_a a hodd i
  have h1 : (a i : ℚ) - 1 ≠ 0 := by linarith
  have h0 : (a i : ℚ) ≠ 0 := by linarith
  field_simp

/-- **Exact variance of the structure correction.**  The centred second moment is
`(number of residue data) × (dispersionBound a − 1)`; i.e. the variance of the
structure correction is exactly `∏_p (1 + 1/(p(p−1))) − 1`.  This is the exact
source of the per-`N` clustering measured as `D = 1.61`. -/
theorem sum_structureCorrection_centred_sq :
    ∑ N : (∀ i, ZMod (a i)), (structureCorrection a N - 1) ^ 2 =
      (∏ i, (a i : ℚ)) * (dispersionBound a - 1) := by
  have expand : ∀ N : (∀ i, ZMod (a i)), (structureCorrection a N - 1) ^ 2 =
      (structureCorrection a N) ^ 2 - 2 * structureCorrection a N + 1 := by
    intro N; ring
  simp only [expand]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    sum_structureCorrection a hodd, sum_structureCorrection_sq a hodd,
    prod_second_moment_eq a hodd, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [card_pi_zmod a]
  ring

end Family

/-! ### The Chinese-remainder form: averaging over `N mod ∏ p` -/

instance neZero_prod_primes (a : ι → ℕ) [∀ i, Fact (a i).Prime] : NeZero (∏ i, a i) :=
  ⟨Finset.prod_ne_zero_iff.2 fun i _ => (Fact.out : (a i).Prime).ne_zero⟩

/-- **Mean exactly one, averaged over `N` modulo the primorial.**  Transporting
`sum_structureCorrection` along the Chinese remainder isomorphism
`ZMod (∏ p) ≃+* ∏ ZMod p` shows that the average structure correction over a
full period of `N` is exactly `1`. -/
theorem sum_structureCorrection_crt (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) (hcop : Pairwise (Function.onFun Nat.Coprime a)) :
    ∑ N : ZMod (∏ i, a i), structureCorrection a (ZMod.prodEquivPi a hcop N) =
      ∏ i, (a i : ℚ) := by
  calc ∑ N : ZMod (∏ i, a i), structureCorrection a (ZMod.prodEquivPi a hcop N)
      = ∑ x : (∀ i, ZMod (a i)), structureCorrection a x :=
        Fintype.sum_equiv (ZMod.prodEquivPi a hcop).toEquiv _ _ (fun _ => rfl)
    _ = ∏ i, (a i : ℚ) := sum_structureCorrection a hodd

/-! ### A uniform ceiling on the dispersion -/

/-- Telescoping evaluation `∑_{n=3}^{M} 1/(n(n−1)) = 1/2 − 1/M`. -/
theorem sum_inv_consecutive (M : ℕ) (hM : 3 ≤ M) :
    ∑ n ∈ Finset.Icc 3 M, (1 : ℚ) / ((n : ℚ) * ((n : ℚ) - 1)) = 1 / 2 - 1 / (M : ℚ) := by
  induction M with
  | zero => omega
  | succ m ih =>
    rcases Nat.lt_or_ge m 3 with hm | hm
    · interval_cases m
      · omega
      · omega
      · norm_num
    · rw [Finset.sum_Icc_succ_top (by omega), ih (by omega)]
      have hm0 : (3 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
      have h1 : (m : ℚ) ≠ 0 := by linarith
      have h2 : ((m : ℚ) + 1) ≠ 0 := by linarith
      push_cast
      rw [show ((m : ℚ) + 1 - 1) = (m : ℚ) by ring]
      field_simp
      ring

/-- For any finite set of naturals `≥ 3`, `∑ 1/(n(n−1)) ≤ 1/2`. -/
theorem sum_inv_le_half (S : Finset ℕ) (hS : ∀ n ∈ S, 3 ≤ n) :
    ∑ n ∈ S, (1 : ℚ) / ((n : ℚ) * ((n : ℚ) - 1)) ≤ 1 / 2 := by
  rcases S.eq_empty_or_nonempty with rfl | hne
  · simp
  · set M := S.max' hne with hMdef
    have hM3 : 3 ≤ M := hS _ (S.max'_mem hne)
    have hsub : S ⊆ Finset.Icc 3 M := fun n hn =>
      Finset.mem_Icc.2 ⟨hS n hn, S.le_max' n hn⟩
    have hnonneg : ∀ n ∈ Finset.Icc 3 M, n ∉ S →
        0 ≤ (1 : ℚ) / ((n : ℚ) * ((n : ℚ) - 1)) := by
      intro n hn _
      have h3 : (3 : ℚ) ≤ (n : ℚ) := by exact_mod_cast (Finset.mem_Icc.1 hn).1
      have hd : (0 : ℚ) < (n : ℚ) * ((n : ℚ) - 1) := by nlinarith
      exact le_of_lt (div_pos one_pos hd)
    have hle := Finset.sum_le_sum_of_subset_of_nonneg hsub hnonneg
    rw [sum_inv_consecutive M hM3] at hle
    have hMpos : (0 : ℚ) < (M : ℚ) := by
      have : (3 : ℚ) ≤ (M : ℚ) := by exact_mod_cast hM3
      linarith
    have : (0 : ℚ) < 1 / (M : ℚ) := by positivity
    linarith

omit [Fintype ι] in
/-- `∏ (1 + xᵢ) ≤ 1/(1 − ∑ xᵢ)` for nonnegative `xᵢ` of total mass `< 1`. -/
theorem prod_one_add_le_inv (s : Finset ι) (x : ι → ℚ) (hx : ∀ i, 0 ≤ x i)
    (h : ∑ i ∈ s, x i < 1) : ∏ i ∈ s, (1 + x i) ≤ 1 / (1 - ∑ i ∈ s, x i) := by
  induction s using Finset.induction with
  | empty => simp
  | insert j s hj ih =>
    rw [Finset.sum_insert hj] at h ⊢
    rw [Finset.prod_insert hj]
    have hsnn : 0 ≤ ∑ i ∈ s, x i := Finset.sum_nonneg fun i _ => hx i
    have hs1 : ∑ i ∈ s, x i < 1 := by have := hx j; linarith
    have hIH := ih hs1
    have hpos : (0 : ℚ) < 1 - ∑ i ∈ s, x i := by linarith
    have hpos2 : (0 : ℚ) < 1 - (x j + ∑ i ∈ s, x i) := by linarith
    have hstep : (1 + x j) * (1 / (1 - ∑ i ∈ s, x i)) ≤ 1 / (1 - (x j + ∑ i ∈ s, x i)) := by
      rw [mul_one_div, div_le_div_iff₀ hpos hpos2]
      nlinarith [hx j, hsnn]
    calc (1 + x j) * ∏ i ∈ s, (1 + x i)
        ≤ (1 + x j) * (1 / (1 - ∑ i ∈ s, x i)) := by
          have : (0 : ℚ) ≤ 1 + x j := by have := hx j; linarith
          exact mul_le_mul_of_nonneg_left hIH this
      _ ≤ 1 / (1 - (x j + ∑ i ∈ s, x i)) := hstep

/-- **Uniform dispersion ceiling.**  For any finite family of *distinct* odd primes
— i.e. for any smoothness bound `B`, however large — the second moment of the
structure correction is at most `2`.  The overdispersion of the per-`N`
smoothness rate can therefore never exceed an absolute constant; the measured
`D = 1.61` is inside this ceiling. -/
theorem dispersionBound_le_two (a : ι → ℕ) [∀ i, Fact (a i).Prime] (hodd : ∀ i, a i ≠ 2)
    (hinj : Function.Injective a) : dispersionBound a ≤ 2 := by
  set x : ι → ℚ := fun i => 1 / ((a i : ℚ) * ((a i : ℚ) - 1)) with hxdef
  have hx : ∀ i, 0 ≤ x i := by
    intro i
    have h3 := three_le_a a hodd i
    have hd : (0 : ℚ) < (a i : ℚ) * ((a i : ℚ) - 1) := by nlinarith
    rw [hxdef]; dsimp only; exact le_of_lt (div_pos one_pos hd)
  have himg : ∑ i, x i = ∑ n ∈ Finset.image a univ, (1 : ℚ) / ((n : ℚ) * ((n : ℚ) - 1)) := by
    rw [Finset.sum_image fun i _ j _ h => hinj h]
  have hhalf : ∑ i, x i ≤ 1 / 2 := by
    rw [himg]
    refine sum_inv_le_half _ fun n hn => ?_
    obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hn
    exact three_le_of_ne_two (a i) (hodd i)
  have hlt : ∑ i, x i < 1 := by linarith
  have hprod := prod_one_add_le_inv (univ : Finset ι) x hx hlt
  have hden : (0 : ℚ) < 1 - ∑ i, x i := by linarith
  have : 1 / (1 - ∑ i, x i) ≤ 2 := by
    rw [div_le_iff₀ hden]; linarith
  calc dispersionBound a = ∏ i, (1 + x i) := rfl
    _ ≤ 1 / (1 - ∑ i, x i) := hprod
    _ ≤ 2 := this

/-- **Finite Chebyshev inequality for the structure correction.**  At most a
`(dispersionBound a − 1)/t²` fraction of residue data have structure correction
deviating from `1` by `t` or more. -/
theorem chebyshev_structureCorrection (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) {t : ℚ} (ht : 0 < t) :
    t ^ 2 * (#{N : (∀ i, ZMod (a i)) | t ≤ |structureCorrection a N - 1|} : ℚ) ≤
      (∏ i, (a i : ℚ)) * (dispersionBound a - 1) := by
  classical
  set S : Finset (∀ i, ZMod (a i)) := {N | t ≤ |structureCorrection a N - 1|} with hS
  have hmem : ∀ N ∈ S, t ^ 2 ≤ (structureCorrection a N - 1) ^ 2 := by
    intro N hN
    have h : t ≤ |structureCorrection a N - 1| := by
      simpa [hS] using hN
    have habs : |structureCorrection a N - 1| ^ 2 = (structureCorrection a N - 1) ^ 2 :=
      sq_abs _
    nlinarith [abs_nonneg (structureCorrection a N - 1)]
  have h1 : (#S : ℚ) * t ^ 2 ≤ ∑ N ∈ S, (structureCorrection a N - 1) ^ 2 := by
    calc (#S : ℚ) * t ^ 2 = ∑ _N ∈ S, t ^ 2 := by
          rw [Finset.sum_const, nsmul_eq_mul]
      _ ≤ ∑ N ∈ S, (structureCorrection a N - 1) ^ 2 :=
          Finset.sum_le_sum hmem
  have h2 : ∑ N ∈ S, (structureCorrection a N - 1) ^ 2 ≤
      ∑ N : (∀ i, ZMod (a i)), (structureCorrection a N - 1) ^ 2 :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
      (fun N _ _ => sq_nonneg _)
  rw [sum_structureCorrection_centred_sq a hodd] at h2
  linarith [h1, h2]

/-- **The packaged null result.**  For every finite family of distinct odd primes:

* the average structure correction of `x² − N` over the residue data is *exactly*
  `1` (no first-order smoothness edge from quadratic structure), and
* the deviation mass is controlled uniformly in the family: the number of `N`
  with `|C(N) − 1| ≥ t` is at most `(∏ p)/t²`.

Together these are the exact-arithmetic counterpart of the experimental
`RANDOM-AT-SCALE` verdict `|r − 1| ≤ 0.217` together with a bounded per-`N`
overdispersion. -/
theorem no_first_order_smoothness_edge (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) (hinj : Function.Injective a) {t : ℚ} (ht : 0 < t) :
    (∑ N : (∀ i, ZMod (a i)), structureCorrection a N) = ∏ i, (a i : ℚ) ∧
      t ^ 2 * (#{N : (∀ i, ZMod (a i)) | t ≤ |structureCorrection a N - 1|} : ℚ) ≤
        (∏ i, (a i : ℚ)) := by
  refine ⟨sum_structureCorrection a hodd, ?_⟩
  have hch := chebyshev_structureCorrection a hodd ht
  have hd := dispersionBound_le_two a hodd hinj
  have hprodpos : (0 : ℚ) < ∏ i, (a i : ℚ) :=
    Finset.prod_pos fun i _ => by have := three_le_a a hodd i; linarith
  nlinarith [hch, hd, hprodpos]


/-! ### The QR dial at the global level, and strict (but bounded) clustering -/

/-- **The QR dial grips.**  Flipping a single coordinate of the residue data from a
quadratic residue to a nonresidue strictly increases the structure correction.
Quantitatively: `N` with many quadratic-residue coordinates is strictly *harder*
to make smooth.  This is the exact mechanism behind the measured
`Spearman(per-N rate, QR frac) = 0.32` at the low-`u` face. -/
theorem structureCorrection_qr_strict_mono (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) {N N' : ∀ i, ZMod (a i)} {j : ι}
    (hagree : ∀ i, i ≠ j → N i = N' i)
    (hQ : dial (a j) (N j) = 2) (hNQ : dial (a j) (N' j) = 0) :
    structureCorrection a N < structureCorrection a N' := by
  have hrest : ∏ i ∈ univ.erase j, localFactor (a i) (N i)
      = ∏ i ∈ univ.erase j, localFactor (a i) (N' i) :=
    Finset.prod_congr rfl fun i hi => by
      rw [hagree i (Finset.mem_erase.1 hi).1]
  have hpos : (0 : ℚ) < ∏ i ∈ univ.erase j, localFactor (a i) (N i) :=
    Finset.prod_pos fun i _ => localFactor_pos (a i) (hodd i) _
  have hj : localFactor (a j) (N j) < localFactor (a j) (N' j) :=
    localFactor_lt_of_qr (a j) (hodd j) hQ hNQ
  have hsplitN : structureCorrection a N
      = localFactor (a j) (N j) * ∏ i ∈ univ.erase j, localFactor (a i) (N i) :=
    (Finset.mul_prod_erase (univ : Finset ι) (fun i => localFactor (a i) (N i))
      (mem_univ j)).symm
  have hsplitN' : structureCorrection a N'
      = localFactor (a j) (N' j) * ∏ i ∈ univ.erase j, localFactor (a i) (N' i) :=
    (Finset.mul_prod_erase (univ : Finset ι) (fun i => localFactor (a i) (N' i))
      (mem_univ j)).symm
  rw [hsplitN, hsplitN', ← hrest]
  exact mul_lt_mul_of_pos_right hj hpos

/-- **Clustering is real.**  For a nonempty family of odd primes the dispersion is
strictly larger than `1`: the structure correction is genuinely non-constant, so
the per-`N` smoothness rate is genuinely overdispersed relative to Poisson.
Together with `dispersionBound_le_two` this pins the phenomenon between `1` and
`2`. -/
theorem one_lt_dispersionBound (a : ι → ℕ) [∀ i, Fact (a i).Prime] (hodd : ∀ i, a i ≠ 2)
    (j : ι) : 1 < dispersionBound a := by
  have hfac : ∀ i ∈ (univ : Finset ι), (1 : ℚ) ≤ 1 + 1 / ((a i : ℚ) * ((a i : ℚ) - 1)) := by
    intro i _
    have h3 := three_le_a a hodd i
    have hd : (0 : ℚ) < (a i : ℚ) * ((a i : ℚ) - 1) := by nlinarith
    have : (0 : ℚ) < 1 / ((a i : ℚ) * ((a i : ℚ) - 1)) := by positivity
    linarith
  have hrest : (1 : ℚ) ≤ ∏ i ∈ univ.erase j, (1 + 1 / ((a i : ℚ) * ((a i : ℚ) - 1))) := by
    calc (1 : ℚ) = ∏ _i ∈ univ.erase j, (1 : ℚ) := by simp
      _ ≤ _ := Finset.prod_le_prod (fun i _ => zero_le_one)
          (fun i hi => hfac i (Finset.mem_of_mem_erase hi))
  have hsplit : dispersionBound a
      = (1 + 1 / ((a j : ℚ) * ((a j : ℚ) - 1))) *
        ∏ i ∈ univ.erase j, (1 + 1 / ((a i : ℚ) * ((a i : ℚ) - 1))) :=
    (Finset.mul_prod_erase (univ : Finset ι)
      (fun i => 1 + 1 / ((a i : ℚ) * ((a i : ℚ) - 1))) (mem_univ j)).symm
  have h3 := three_le_a a hodd j
  have hd : (0 : ℚ) < (a j : ℚ) * ((a j : ℚ) - 1) := by nlinarith
  have hpos : (0 : ℚ) < 1 / ((a j : ℚ) * ((a j : ℚ) - 1)) := by positivity
  rw [hsplit]
  nlinarith [hpos, hrest]

/-! ### Non-vacuity: the family `{3, 5, 7}` -/

namespace Example357

/-- The family of the three smallest odd primes. -/
def a : Fin 3 → ℕ := ![3, 5, 7]

instance factPrime : ∀ i, Fact (Nat.Prime (a i)) := by
  intro i
  fin_cases i <;> exact ⟨by norm_num [a]⟩

theorem a_ne_two : ∀ i, a i ≠ 2 := by
  intro i; fin_cases i <;> simp [a]

theorem a_injective : Function.Injective a := by
  intro i j h
  fin_cases i <;> fin_cases j <;> simp_all [a]

/-- The dispersion of the family `{3,5,7}` is exactly `301/240 ≈ 1.254`, which is
strictly between `1` and the universal ceiling `2`. -/
theorem dispersionBound_eq : dispersionBound a = 301 / 240 := by
  simp [dispersionBound, Fin.prod_univ_three, a]
  norm_num

theorem dispersion_between : 1 < dispersionBound a ∧ dispersionBound a ≤ 2 := by
  refine ⟨one_lt_dispersionBound a a_ne_two 0, dispersionBound_le_two a a_ne_two a_injective⟩

/-- The mean structure correction over the `105` residue classes is exactly `1`. -/
theorem sum_eq : ∑ N : (∀ i, ZMod (a i)), structureCorrection a N = 105 := by
  rw [sum_structureCorrection a a_ne_two]
  simp [Fin.prod_univ_three, a]
  norm_num

end Example357

end ScaleSmoothness