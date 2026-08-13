import Mathlib
import Algebra.QubitTrade.SuccessDensity

/-!
# QUBIT-TRADE XII: the exact number of successful records

`SuccessDensity.lean` bounds the number of *good* records — the length-`m`
records of numerators whose joint gcd is coprime to the order `r`, i.e. exactly
the records that `recordEstimate` turns into the true order — from below by
`r^m / 2`.  Here we compute that number **exactly**.

The count is Jordan's totient `J_m(r)`:

* `QubitTrade.sum_card_goodRecords` — the divisor identity
  `∑_{d ∣ r} #good(d, m) = r^m`, proved by an explicit bijection that rescales a
  record by the gcd of its entries with `r`;
* `QubitTrade.card_goodRecords_eq_moebius_sum` — Möbius inversion of that
  identity: `#good(r, m) = ∑_{d ∣ r} μ(d) · (r/d)^m`;
* `QubitTrade.card_goodRecords_eq_euler_product` — the closed Euler product
  `#good(r, m) = r^m · ∏_{p ∣ r} (1 − p^{−m})`.

The last statement is the exact form of the success density conjectured in the
previous cycle: the failure probability of an `m`-sample record is exactly
`1 − ∏_{p ∣ r} (1 − p^{−m})`, which is `≤ ω(r)·2^{−m}` and `< 1/2` for `m ≥ 2`,
recovering the earlier bounds and pinning the constant.
-/

namespace QubitTrade

open Finset ArithmeticFunction

variable {r m : ℕ}

/-! ## Rescaling records -/

/-- Dividing every entry of a record by a common divisor divides its gcd. -/
theorem recordGcd_map_div {e : ℕ} :
    ∀ {L : List ℕ}, (∀ x ∈ L, e ∣ x) → recordGcd (L.map (fun x => x / e)) * e = recordGcd L := by
  intro L
  induction L with
  | nil => intro _; simp [recordGcd]
  | cons a L ih =>
      intro h
      have ha : e ∣ a := h a (by simp)
      have hL : ∀ x ∈ L, e ∣ x := fun x hx => h x (by simp [hx])
      have h1 : recordGcd ((a :: L).map (fun x => x / e))
          = Nat.gcd (a / e) (recordGcd (L.map (fun x => x / e))) := by
        simp [recordGcd]
      have h2 : recordGcd (a :: L) = Nat.gcd a (recordGcd L) := by simp [recordGcd]
      have h3 : Nat.gcd a (recordGcd L)
          = Nat.gcd (a / e * e) (recordGcd (L.map (fun x => x / e)) * e) := by
        rw [Nat.div_mul_cancel ha, ih hL]
      rw [h1, h2, h3, Nat.gcd_mul_right]

/-- Multiplying every entry of a record by `e` multiplies its gcd by `e`. -/
theorem recordGcd_map_mul {e : ℕ} :
    ∀ L : List ℕ, recordGcd (L.map (fun x => e * x)) = e * recordGcd L := by
  intro L
  induction L with
  | nil => simp [recordGcd]
  | cons a L ih =>
      have h1 : recordGcd ((a :: L).map (fun x => e * x))
          = Nat.gcd (e * a) (recordGcd (L.map (fun x => e * x))) := by
        simp [recordGcd]
      have h2 : recordGcd (a :: L) = Nat.gcd a (recordGcd L) := by simp [recordGcd]
      rw [h1, ih, h2, Nat.gcd_mul_left]

/-- The records of `allRecords n m` whose gcd meets `n` in exactly `e`. -/
noncomputable def levelRecords (n m e : ℕ) : Finset (Fin m → ℕ) :=
  (allRecords n m).filter (fun f => Nat.gcd (recordGcd (List.ofFn f)) n = e)

theorem mem_levelRecords {n e : ℕ} {f : Fin m → ℕ} :
    f ∈ levelRecords n m e ↔
      (∀ i, f i < n) ∧ Nat.gcd (recordGcd (List.ofFn f)) n = e := by
  simp [levelRecords, allRecords, Fintype.mem_piFinset]

/-- Every record lies at exactly one level, and the levels are divisors of `n`. -/
theorem allRecords_eq_biUnion (hn : 0 < n) :
    allRecords n m = n.divisors.biUnion (fun e => levelRecords n m e) := by
  ext f
  simp only [Finset.mem_biUnion, Nat.mem_divisors]
  constructor
  · intro hf
    refine ⟨Nat.gcd (recordGcd (List.ofFn f)) n, ⟨Nat.gcd_dvd_right _ _, by omega⟩, ?_⟩
    exact Finset.mem_filter.mpr ⟨hf, rfl⟩
  · rintro ⟨e, -, he⟩
    exact (Finset.mem_filter.mp he).1

theorem card_levelRecords {n e : ℕ} (hn : 0 < n) (he : e ∣ n) :
    (levelRecords n m e).card = (goodRecords (n / e) m).card := by
  have hepos : 0 < e := Nat.pos_of_dvd_of_pos he hn
  refine Finset.card_bij' (fun f _ => fun i => f i / e) (fun g _ => fun i => e * g i)
    ?_ ?_ ?_ ?_
  · -- forward maps into `goodRecords (n / e) m`
    intro f hf
    rw [mem_levelRecords] at hf
    obtain ⟨hlt, hgcd⟩ := hf
    have hdvd : ∀ i, e ∣ f i := by
      intro i
      have h1 : e ∣ recordGcd (List.ofFn f) := hgcd ▸ Nat.gcd_dvd_left _ _
      exact h1.trans (recordGcd_dvd_mem (List.mem_ofFn.mpr ⟨i, rfl⟩))
    have hmapeq : List.ofFn (fun i => f i / e)
        = (List.ofFn f).map (fun x => x / e) := by
      simp [List.map_ofFn, Function.comp_def]
    have hgcd' : recordGcd (List.ofFn (fun i => f i / e)) * e = recordGcd (List.ofFn f) := by
      rw [hmapeq]
      exact recordGcd_map_div (fun x hx => by
        obtain ⟨i, rfl⟩ := List.mem_ofFn.mp hx
        exact hdvd i)
    have hkey : recordGcd (List.ofFn (fun i => f i / e)) = recordGcd (List.ofFn f) / e := by
      rw [← hgcd', Nat.mul_div_cancel _ hepos]
    simp only [goodRecords, allRecords, Finset.mem_filter, Fintype.mem_piFinset,
      Finset.mem_range]
    refine ⟨fun i => Nat.div_lt_div_of_lt_of_dvd he (hlt i), ?_⟩
    rw [hkey, ← hgcd]
    exact Nat.coprime_div_gcd_div_gcd (by omega)
  · -- backward maps into `levelRecords n m e`
    intro g hg
    simp only [goodRecords, allRecords, Finset.mem_filter, Fintype.mem_piFinset,
      Finset.mem_range] at hg
    obtain ⟨hlt, hcop⟩ := hg
    rw [mem_levelRecords]
    constructor
    · intro i
      have := hlt i
      calc e * g i < e * (n / e) := by
            exact mul_lt_mul_of_pos_left this hepos
        _ = n := Nat.mul_div_cancel' he
    · have hmapeq : List.ofFn (fun i => e * g i) = (List.ofFn g).map (fun x => e * x) := by
        simp [List.map_ofFn, Function.comp_def]
      rw [hmapeq, recordGcd_map_mul]
      calc Nat.gcd (e * recordGcd (List.ofFn g)) n
          = Nat.gcd (e * recordGcd (List.ofFn g)) (e * (n / e)) := by
            rw [Nat.mul_div_cancel' he]
        _ = e * Nat.gcd (recordGcd (List.ofFn g)) (n / e) := Nat.gcd_mul_left _ _ _
        _ = e := by rw [hcop, mul_one]
  · intro f hf
    rw [mem_levelRecords] at hf
    obtain ⟨-, hgcd⟩ := hf
    funext i
    have h1 : e ∣ recordGcd (List.ofFn f) := hgcd ▸ Nat.gcd_dvd_left _ _
    exact Nat.mul_div_cancel' (h1.trans (recordGcd_dvd_mem (List.mem_ofFn.mpr ⟨i, rfl⟩)))
  · intro g _
    funext i
    exact Nat.mul_div_cancel_left _ hepos

/-- **The divisor identity.**  Splitting the `n^m` records by the gcd of their
numerators with `n` shows that the good-record counts sum to `n^m` over the
divisors of `n`. -/
theorem sum_card_goodRecords (hn : 0 < n) :
    ∑ d ∈ n.divisors, (goodRecords d m).card = n ^ m := by
  have hdisj : (n.divisors : Set ℕ).PairwiseDisjoint (fun e => levelRecords n m e) := by
    intro a _ b _ hab
    refine Finset.disjoint_left.mpr ?_
    intro f ha hb
    rw [mem_levelRecords] at ha hb
    exact hab (ha.2 ▸ hb.2 ▸ rfl)
  have hcard : (allRecords n m).card = ∑ e ∈ n.divisors, (levelRecords n m e).card := by
    rw [allRecords_eq_biUnion hn, Finset.card_biUnion]
    intro a ha b hb hab
    exact hdisj ha hb hab
  rw [card_allRecords] at hcard
  have hstep : ∑ e ∈ n.divisors, (levelRecords n m e).card
      = ∑ e ∈ n.divisors, (goodRecords (n / e) m).card := by
    refine Finset.sum_congr rfl ?_
    intro e he
    exact card_levelRecords hn (Nat.dvd_of_mem_divisors he)
  rw [hcard, hstep]
  exact (Nat.sum_div_divisors n (fun d => (goodRecords d m).card)).symm

/-- **Exact count of the successful records (Möbius form).**  The number of
length-`m` records of numerators in `[0, r)` that recover the order `r` is the
Jordan totient `J_m(r) = ∑_{d ∣ r} μ(d)·(r/d)^m`. -/
theorem card_goodRecords_eq_moebius_sum (hr : 0 < r) :
    ((goodRecords r m).card : ℤ) = ∑ d ∈ r.divisors, moebius d * ((r / d : ℕ) : ℤ) ^ m := by
  have key := (ArithmeticFunction.sum_eq_iff_sum_smul_moebius_eq
      (f := fun d => ((goodRecords d m).card : ℤ)) (g := fun n => ((n : ℤ)) ^ m)).mp
      (by
        intro n hn
        exact_mod_cast sum_card_goodRecords (m := m) hn) r hr
  rw [← key, ← Nat.sum_divisorsAntidiagonal (fun d e => (moebius d : ℤ) * ((e : ℤ)) ^ m)]
  refine Finset.sum_congr rfl ?_
  intro x _
  simp

/-! ## The Euler product -/

/-- Möbius value of a squarefree product of distinct primes. -/
theorem moebius_prod_primes {t : Finset ℕ} (ht : ∀ p ∈ t, p.Prime) :
    moebius (∏ p ∈ t, p) = (-1 : ℤ) ^ t.card := by
  have hpair : (t : Set ℕ).Pairwise (Function.onFun Nat.Coprime (fun p => p)) := by
    intro a ha b hb hab
    exact (Nat.coprime_primes (ht a ha) (ht b hb)).mpr hab
  rw [isMultiplicative_moebius.map_prod (fun p => p) t hpair]
  rw [Finset.prod_congr rfl (fun p hp => moebius_apply_prime (ht p hp))]
  simp

/-- **Exact success density (Euler product).**  The number of length-`m` records
of numerators in `[0, r)` that recover the order `r` is `r^m ∏_{p ∣ r} (1 - p^{-m})`,
i.e. Jordan's totient `J_m(r)`.  Dividing by `r^m`, the success probability of an
`m`-sample record is exactly `∏_{p ∣ r} (1 - p^{-m})`. -/
theorem card_goodRecords_eq_euler_product (hr : 0 < r) :
    ((goodRecords r m).card : ℚ)
      = (r : ℚ) ^ m * ∏ p ∈ r.primeFactors, (1 - ((p : ℚ) ^ m)⁻¹) := by
  have hr0 : r ≠ 0 := by omega
  -- Möbius form, cast to `ℚ`
  have hM : ((goodRecords r m).card : ℚ)
      = ∑ d ∈ r.divisors, (moebius d : ℚ) * ((r / d : ℕ) : ℚ) ^ m := by
    have h := congrArg (fun z : ℤ => (z : ℚ)) (card_goodRecords_eq_moebius_sum (m := m) hr)
    push_cast at h
    exact h
  -- only squarefree divisors contribute
  have hsq : ∑ d ∈ r.divisors, (moebius d : ℚ) * ((r / d : ℕ) : ℚ) ^ m
      = ∑ d ∈ r.divisors with Squarefree d, (moebius d : ℚ) * ((r / d : ℕ) : ℚ) ^ m := by
    refine (Finset.sum_filter_of_ne ?_).symm
    intro d _ hne
    by_contra hns
    exact hne (by rw [moebius_eq_zero_of_not_squarefree hns]; simp)
  -- squarefree divisors are products of subsets of the prime factors
  have hpow : ∑ d ∈ r.divisors with Squarefree d, (moebius d : ℚ) * ((r / d : ℕ) : ℚ) ^ m
      = ∑ t ∈ r.primeFactors.powerset,
          (moebius t.val.prod : ℚ) * ((r / t.val.prod : ℕ) : ℚ) ^ m := by
    rw [Nat.sum_divisors_filter_squarefree hr0]
    congr 1
    rw [Nat.factors_eq]
    rfl
  -- expand the Euler product over subsets
  have hprod : ∏ p ∈ r.primeFactors, (1 - ((p : ℚ) ^ m)⁻¹)
      = ∑ t ∈ r.primeFactors.powerset, ∏ p ∈ t, (-(((p : ℚ) ^ m)⁻¹)) := by
    have hp1 : ∀ p : ℕ, (1 : ℚ) - ((p : ℚ) ^ m)⁻¹ = (-(((p : ℚ) ^ m)⁻¹)) + 1 := by
      intro p; ring
    rw [Finset.prod_congr rfl (fun p _ => hp1 p),
      Finset.prod_add (fun p : ℕ => -(((p : ℚ) ^ m)⁻¹)) (fun _ : ℕ => (1 : ℚ)) r.primeFactors]
    simp
  rw [hM, hsq, hpow, hprod, Finset.mul_sum]
  refine Finset.sum_congr rfl ?_
  intro t ht
  rw [Finset.mem_powerset] at ht
  have htp : ∀ p ∈ t, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors (ht hp)
  have hDval : t.val.prod = ∏ p ∈ t, p := by rw [Finset.prod_val]; rfl
  rw [hDval]
  set D : ℕ := ∏ p ∈ t, p with hDdef
  have hDdvd : D ∣ r :=
    Finset.prod_primes_dvd r (fun p hp => (htp p hp).prime)
      (fun p hp => Nat.dvd_of_mem_primeFactors (ht hp))
  have hDpos : 0 < D := Finset.prod_pos (fun p hp => (htp p hp).pos)
  have hDQ : ((D : ℚ)) ≠ 0 := Nat.cast_ne_zero.mpr hDpos.ne'
  have hmu : (moebius D : ℚ) = (-1 : ℚ) ^ t.card := by
    rw [hDdef, moebius_prod_primes htp]
    push_cast
    ring
  have hcast : ((r / D : ℕ) : ℚ) = (r : ℚ) / (D : ℚ) := Nat.cast_div hDdvd hDQ
  have hDpow : ((D : ℚ)) ^ m = ∏ p ∈ t, ((p : ℚ)) ^ m := by
    rw [hDdef, Finset.prod_pow]
    push_cast
    rfl
  have hprodt : ∏ p ∈ t, (-(((p : ℚ) ^ m)⁻¹)) = (-1 : ℚ) ^ t.card * ((D : ℚ) ^ m)⁻¹ := by
    have h1 : ∏ p ∈ t, (-(((p : ℚ) ^ m)⁻¹))
        = (∏ _p ∈ t, (-1 : ℚ)) * ∏ p ∈ t, (((p : ℚ) ^ m)⁻¹) := by
      rw [← Finset.prod_mul_distrib]
      exact Finset.prod_congr rfl (fun p _ => by ring)
    rw [h1, Finset.prod_const, hDpow, ← Finset.prod_inv_distrib]
  rw [hmu, hcast, hprodt, div_pow]
  field_simp

end QubitTrade