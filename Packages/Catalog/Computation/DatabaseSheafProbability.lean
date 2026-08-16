import Mathlib

/-!
# The exact law for the sheaf condition of a random database

Model. A database has `n` columns and `k` rows, entries in an alphabet of size
`q`. Each cell is independently missing with probability `r`, and each present
cell carries an independent uniform alphabet value. By the gluing theorem
(`Catalog/Computation/DatabaseSheafGluing.lean`) the database is a section of the
constant data sheaf exactly when, in every column, all observed entries coincide.

The assignment conjectures `P(sheaf) = (1-r)^{C(n,k)}`. We compute the law
exactly and show the conjecture is false in every respect: the true law is
exponential in the *number of columns* `n`, with base

  `base(k,q,r) = q * (r + (1-r)/q)^k - (q-1) * r^k`,

and it is **increasing** in the missing rate `r`, not decreasing.

Main results.
* `card_column_agree` — the counting justification of the per-column agreement
  probability `q^{1-|S|}`.
* `sheafProb_eq_base_pow` — factorisation over columns: `P(sheaf) = base ^ n`.
* `baseSum_eq_base` — the closed form of the per-column factor (a binomial-sum
  evaluation over all `2^k` observation patterns).
* `base_mono` — monotonicity of the base in the missing rate.
* `base_le_one`, `base_lt_one` — the base is at most one, and strictly below one
  when `k ≥ 2`, `q ≥ 2` and `r < 1`; hence exponential decay in `n`.
* `no_missing_rate_power_law` — no exponent `C` whatsoever makes
  `P(sheaf) = (1-r)^C` true on `[0,1]`.

-- !-- Lab Notes -- !--
Hypothesis: `P(sheaf) = (1-r)^{C(n,k)}`, decaying in `r`.
Experiment: define the law as the exact finite sum over the `2^{nk}`
observation patterns weighted by the per-column agreement probabilities, then
evaluate it in closed form; Monte Carlo (see `ComputationalEvidence.md`) matches
the closed form to three digits at five parameter points.
Analysis: the sum factorises over columns because masks and values are cellwise
independent; the per-column factor is a two-term binomial evaluation. The base
increases with `r` because missing cells *remove* consistency constraints. At
`r = 0` the law is `q^{n(1-k)} < 1`, whereas `(1-r)^C = 1`: the conjecture fails
at a single point for every `C`.
Critique: the law is exact only for the constant sheaf and cellwise-independent
MCAR masking with uniform values; correlated columns or nontrivial restriction
maps change the per-column factor, though the factorisation over columns
persists whenever columns are independent.
Synthesis: the correct law is `P(sheaf) = base(k,q,r)^n`, exponential in the
number of columns, monotone increasing in the missing rate, and with no binomial
coefficient anywhere.
-- !-- Lab Notes -- !--
-/

open Finset

namespace DatabaseSheafProb

/-! ### The per-column agreement probability, justified by counting -/

/-- The number of value assignments to `k` rows in an alphabet of size `q` that
agree on the row set `S`, times `q ^ (|S| - 1)`, equals `q ^ k`.  Equivalently
the probability that the rows in `S` all carry the same uniform value is
`q ^ (1 - |S|)` (and `1` when `S = ∅`). -/
theorem card_column_agree (q k : ℕ) (S : Finset (Fin k)) :
    (Finset.univ.filter (fun v : Fin k → Fin q => ∀ j ∈ S, ∀ j' ∈ S, v j = v j')).card
        * q ^ (S.card - 1) = q ^ k := by
  classical
  rcases S.eq_empty_or_nonempty with rfl | hS
  · simp [Finset.filter_true_of_mem]
  obtain ⟨j₀, hj₀⟩ := hS
  have hSne : S.Nonempty := ⟨j₀, hj₀⟩
  -- each fibre of the "common value" map has `q ^ (k - |S|)` elements
  have hpi : ∀ a : Fin q, (Fintype.piFinset
      (fun j => if j ∈ S then ({a} : Finset (Fin q)) else Finset.univ)).card
        = q ^ (k - S.card) := by
    intro a
    rw [Fintype.card_piFinset, ← Finset.prod_mul_prod_compl S]
    have e1 : ∏ j ∈ S, (if j ∈ S then ({a} : Finset (Fin q)) else Finset.univ).card = 1 :=
      Finset.prod_eq_one fun j hj => by simp [hj]
    have e2 : ∏ j ∈ Sᶜ, (if j ∈ S then ({a} : Finset (Fin q)) else Finset.univ).card
        = q ^ (Sᶜ).card :=
      calc ∏ j ∈ Sᶜ, (if j ∈ S then ({a} : Finset (Fin q)) else Finset.univ).card
          = ∏ _j ∈ Sᶜ, q :=
            Finset.prod_congr rfl (fun j hj => by simp [Finset.mem_compl.1 hj])
        _ = q ^ (Sᶜ).card := by simp
    rw [e1, e2, one_mul, Finset.card_compl, Fintype.card_fin]
  -- the agreeing assignments are the disjoint union of these fibres
  have hbi : Finset.univ.filter (fun v : Fin k → Fin q => ∀ j ∈ S, ∀ j' ∈ S, v j = v j')
      = (Finset.univ : Finset (Fin q)).biUnion
          (fun a => Fintype.piFinset (fun j => if j ∈ S then {a} else Finset.univ)) := by
    ext v
    rw [Finset.mem_filter, Finset.mem_biUnion]
    constructor
    · rintro ⟨-, h⟩
      refine ⟨v j₀, Finset.mem_univ _, Fintype.mem_piFinset.2 fun j => ?_⟩
      by_cases hj : j ∈ S
      · simp only [hj, if_true, Finset.mem_singleton]
        exact h j hj j₀ hj₀
      · simp [hj]
    · rintro ⟨a, -, ha⟩
      refine ⟨Finset.mem_univ _, fun j hj j' hj' => ?_⟩
      have h1 := Fintype.mem_piFinset.1 ha j
      have h2 := Fintype.mem_piFinset.1 ha j'
      simp only [hj, if_true, Finset.mem_singleton] at h1
      simp only [hj', if_true, Finset.mem_singleton] at h2
      rw [h1, h2]
  have hdisj : ∀ a ∈ (Finset.univ : Finset (Fin q)), ∀ b ∈ (Finset.univ : Finset (Fin q)),
      a ≠ b → Disjoint
        (Fintype.piFinset (fun j => if j ∈ S then ({a} : Finset (Fin q)) else Finset.univ))
        (Fintype.piFinset (fun j => if j ∈ S then ({b} : Finset (Fin q)) else Finset.univ)) := by
    intro a _ b _ hab
    rw [Finset.disjoint_left]
    intro v hv hv'
    have h1 := Fintype.mem_piFinset.1 hv j₀
    have h2 := Fintype.mem_piFinset.1 hv' j₀
    simp only [hj₀, if_true, Finset.mem_singleton] at h1 h2
    exact hab (h1 ▸ h2 ▸ rfl)
  have hcard : (Finset.univ.filter
      (fun v : Fin k → Fin q => ∀ j ∈ S, ∀ j' ∈ S, v j = v j')).card = q * q ^ (k - S.card) := by
    rw [hbi, Finset.card_biUnion (fun a _ b _ hab =>
      hdisj a (Finset.mem_univ a) b (Finset.mem_univ b) hab)]
    rw [Finset.sum_congr rfl (fun a _ => hpi a)]
    simp [Finset.card_univ]
  rw [hcard]
  have h1 : 1 ≤ S.card := Finset.card_pos.2 hSne
  have h2 : S.card ≤ k := by simpa using Finset.card_le_card (Finset.subset_univ S)
  rw [mul_assoc, ← pow_add, show k - S.card + (S.card - 1) = k - 1 by omega, ← pow_succ']
  congr 1
  omega

/-! ### The exact law -/

variable (k q n : ℕ) (r : ℝ)

/-- Probability weight of the observation pattern `S` in a single column:
`|S|` cells observed, `k - |S|` missing. -/
noncomputable def maskWeight (k : ℕ) (r : ℝ) (S : Finset (Fin k)) : ℝ :=
  (1 - r) ^ S.card * r ^ (k - S.card)

/-- Probability that the observed entries of a column agree, given that exactly
the rows in `S` are observed there (`q ^ (1 - |S|)`, and `1` for `S = ∅`). -/
noncomputable def colGlueProb (q k : ℕ) (S : Finset (Fin k)) : ℝ :=
  ((q : ℝ)⁻¹) ^ (S.card - 1)

/-- The per-column probability that the column is consistent. -/
noncomputable def baseSum (k q : ℕ) (r : ℝ) : ℝ :=
  ∑ S : Finset (Fin k), maskWeight k r S * colGlueProb q k S

/-- Probability that a random `k × n` database with missing rate `r` and uniform
alphabet of size `q` satisfies the sheaf condition: the exact finite sum over all
column-wise observation patterns. -/
noncomputable def sheafProb (n k q : ℕ) (r : ℝ) : ℝ :=
  ∑ M : Fin n → Finset (Fin k), ∏ c : Fin n, maskWeight k r (M c) * colGlueProb q k (M c)

/-- Closed form of the per-column factor. -/
noncomputable def base (k q : ℕ) (r : ℝ) : ℝ :=
  (q : ℝ) * (r + (1 - r) / q) ^ k - ((q : ℝ) - 1) * r ^ k

/-- **Factorisation over columns.** Columns are independent, so the probability
of the sheaf condition is the `n`-th power of the per-column probability. -/
theorem sheafProb_eq_baseSum_pow (n k q : ℕ) (r : ℝ) :
    sheafProb n k q r = baseSum k q r ^ n := by
  classical
  have h := Finset.prod_univ_sum (fun _ : Fin n => (Finset.univ : Finset (Finset (Fin k))))
    (fun (_ : Fin n) (S : Finset (Fin k)) => maskWeight k r S * colGlueProb q k S)
  rw [Fintype.piFinset_univ] at h
  simp only [baseSum, sheafProb] at *
  rw [← h]
  simp [Finset.prod_const]

/-- Binomial evaluation over all `2^k` observation patterns of one column. -/
theorem sum_pow_card (k : ℕ) (a b : ℝ) :
    ∑ S : Finset (Fin k), a ^ S.card * b ^ (k - S.card) = (a + b) ^ k := by
  classical
  have h := Finset.prod_add (fun _ : Fin k => a) (fun _ : Fin k => b) Finset.univ
  simp only [Finset.prod_const, Finset.card_univ, Fintype.card_fin] at h
  rw [h, Finset.powerset_univ]
  refine Finset.sum_congr rfl fun S _ => ?_
  rw [← Finset.compl_eq_univ_sdiff, Finset.card_compl, Fintype.card_fin]

/-- **Closed form of the per-column probability.** -/
theorem baseSum_eq_base (k q : ℕ) (hq : 0 < q) (r : ℝ) :
    baseSum k q r = base k q r := by
  classical
  have hq0 : (q : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  -- the summand, off the empty pattern, is `q * ((1-r)/q)^|S| * r^(k-|S|)`
  set T : Finset (Fin k) → ℝ := fun S => (q : ℝ) * (((1 - r) / q) ^ S.card * r ^ (k - S.card))
    with hT
  have hoff : ∀ S : Finset (Fin k), S ≠ ∅ →
      maskWeight k r S * colGlueProb q k S = T S := by
    intro S hS
    obtain ⟨m, hm⟩ : ∃ m, S.card = m + 1 :=
      ⟨S.card - 1, by have := Finset.card_pos.2 (Finset.nonempty_iff_ne_empty.2 hS); omega⟩
    simp only [maskWeight, colGlueProb, hT, div_pow, hm, Nat.add_sub_cancel, inv_pow]
    field_simp
    ring
  have hemptyT : T ∅ = (q : ℝ) * r ^ k := by simp [hT]
  have hemptyf : maskWeight k r (∅ : Finset (Fin k)) * colGlueProb q k ∅ = r ^ k := by
    simp [maskWeight, colGlueProb]
  have hTsum : ∑ S : Finset (Fin k), T S = (q : ℝ) * ((1 - r) / q + r) ^ k := by
    simp only [hT, ← Finset.mul_sum]
    rw [sum_pow_card]
  have hsplitf : ∑ S : Finset (Fin k), maskWeight k r S * colGlueProb q k S
      = (∑ S ∈ Finset.univ.erase (∅ : Finset (Fin k)), maskWeight k r S * colGlueProb q k S)
        + maskWeight k r ∅ * colGlueProb q k ∅ :=
    (Finset.sum_erase_add _ _ (Finset.mem_univ _)).symm
  have hsplitT : ∑ S : Finset (Fin k), T S
      = (∑ S ∈ Finset.univ.erase (∅ : Finset (Fin k)), T S) + T ∅ :=
    (Finset.sum_erase_add _ _ (Finset.mem_univ _)).symm
  have herase : ∑ S ∈ Finset.univ.erase (∅ : Finset (Fin k)),
        maskWeight k r S * colGlueProb q k S
      = ∑ S ∈ Finset.univ.erase (∅ : Finset (Fin k)), T S :=
    Finset.sum_congr rfl fun S hS => hoff S (Finset.ne_of_mem_erase hS)
  rw [baseSum, hsplitf, herase, hemptyf]
  have : ∑ S ∈ Finset.univ.erase (∅ : Finset (Fin k)), T S
      = (q : ℝ) * ((1 - r) / q + r) ^ k - (q : ℝ) * r ^ k := by
    rw [← hTsum] at *
    rw [hsplitT, hemptyT]; ring
  rw [this, base]
  rw [show r + (1 - r) / q = (1 - r) / q + r by ring]
  ring

/-! ### Monotonicity in the missing rate, and exponential decay in `n` -/

/-- A single algebraic identity behind all monotonicity statements: the increment
of the per-column probability is a positive multiple of the difference of two
geometric sums. -/
theorem base_sub_base (k q : ℕ) (hq : 0 < q) (r₁ r₂ : ℝ) :
    base k q r₂ - base k q r₁
      = ((q : ℝ) - 1) * (r₂ - r₁) *
        ((∑ i ∈ Finset.range k, (r₂ + (1 - r₂) / q) ^ i * (r₁ + (1 - r₁) / q) ^ (k - 1 - i))
          - ∑ i ∈ Finset.range k, r₂ ^ i * r₁ ^ (k - 1 - i)) := by
  have hq0 : (q : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  set A := r₂ + (1 - r₂) / q with hA
  set B := r₁ + (1 - r₁) / q with hB
  set Su := ∑ i ∈ Finset.range k, A ^ i * B ^ (k - 1 - i) with hSu
  set Sr := ∑ i ∈ Finset.range k, r₂ ^ i * r₁ ^ (k - 1 - i) with hSr
  have e1 : Su * (A - B) = A ^ k - B ^ k := geom_sum₂_mul A B k
  have e2 : Sr * (r₂ - r₁) = r₂ ^ k - r₁ ^ k := geom_sum₂_mul r₂ r₁ k
  have hu : (q : ℝ) * (A - B) = ((q : ℝ) - 1) * (r₂ - r₁) := by
    rw [hA, hB]; field_simp; ring
  simp only [base, ← hA, ← hB]
  linear_combination (-(q : ℝ)) * e1 + ((q : ℝ) - 1) * e2 + Su * hu

/-- The geometric sums are monotone in the base points. -/
theorem geom_sum_le (k : ℕ) {a₁ a₂ b₁ b₂ : ℝ} (ha : 0 ≤ a₁) (hb : 0 ≤ b₁)
    (h1 : a₁ ≤ a₂) (h2 : b₁ ≤ b₂) :
    ∑ i ∈ Finset.range k, a₁ ^ i * b₁ ^ (k - 1 - i)
      ≤ ∑ i ∈ Finset.range k, a₂ ^ i * b₂ ^ (k - 1 - i) := by
  refine Finset.sum_le_sum fun i _ => ?_
  exact mul_le_mul (pow_le_pow_left₀ ha h1 i) (pow_le_pow_left₀ hb h2 _)
    (pow_nonneg hb _) (pow_nonneg (ha.trans h1) i)

/-- **The sheaf condition becomes *more* likely as data goes missing.** The
per-column probability is monotone non-decreasing in the missing rate `r`: this
is the exact opposite of the conjectured decay `(1-r)^{C}`. -/
theorem base_mono (k q : ℕ) (hq : 1 ≤ q) {r₁ r₂ : ℝ} (h0 : 0 ≤ r₁) (h : r₁ ≤ r₂)
    (h1 : r₂ ≤ 1) : base k q r₁ ≤ base k q r₂ := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hq1 : (0 : ℝ) ≤ (q : ℝ) - 1 := by
    have : (1 : ℝ) ≤ q := by exact_mod_cast hq
    linarith
  have hr2 : 0 ≤ r₂ := h0.trans h
  have hu1 : r₁ ≤ r₁ + (1 - r₁) / q := by
    have : 0 ≤ (1 - r₁) / q := div_nonneg (by linarith) hq0.le
    linarith
  have hu2 : r₂ ≤ r₂ + (1 - r₂) / q := by
    have : 0 ≤ (1 - r₂) / q := div_nonneg (by linarith) hq0.le
    linarith
  have hgs := geom_sum_le k hr2 h0 hu2 hu1
  have hkey := base_sub_base k q (by omega) r₁ r₂
  nlinarith [hkey, hgs, mul_nonneg hq1 (sub_nonneg.2 h)]

/-- Value of the per-column probability at full missingness: an empty database
always glues. -/
@[simp] theorem base_at_one (k q : ℕ) (hq : 0 < q) : base k q 1 = 1 := by
  have hq0 : (q : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  simp [base]

/-- Value at zero missingness: all `k` rows must coincide, probability
`q ^ (1-k)` per column. -/
theorem base_at_zero (k q : ℕ) (hq : 0 < q) (hk : 0 < k) :
    base k q 0 = (q : ℝ) * ((q : ℝ)⁻¹) ^ k := by
  have hq0 : (q : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  simp [base, zero_pow hk.ne', inv_pow]

/-- The per-column probability is a probability: it never exceeds one. -/
theorem base_le_one (k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    base k q r ≤ 1 := by
  have := base_mono k q hq h0 h1 le_rfl
  rwa [base_at_one k q (by omega)] at this

/-- The per-column probability is nonnegative. -/
theorem base_nonneg (k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    0 ≤ base k q r := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have hu : r ≤ r + (1 - r) / q := by
    have : 0 ≤ (1 - r) / q := div_nonneg (by linarith) hq0.le
    linarith
  have hpow : r ^ k ≤ (r + (1 - r) / q) ^ k := pow_le_pow_left₀ h0 hu k
  have hrk : 0 ≤ r ^ k := pow_nonneg h0 k
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  simp only [base]
  nlinarith [hpow, hrk]

/-- **Strict decay.** For at least two rows, an alphabet with at least two
letters and an incomplete missing rate, the per-column probability is strictly
below one, so the sheaf condition fails with probability tending to one
exponentially fast in the number of columns. -/
theorem base_lt_one (k q : ℕ) (hq : 2 ≤ q) (hk : 2 ≤ k) {r : ℝ} (h0 : 0 ≤ r) (h1 : r < 1) :
    base k q r < 1 := by
  have hq0 : (0 : ℝ) < q := by positivity
  have hqR : (2 : ℝ) ≤ q := by exact_mod_cast hq
  have hu : r < r + (1 - r) / q := by
    have : 0 < (1 - r) / q := div_pos (by linarith) (by exact_mod_cast hq0)
    linarith
  -- strict comparison of the two geometric sums at `r₂ = 1`
  have hstrict :
      (∑ i ∈ Finset.range k, (1 : ℝ) ^ i * r ^ (k - 1 - i))
        < ∑ i ∈ Finset.range k, ((1 : ℝ) + (1 - 1) / q) ^ i * (r + (1 - r) / q) ^ (k - 1 - i) := by
    refine Finset.sum_lt_sum (fun i _ => ?_) ⟨0, Finset.mem_range.2 (by omega), ?_⟩
    · have : r ^ (k - 1 - i) ≤ (r + (1 - r) / q) ^ (k - 1 - i) :=
        pow_le_pow_left₀ h0 hu.le _
      simpa using this
    · have hne : k - 1 - 0 ≠ 0 := by omega
      have : r ^ (k - 1 - 0) < (r + (1 - r) / q) ^ (k - 1 - 0) :=
        pow_lt_pow_left₀ hu h0 hne
      simpa using this
  have hkey := base_sub_base k q (by omega) r 1
  rw [base_at_one k q (by omega)] at hkey
  nlinarith [hkey, hstrict, mul_pos (by linarith : (0:ℝ) < (q:ℝ) - 1) (by linarith : (0:ℝ) < 1 - r)]

/-! ### The corrected law, and refutation of the conjectured one -/

/-- **Exact law for the sheaf condition.** The probability that a random `k × n`
database with cellwise missing rate `r` over an alphabet of size `q` is a section
of the constant data sheaf equals `base(k,q,r) ^ n`: exponential in the number of
columns, with an explicit base. -/
theorem sheafProb_eq_base_pow (n k q : ℕ) (hq : 0 < q) (r : ℝ) :
    sheafProb n k q r = ((q : ℝ) * (r + (1 - r) / q) ^ k - ((q : ℝ) - 1) * r ^ k) ^ n := by
  rw [sheafProb_eq_baseSum_pow, baseSum_eq_base k q hq r, base]

/-- Monotonicity of the full law in the missing rate. -/
theorem sheafProb_mono (n k q : ℕ) (hq : 1 ≤ q) {r₁ r₂ : ℝ} (h0 : 0 ≤ r₁) (h : r₁ ≤ r₂)
    (h1 : r₂ ≤ 1) : sheafProb n k q r₁ ≤ sheafProb n k q r₂ := by
  rw [sheafProb_eq_baseSum_pow, sheafProb_eq_baseSum_pow,
    baseSum_eq_base k q (by omega) r₁, baseSum_eq_base k q (by omega) r₂]
  exact pow_le_pow_left₀ (base_nonneg k q hq h0 (h.trans h1)) (base_mono k q hq h0 h h1) n

/-- **Exponential decay in the number of columns**, at a rate depending only on
`k, q, r` — and with no binomial coefficient in sight. -/
theorem sheafProb_lt_one (n k q : ℕ) (hn : 0 < n) (hk : 2 ≤ k) (hq : 2 ≤ q) {r : ℝ}
    (h0 : 0 ≤ r) (h1 : r < 1) : sheafProb n k q r < 1 := by
  rw [sheafProb_eq_baseSum_pow, baseSum_eq_base k q (by omega) r]
  exact pow_lt_one₀ (base_nonneg k q (by omega) h0 h1.le) (base_lt_one k q hq hk h0 h1) hn.ne'

/-- **Refutation of the conjectured law.** No exponent `C` at all — in
particular none of the form `C(n,k)` — makes `P(sheaf) = (1-r)^C` hold on the
whole range of missing rates: at `r = 0` the true probability is `q^{n(1-k)} < 1`
while `(1-0)^C = 1`. -/
theorem no_missing_rate_power_law (n k q C : ℕ) (hn : 0 < n) (hk : 2 ≤ k) (hq : 2 ≤ q) :
    ¬ ∀ r : ℝ, 0 ≤ r → r ≤ 1 → sheafProb n k q r = (1 - r) ^ C := by
  intro h
  have h0 := h 0 le_rfl zero_le_one
  have hlt : sheafProb n k q 0 < 1 :=
    sheafProb_lt_one n k q hn hk hq le_rfl one_pos
  rw [h0] at hlt
  simp at hlt

/-- The exact value at zero missing rate, which is what breaks the conjecture:
`q^{n(1-k)}`, strictly below one for `k, q ≥ 2`. -/
theorem sheafProb_at_zero (n k q : ℕ) (hq : 0 < q) (hk : 0 < k) :
    sheafProb n k q 0 = ((q : ℝ) * ((q : ℝ)⁻¹) ^ k) ^ n := by
  rw [sheafProb_eq_baseSum_pow, baseSum_eq_base k q hq 0, base_at_zero k q hq hk]

/-! ### First moment: the expected number of global sections -/

/-- Expected number of admissible values in a single column whose observed rows
are `S` (namely `q ^ (1 - |S|)`, and `q` when nothing is observed). -/
noncomputable def colExpSections (q k : ℕ) (S : Finset (Fin k)) : ℝ :=
  (q : ℝ) * ((q : ℝ)⁻¹) ^ S.card

/-- The expected number of global sections (complete databases consistent with
all observed entries) of a random database. -/
noncomputable def expSections (n k q : ℕ) (r : ℝ) : ℝ :=
  ∑ M : Fin n → Finset (Fin k), ∏ c : Fin n, maskWeight k r (M c) * colExpSections q k (M c)

/-- Columnwise factorisation, in the form used for both moments. -/
theorem sum_prod_factor (n k : ℕ) (f : Finset (Fin k) → ℝ) :
    ∑ M : Fin n → Finset (Fin k), ∏ _c : Fin n, f (M _c)
      = (∑ S : Finset (Fin k), f S) ^ n := by
  classical
  have h := Finset.prod_univ_sum (fun _ : Fin n => (Finset.univ : Finset (Finset (Fin k))))
    (fun (_ : Fin n) (S : Finset (Fin k)) => f S)
  rw [Fintype.piFinset_univ] at h
  rw [← h]
  simp [Finset.prod_const]

/-- **Exact first moment.** The expected number of global sections is
`(q * (r + (1-r)/q)^k)^n`; note that it exceeds the probability of the sheaf
condition by the factor coming from the fully unobserved columns. -/
theorem expSections_eq (n k q : ℕ) (hq : 0 < q) (r : ℝ) :
    expSections n k q r = ((q : ℝ) * (r + (1 - r) / q) ^ k) ^ n := by
  have hq0 : (q : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hq.ne'
  rw [expSections, sum_prod_factor n k (fun S => maskWeight k r S * colExpSections q k S)]
  congr 1
  have hterm : ∀ S : Finset (Fin k), maskWeight k r S * colExpSections q k S
      = (q : ℝ) * (((1 - r) / q) ^ S.card * r ^ (k - S.card)) := by
    intro S
    simp only [maskWeight, colExpSections, div_pow, inv_pow]
    field_simp
  rw [Finset.sum_congr rfl (fun S _ => hterm S), ← Finset.mul_sum, sum_pow_card]
  rw [show (1 - r) / (q : ℝ) + r = r + (1 - r) / q by ring]

/-- **First-moment (Markov) bound.** The probability of the sheaf condition never
exceeds the expected number of global sections. -/
theorem sheafProb_le_expSections (n k q : ℕ) (hq : 1 ≤ q) {r : ℝ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    sheafProb n k q r ≤ expSections n k q r := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  rw [sheafProb_eq_baseSum_pow, baseSum_eq_base k q (by omega) r, expSections_eq n k q (by omega) r]
  refine pow_le_pow_left₀ (base_nonneg k q hq h0 h1) ?_ n
  have hrk : 0 ≤ ((q : ℝ) - 1) * r ^ k := by
    have : (1 : ℝ) ≤ q := by exact_mod_cast hq
    exact mul_nonneg (by linarith) (pow_nonneg h0 k)
  simp only [base]
  linarith

end DatabaseSheafProb