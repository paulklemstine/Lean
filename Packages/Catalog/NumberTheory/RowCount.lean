/-
# Counting the entries of a `q`-Pascal row that are prime to `ℓ`

Kummer's theorem has a famous counting shadow: the number of entries of the `n`-th row of
Pascal's triangle that are **not** divisible by a prime `ℓ` is `∏ (digit_i(n) + 1)`, the product
over the base-`ℓ` digits of `n`.  This file establishes the `q`-analogue of that count, using the
`q`-Lucas congruence of `Catalog/NumberTheory/QKummer/Lucas.lean`.

Write `d` for a `q`-Lucas period of `ℓ` (for instance `d = ord_ℓ(q)`), and `n = dN + r` with
`0 ≤ r < d`.  Then

* `QKummer.not_dvd_qBinom_iff_lucas` — **the sharp indivisibility criterion**:
  for `k ≤ n`, `ℓ ∤ binom(n,k)_q` **iff** `k % d ≤ n % d` (no base-`d` carry) *and*
  `ℓ ∤ C(⌊n/d⌋, ⌊k/d⌋)`.  Unlike `QKummer.dvd_qBinom_iff_orderOf`, this needs no oddness
  hypothesis on `ℓ`;
* `QKummer.card_row_not_dvd_qBinom` — **the row count factorises**:
  `#{k ≤ n : ℓ ∤ binom(n,k)_q} = (n % d + 1) · #{A ≤ ⌊n/d⌋ : ℓ ∤ C(⌊n/d⌋, A)}`,
  i.e. the classical Kummer row count of the *block index* `⌊n/d⌋`, dilated by the purely
  residual factor `n % d + 1`.

The residual factor is `n % d + 1`, **not** `d − n % d`: the surviving residues are the `s` with
`s ≤ n % d`, and there are `n % d + 1` of them.  (An earlier guess in `FUTURE_DIRECTIONS.md`
had the complementary count; the criterion below settles it.)

The classical factor is then evaluated in closed form.  `QKummer.card_choose_not_dvd_eq_prod_digits`
proves Glaisher's count `#{A ≤ N : p ∤ C(N,A)} = ∏_i (digit_i(N) + 1)` — itself a consequence of
the same combinatorial lemma, applied to the classical one-step Lucas criterion — whence
`QKummer.card_row_not_dvd_qBinom_digits`:

`#{k ≤ n : ℓ ∤ binom(n,k)_q} = (n % d + 1) · ∏_i (digit_i(⌊n/d⌋) + 1)`, digits in base `ℓ`.

All statements hold at every prime, including `ℓ = 2`.
-/
import Catalog.NumberTheory.QKummer.Lucas

namespace QKummer

open Finset

section Criterion

variable {q ℓ d : ℕ} [hp : Fact ℓ.Prime]

/-- **Indivisibility criterion, Lucas form.**  For a `q`-Lucas period `d` of the prime `ℓ` and
`k ≤ n`, the Gaussian binomial coefficient `binom(n,k)_q` is prime to `ℓ` exactly when the
base-`d` digits do not carry (`k % d ≤ n % d`) and the classical binomial coefficient of the
block indices is prime to `ℓ`. -/
theorem not_dvd_qBinom_iff_lucas (h : IsQLucas q ℓ d) {n k : ℕ} (hk : k ≤ n) :
    ¬ ℓ ∣ qBinom q n k ↔ (k % d ≤ n % d ∧ ¬ ℓ ∣ (n / d).choose (k / d)) := by
  have hcast := qBinom_cast_lucas h hk
  have hrd : n % d < d := Nat.mod_lt _ h.pos
  constructor
  · intro hnd
    have hne : ((qBinom q n k : ℕ) : ZMod ℓ) ≠ 0 := fun hz =>
      hnd ((ZMod.natCast_eq_zero_iff _ _).mp hz)
    rw [hcast] at hne
    refine ⟨?_, fun hdvd => hne ?_⟩
    · by_contra hlt
      push_neg at hlt
      have : qBinom q (n % d) (k % d) = 0 := qBinom_eq_zero_of_lt hlt
      rw [this] at hne
      simp at hne
    · rw [(ZMod.natCast_eq_zero_iff _ _).mpr hdvd, zero_mul]
  · rintro ⟨hs, hch⟩ hdvd
    have hz : ((qBinom q n k : ℕ) : ZMod ℓ) = 0 := (ZMod.natCast_eq_zero_iff _ _).mpr hdvd
    rw [hcast] at hz
    rcases mul_eq_zero.mp hz with h1 | h2
    · exact hch ((ZMod.natCast_eq_zero_iff _ _).mp h1)
    · exact qBinom_cast_ne_zero h hs hrd h2

/-- **Indivisibility criterion at every prime `ℓ ∤ q`**, with `d = ord_ℓ(q)`.  No oddness
hypothesis is needed: the degenerate case `d = 1` (i.e. `q ≡ 1 mod ℓ`) is covered as well, where
the criterion degenerates to the classical one. -/
theorem not_dvd_qBinom_iff_orderOf (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) {n k : ℕ} (hk : k ≤ n) :
    ¬ ℓ ∣ qBinom q n k ↔
      (k % orderOf ((q : ℕ) : ZMod ℓ) ≤ n % orderOf ((q : ℕ) : ZMod ℓ) ∧
        ¬ ℓ ∣ (n / orderOf ((q : ℕ) : ZMod ℓ)).choose (k / orderOf ((q : ℕ) : ZMod ℓ))) := by
  set d := orderOf ((q : ℕ) : ZMod ℓ) with hddef
  have hdpos : 0 < d := orderOf_pos_of_not_dvd hnd
  rcases Nat.lt_or_ge 1 d with hd1 | hd1
  · exact not_dvd_qBinom_iff_lucas (isQLucas_orderOf hq (hddef ▸ hd1)) hk
  · have hd : d = 1 := by omega
    have hq1 : ((q : ℕ) : ZMod ℓ) = 1 := by
      have := pow_orderOf_eq_one ((q : ℕ) : ZMod ℓ)
      rwa [← hddef, hd, pow_one] at this
    have hcast := qBinom_cast_of_q_eq_one hq1 n k
    simp only [hd, Nat.mod_one, Nat.div_one, le_refl, true_and]
    constructor
    · intro hnk hdvd
      exact hnk ((ZMod.natCast_eq_zero_iff _ _).mp
        (hcast.trans ((ZMod.natCast_eq_zero_iff _ _).mpr hdvd)))
    · intro hnc hdvd
      exact hnc ((ZMod.natCast_eq_zero_iff _ _).mp
        (hcast.symm.trans ((ZMod.natCast_eq_zero_iff _ _).mpr hdvd)))

end Criterion

section Counting

/-- The combinatorial core of the row count: a predicate on `{0, …, n}` cut out by "no base-`d`
carry against `n`, and a classical indivisibility on the block index" is counted by the product
of the residual count `n % d + 1` with the classical count on the block row. -/
theorem card_filter_of_digit_criterion {ℓ d n : ℕ} (hd : 0 < d) (P : ℕ → Prop)
    [DecidablePred P]
    (hiff : ∀ k, k ≤ n → (P k ↔ (k % d ≤ n % d ∧ ¬ ℓ ∣ (n / d).choose (k / d)))) :
    ((range (n + 1)).filter P).card
      = (n % d + 1) * ((range (n / d + 1)).filter (fun A => ¬ ℓ ∣ (n / d).choose A)).card := by
  classical
  have hsplit : ∀ A s : ℕ, s < d → (d * A + s) / d = A ∧ (d * A + s) % d = s := by
    intro A s hs
    refine ⟨?_, ?_⟩
    · rw [Nat.mul_add_div hd, Nat.div_eq_of_lt hs, Nat.add_zero]
    · rw [Nat.mul_add_mod, Nat.mod_eq_of_lt hs]
  have hn : n = d * (n / d) + n % d := (Nat.div_add_mod n d).symm
  have hrd : n % d < d := Nat.mod_lt _ hd
  have himg : (range (n + 1)).filter P
      = (((range (n / d + 1)).filter (fun A => ¬ ℓ ∣ (n / d).choose A)) ×ˢ
          range (n % d + 1)).image (fun p => d * p.1 + p.2) := by
    ext k
    simp only [mem_filter, mem_range, mem_image, mem_product, Prod.exists]
    constructor
    · rintro ⟨hk1, hk2⟩
      have hk : k ≤ n := by omega
      obtain ⟨hs, hch⟩ := (hiff k hk).mp hk2
      refine ⟨k / d, k % d, ⟨⟨?_, hch⟩, ?_⟩, ?_⟩
      · have : k / d ≤ n / d := Nat.div_le_div_right hk
        omega
      · omega
      · rw [Nat.div_add_mod]
    · rintro ⟨A, s, ⟨⟨hA, hch⟩, hs⟩, rfl⟩
      have hsd : s < d := by omega
      obtain ⟨hdiv, hmod⟩ := hsplit A s hsd
      have hAle : A ≤ n / d := by omega
      have hle : d * A + s ≤ n := by
        rcases eq_or_lt_of_le hAle with rfl | hlt
        · omega
        · have hstep : d * (A + 1) ≤ d * (n / d) := Nat.mul_le_mul_left d hlt
          rw [Nat.mul_succ] at hstep
          omega
      refine ⟨by omega, ?_⟩
      refine (hiff _ hle).mpr ⟨?_, ?_⟩
      · rw [hmod]; omega
      · rw [hdiv]; exact hch
  rw [himg, Finset.card_image_of_injOn, Finset.card_product, Finset.card_range]
  · exact Nat.mul_comm _ _
  · rintro ⟨A, s⟩ hp ⟨A', s'⟩ hp' heq
    simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, mem_filter, mem_range] at hp hp'
    have hsd : s < d := by omega
    have hsd' : s' < d := by omega
    simp only at heq
    obtain ⟨hdiv, hmod⟩ := hsplit A s hsd
    obtain ⟨hdiv', hmod'⟩ := hsplit A' s' hsd'
    have h1 : A = A' := by rw [← hdiv, ← hdiv', heq]
    have h2 : s = s' := by rw [← hmod, ← hmod', heq]
    simp [h1, h2]

end Counting

section Classical

variable {p : ℕ} [hp : Fact p.Prime]

/-- A binomial coefficient of a single base-`p` digit is prime to `p`. -/
theorem not_dvd_choose_of_lt_prime {r s : ℕ} (hs : s ≤ r) (hr : r < p) : ¬ p ∣ r.choose s := by
  intro hdvd
  have h : r.choose s * s.factorial * (r - s).factorial = r.factorial :=
    Nat.choose_mul_factorial_mul_factorial hs
  have hfac : p ∣ r.factorial := h ▸ (hdvd.mul_right _).mul_right _
  have := (Nat.Prime.dvd_factorial hp.out).mp hfac
  omega

/-- **One-step Lucas criterion.**  For `A ≤ N` and a prime `p`, `p ∤ C(N,A)` exactly when the last
base-`p` digits do not carry and `p ∤ C(⌊N/p⌋, ⌊A/p⌋)`. -/
theorem not_dvd_choose_iff_step {N A : ℕ} :
    ¬ p ∣ N.choose A ↔ (A % p ≤ N % p ∧ ¬ p ∣ (N / p).choose (A / p)) := by
  have hstep : N.choose A ≡ (N % p).choose (A % p) * (N / p).choose (A / p) [MOD p] :=
    Choose.choose_modEq_choose_mod_mul_choose_div_nat
  have hmod : p ∣ N.choose A ↔ p ∣ (N % p).choose (A % p) * (N / p).choose (A / p) := by
    constructor
    · intro hd
      exact (Nat.modEq_zero_iff_dvd).mp (((Nat.modEq_zero_iff_dvd).mpr hd).symm.trans hstep).symm
    · intro hd
      exact (Nat.modEq_zero_iff_dvd).mp (hstep.trans ((Nat.modEq_zero_iff_dvd).mpr hd))
  have hrp : N % p < p := Nat.mod_lt _ hp.out.pos
  constructor
  · intro hnd
    have hnprod : ¬ p ∣ (N % p).choose (A % p) * (N / p).choose (A / p) :=
      fun hc => hnd (hmod.mpr hc)
    refine ⟨?_, fun hc => hnprod (Dvd.dvd.mul_left hc _)⟩
    by_contra hlt
    push_neg at hlt
    exact hnprod (by rw [Nat.choose_eq_zero_of_lt hlt, zero_mul]; exact Dvd.intro 0 rfl)
  · rintro ⟨hs, hch⟩ hd
    rcases (Nat.Prime.dvd_mul hp.out).mp (hmod.mp hd) with h1 | h2
    · exact not_dvd_choose_of_lt_prime hs hrp h1
    · exact hch h2

/-- **Glaisher's count** (the counting shadow of Kummer's theorem).  The number of entries of the
`N`-th row of Pascal's triangle that are prime to `p` is the product of `digit + 1` over the
base-`p` digits of `N`. -/
theorem card_choose_not_dvd_eq_prod_digits (N : ℕ) :
    ((range (N + 1)).filter (fun A => ¬ p ∣ N.choose A)).card
      = ((Nat.digits p N).map (fun t => t + 1)).prod := by
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    rcases Nat.eq_zero_or_pos N with rfl | hN
    · have hmem : ∀ A ∈ range (0 + 1), ¬ p ∣ (0 : ℕ).choose A := by
        intro A hA
        simp only [Finset.mem_range] at hA
        obtain rfl : A = 0 := by omega
        simpa using hp.out.ne_one
      rw [Finset.filter_true_of_mem hmem]
      simp
    · have hp1 : 1 < p := hp.out.one_lt
      have hlt : N / p < N := Nat.div_lt_self hN hp1
      have hcount := card_filter_of_digit_criterion (ℓ := p) (d := p) (n := N) hp.out.pos
        (fun A => ¬ p ∣ N.choose A) (fun _ _ => not_dvd_choose_iff_step)
      rw [hcount, ih (N / p) hlt, Nat.digits_def' hp1 hN]
      simp

end Classical

section RowCount

variable {q ℓ d : ℕ} [hp : Fact ℓ.Prime]

/-- **The `q`-Kummer row count.**  For a `q`-Lucas period `d` of the prime `ℓ`, the number of
entries of the `n`-th `q`-Pascal row that are prime to `ℓ` equals the classical Kummer count of
the block row `⌊n/d⌋`, multiplied by the residual factor `n % d + 1`. -/
theorem card_row_not_dvd_qBinom (h : IsQLucas q ℓ d) (n : ℕ) :
    ((range (n + 1)).filter (fun k => ¬ ℓ ∣ qBinom q n k)).card
      = (n % d + 1) *
        ((range (n / d + 1)).filter (fun A => ¬ ℓ ∣ (n / d).choose A)).card :=
  card_filter_of_digit_criterion h.pos _ (fun _ hk => not_dvd_qBinom_iff_lucas h hk)

/-- **The `q`-Kummer row count at every prime `ℓ ∤ q`**, with `d = ord_ℓ(q)`. -/
theorem card_row_not_dvd_qBinom_orderOf (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) (n : ℕ) :
    ((range (n + 1)).filter (fun k => ¬ ℓ ∣ qBinom q n k)).card
      = (n % orderOf ((q : ℕ) : ZMod ℓ) + 1) *
        ((range (n / orderOf ((q : ℕ) : ZMod ℓ) + 1)).filter
          (fun A => ¬ ℓ ∣ (n / orderOf ((q : ℕ) : ZMod ℓ)).choose A)).card :=
  card_filter_of_digit_criterion (orderOf_pos_of_not_dvd hnd) _
    (fun _ hk => not_dvd_qBinom_iff_orderOf hq hnd hk)

/-- **Closed form for the `q`-Kummer row count.**  Combining the row-count factorisation with
Glaisher's digit-product count: the number of entries of the `n`-th `q`-Pascal row prime to `ℓ`
is `(n % d + 1) · ∏_i (digit_i(⌊n/d⌋) + 1)`, the digits being taken in base `ℓ`. -/
theorem card_row_not_dvd_qBinom_digits (h : IsQLucas q ℓ d) (n : ℕ) :
    ((range (n + 1)).filter (fun k => ¬ ℓ ∣ qBinom q n k)).card
      = (n % d + 1) * ((Nat.digits ℓ (n / d)).map (fun t => t + 1)).prod := by
  rw [card_row_not_dvd_qBinom h n, card_choose_not_dvd_eq_prod_digits (n / d)]

/-- **Closed form at every prime `ℓ ∤ q`**, with `d = ord_ℓ(q)`. -/
theorem card_row_not_dvd_qBinom_digits_orderOf (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) (n : ℕ) :
    ((range (n + 1)).filter (fun k => ¬ ℓ ∣ qBinom q n k)).card
      = (n % orderOf ((q : ℕ) : ZMod ℓ) + 1) *
        ((Nat.digits ℓ (n / orderOf ((q : ℕ) : ZMod ℓ))).map (fun t => t + 1)).prod := by
  rw [card_row_not_dvd_qBinom_orderOf hq hnd n, card_choose_not_dvd_eq_prod_digits]

/-- **Rows with all entries prime to `ℓ`.**  If the block index `⌊n/d⌋` is `0`, i.e. `n < d`,
then the whole `n`-th `q`-Pascal row is prime to `ℓ`: it has `n + 1` such entries. -/
theorem card_row_not_dvd_qBinom_of_lt (h : IsQLucas q ℓ d) {n : ℕ} (hn : n < d) :
    ((range (n + 1)).filter (fun k => ¬ ℓ ∣ qBinom q n k)).card = n + 1 := by
  have hdiv : n / d = 0 := Nat.div_eq_of_lt hn
  have hmod : n % d = n := Nat.mod_eq_of_lt hn
  rw [card_row_not_dvd_qBinom h n, hdiv, hmod]
  have hmem : ∀ A ∈ range (0 + 1), ¬ ℓ ∣ (0 : ℕ).choose A := by
    intro A hA
    simp only [Finset.mem_range] at hA
    obtain rfl : A = 0 := by omega
    simpa using hp.out.ne_one
  rw [Finset.filter_true_of_mem hmem, Finset.card_range, Nat.mul_one]

end RowCount

section TotalCount

/-- A blockwise summation principle: if `F` on the block `[Mb, (M+1)b)` is the weight `j + 1`
times a block value `G M`, then summing `F` over `[0, Mb)` multiplies the sum of `G` by the total
weight `∑_{t<b} (t+1)`. -/
theorem sum_range_mul_blockwise {b : ℕ} (F G : ℕ → ℕ)
    (hFG : ∀ M j, j < b → F (M * b + j) = (j + 1) * G M) (M : ℕ) :
    ∑ N ∈ range (M * b), F N = (∑ t ∈ range b, (t + 1)) * ∑ i ∈ range M, G i := by
  induction M with
  | zero => simp
  | succ M ih =>
      have hb : (M + 1) * b = M * b + b := by ring
      have hblock : ∑ j ∈ range b, F (M * b + j) = (∑ t ∈ range b, (t + 1)) * G M := by
        rw [Finset.sum_congr rfl (fun j hj => hFG M j (mem_range.mp hj)), ← Finset.sum_mul]
      rw [hb, Finset.sum_range_add, ih, hblock, Finset.sum_range_succ]
      ring

/-- The digit product satisfies the one-step recursion `P(N) = (N % ℓ + 1) · P(⌊N/ℓ⌋)`. -/
theorem prod_digits_succ {ℓ : ℕ} (hl : 1 < ℓ) (N : ℕ) :
    ((Nat.digits ℓ N).map (fun t => t + 1)).prod
      = (N % ℓ + 1) * ((Nat.digits ℓ (N / ℓ)).map (fun t => t + 1)).prod := by
  rcases Nat.eq_zero_or_pos N with rfl | hN
  · simp
  · rw [Nat.digits_def' hl hN]
    simp

/-- **Exact self-similar total count for Pascal's triangle.**  Summing Glaisher's row count over
the first `ℓ^m` rows gives exactly `(∑_{t<ℓ} (t+1))^m = (ℓ(ℓ+1)/2)^m`. -/
theorem sum_prod_digits_pow {ℓ : ℕ} (hl : 1 < ℓ) (m : ℕ) :
    ∑ N ∈ range (ℓ ^ m), ((Nat.digits ℓ N).map (fun t => t + 1)).prod
      = (∑ t ∈ range ℓ, (t + 1)) ^ m := by
  induction m with
  | zero => simp
  | succ m ih =>
      have hpow : ℓ ^ (m + 1) = ℓ ^ m * ℓ := by ring
      have hstep : ∀ M j, j < ℓ →
          ((Nat.digits ℓ (M * ℓ + j)).map (fun t => t + 1)).prod
            = (j + 1) * ((Nat.digits ℓ M).map (fun t => t + 1)).prod := by
        intro M j hj
        have hmod : (M * ℓ + j) % ℓ = j := by
          rw [Nat.mul_comm, Nat.mul_add_mod, Nat.mod_eq_of_lt hj]
        have hdiv : (M * ℓ + j) / ℓ = M := by
          rw [Nat.mul_comm, Nat.mul_add_div (by omega), Nat.div_eq_of_lt hj, Nat.add_zero]
        rw [prod_digits_succ hl, hmod, hdiv]
      rw [hpow, sum_range_mul_blockwise _ _ hstep, ih, pow_succ]
      ring

variable {q ℓ d : ℕ} [hp : Fact ℓ.Prime]

/-- **Exact self-similar total count for the `q`-Pascal triangle.**  Over the first `d·ℓ^m` rows,
the total number of entries prime to `ℓ` is exactly `(∑_{r<d}(r+1)) · (∑_{t<ℓ}(t+1))^m`, i.e.
`(d(d+1)/2) · (ℓ(ℓ+1)/2)^m`: the base-`d` dilation contributes one constant factor and the
classical self-similarity does the rest. -/
theorem sum_card_row_not_dvd_qBinom (h : IsQLucas q ℓ d) (m : ℕ) :
    ∑ n ∈ range (ℓ ^ m * d), ((range (n + 1)).filter (fun k => ¬ ℓ ∣ qBinom q n k)).card
      = (∑ r ∈ range d, (r + 1)) * (∑ t ∈ range ℓ, (t + 1)) ^ m := by
  have hl : 1 < ℓ := hp.out.one_lt
  have hstep : ∀ M j, j < d →
      ((range (M * d + j + 1)).filter (fun k => ¬ ℓ ∣ qBinom q (M * d + j) k)).card
        = (j + 1) * ((Nat.digits ℓ M).map (fun t => t + 1)).prod := by
    intro M j hj
    have hmod : (M * d + j) % d = j := by
      rw [Nat.mul_comm, Nat.mul_add_mod, Nat.mod_eq_of_lt hj]
    have hdiv : (M * d + j) / d = M := by
      rw [Nat.mul_comm, Nat.mul_add_div h.pos, Nat.div_eq_of_lt hj, Nat.add_zero]
    rw [card_row_not_dvd_qBinom_digits h, hmod, hdiv]
  rw [sum_range_mul_blockwise _ _ hstep, sum_prod_digits_pow hl]

end TotalCount

end QKummer