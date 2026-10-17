import Mathlib

/-!
# The Umans–Wang `(α,β)`-divisor conjecture: the corrected counting wall `α ≥ 1 − 2β`

Companion to `Catalog/Cryptography/FactoringBarriers/UMWCountingWall.lean` (namespace
`UMWTest`), which proved the *prime* version `primorial n ≤ M^m` for a list of differences.
Here we work directly with the two sets `S, T` of Conjecture 3.2 of Umans–Wang
(arXiv:2511.10851) and prove:

* `UMWWall.lcm_dvd_diffProd` — if the differences of `S, T` have the `n`-divisor property,
  then `lcm(1,…,n)` divides the product of all positive differences (prime *powers*, not
  only primes, are forced — strictly sharper than the primorial wall).
* `UMWWall.centralBinom_dvd_lcm` — `C(2m,m) ∣ lcm(1,…,2m)` (each prime power in the
  central binomial coefficient is `≤ 2m`).
* `UMWWall.counting_wall` — the explicit finite wall
  `4^(n/2) ≤ (n+1) · M^(|S|·|T|)`.
* `UMWWall.alpha_ge_one_sub_two_beta` — **the corrected asymptotic constraint**: if for
  infinitely many `n` there are `S, T` with the `n`-divisor property, elements
  `≤ exp(n^α)` and `|S|,|T| ≤ n^β`, then `α ≥ 1 − 2β` (i.e. `α + 2β ≥ 1`, NOT `α + β ≤ 1`).
* `UMWWall.trivial_block_cover` — the trivial construction (`α = 1 − β + o(1)`):
  with `T = {1}` and `⌈n/b⌉` block products one covers `[n]` with elements `≤ 1 + n^b`.
* `UMWWall.zero_slack` — at `α = β = 1/3` the wall is met with equality.
* `UMWWall.lcm_wall` / `UMWWall.singleton_optimum` — the sharp form
  `lcm(1,…,n) ≤ M^(|S|·|T|)`, attained exactly (`M = lcm(1,…,n)+1`) when `|S| = |T| = 1`.
* `UMWWall.crt_progression` — the CRT core of Lemma 6.2: for pairwise coprime moduli
  `U₀,…,U_{ℓ-1}` and any step `c`, some progression `b + (i+1)c` has `U_i ∣ b + (i+1)c`.

Nothing here constructs a `(1/3,1/3)` cover; the conjecture remains open.
-/

namespace UMWWall

open Finset Real Filter

/-- The `n`-divisor property for the difference set `S − T`: every `1 ≤ i ≤ n` divides some
nonzero difference.  Since `i ∣ s − t ↔ i ∣ t − s`, we orient differences positively,
`t < s`, and work in `ℕ`. -/
def DivisorProperty (n : ℕ) (S T : Finset ℕ) : Prop :=
  ∀ i, 1 ≤ i → i ≤ n → ∃ s ∈ S, ∃ t ∈ T, t < s ∧ i ∣ s - t

/-- `lcm(1, …, n)`. -/
def lcmUpTo (n : ℕ) : ℕ := (Icc 1 n).lcm id

/-- Product of all positive differences `s − t`, `s ∈ S`, `t ∈ T`, `t < s`. -/
def diffProd (S T : Finset ℕ) : ℕ :=
  ∏ p ∈ (S ×ˢ T).filter (fun p => p.2 < p.1), (p.1 - p.2)

lemma diffProd_pos (S T : Finset ℕ) : 0 < diffProd S T := by
  unfold diffProd
  refine Finset.prod_pos ?_
  intro p hp
  have := (Finset.mem_filter.mp hp).2
  omega

/-- Every forced divisor divides the product of differences, hence so does their lcm. -/
theorem lcm_dvd_diffProd {n : ℕ} {S T : Finset ℕ} (h : DivisorProperty n S T) :
    lcmUpTo n ∣ diffProd S T := by
  unfold lcmUpTo
  refine Finset.lcm_dvd ?_
  intro i hi
  obtain ⟨hi1, hin⟩ := Finset.mem_Icc.mp hi
  obtain ⟨s, hs, t, ht, hts, hdvd⟩ := h i hi1 hin
  have hmem : (s, t) ∈ (S ×ˢ T).filter (fun p => p.2 < p.1) :=
    Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨hs, ht⟩, hts⟩
  exact hdvd.trans (Finset.dvd_prod_of_mem (fun p : ℕ × ℕ => p.1 - p.2) hmem)

/-- If all elements of `S` are `≤ M`, the product of differences is `≤ M^(|S|·|T|)`. -/
theorem diffProd_le {S T : Finset ℕ} {M : ℕ} (hM : 1 ≤ M) (hS : ∀ s ∈ S, s ≤ M) :
    diffProd S T ≤ M ^ (S.card * T.card) := by
  unfold diffProd
  calc ∏ p ∈ (S ×ˢ T).filter (fun p => p.2 < p.1), (p.1 - p.2)
      ≤ M ^ ((S ×ˢ T).filter (fun p => p.2 < p.1)).card := by
        refine Finset.prod_le_pow_card _ _ _ ?_
        intro p hp
        have := hS p.1 (Finset.mem_product.mp (Finset.mem_filter.mp hp).1).1
        omega
    _ ≤ M ^ (S ×ˢ T).card := Nat.pow_le_pow_right hM (Finset.card_filter_le _ _)
    _ = M ^ (S.card * T.card) := by rw [Finset.card_product]

lemma lcmUpTo_ne_zero (n : ℕ) : lcmUpTo n ≠ 0 := by
  unfold lcmUpTo
  intro h
  rw [Finset.lcm_eq_zero_iff] at h
  obtain ⟨i, hi, h0⟩ := h
  simp only [id] at h0
  have := (Finset.mem_Icc.mp hi).1
  omega

lemma lcmUpTo_mono {m n : ℕ} (h : m ≤ n) : lcmUpTo m ∣ lcmUpTo n := by
  unfold lcmUpTo
  refine Finset.lcm_dvd ?_
  intro i hi
  obtain ⟨h1, h2⟩ := Finset.mem_Icc.mp hi
  exact Finset.dvd_lcm (Finset.mem_Icc.mpr ⟨h1, h2.trans h⟩)

/-- Every prime power in `C(2m, m)` is `≤ 2m`, hence `C(2m,m) ∣ lcm(1,…,2m)`. -/
theorem centralBinom_dvd_lcm (m : ℕ) : (2 * m).choose m ∣ lcmUpTo (2 * m) := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simp
  have hpos : 0 < 2 * m := by omega
  have hc0 : (2 * m).choose m ≠ 0 := (Nat.choose_pos (by omega)).ne'
  rw [← Nat.factorization_le_iff_dvd hc0 (lcmUpTo_ne_zero _)]
  intro p
  by_cases hp : p.Prime
  · have hle : p ^ ((2 * m).choose m).factorization p ≤ 2 * m :=
      Nat.pow_factorization_choose_le hpos
    have hdvd : p ^ ((2 * m).choose m).factorization p ∣ lcmUpTo (2 * m) := by
      unfold lcmUpTo
      exact Finset.dvd_lcm (f := id)
        (Finset.mem_Icc.mpr ⟨Nat.one_le_pow _ _ hp.pos, hle⟩)
    exact (hp.pow_dvd_iff_le_factorization (lcmUpTo_ne_zero _)).mp hdvd
  · simp [Nat.factorization_eq_zero_of_not_prime _ hp]

/-- **The explicit finite counting wall.**  If the differences of `S, T` divide-cover `[n]`
and every element of `S` is at most `M` (`M ≥ 1`), then `4^(n/2) ≤ (n+1) · M^(|S|·|T|)`. -/
theorem counting_wall {n M : ℕ} {S T : Finset ℕ} (h : DivisorProperty n S T)
    (hM : 1 ≤ M) (hS : ∀ s ∈ S, s ≤ M) : 4 ^ (n / 2) ≤ (n + 1) * M ^ (S.card * T.card) := by
  have h1 := Nat.four_pow_le_two_mul_add_one_mul_central_binom (n / 2)
  have h2 : (2 * (n / 2)).choose (n / 2) ≤ diffProd S T := by
    refine Nat.le_of_dvd (diffProd_pos S T) ?_
    exact (centralBinom_dvd_lcm (n / 2)).trans
      ((lcmUpTo_mono (by omega)).trans (lcm_dvd_diffProd h))
  have h3 := diffProd_le (T := T) hM hS
  calc 4 ^ (n / 2) ≤ (2 * (n / 2) + 1) * (2 * (n / 2)).choose (n / 2) := h1
    _ ≤ (n + 1) * M ^ (S.card * T.card) :=
        Nat.mul_le_mul (by omega) (h2.trans h3)

open Asymptotics in
/-- Analytic core: for `γ < 1`, eventually `log(x+1) + x^γ + log 2 < x log 2`. -/
lemma eventually_linear_beats (γ : ℝ) (hγ : γ < 1) :
    ∀ᶠ x : ℝ in atTop, Real.log (x + 1) + x ^ γ + Real.log 2 < x * Real.log 2 := by
  have h1 : (fun x : ℝ => x ^ γ) =o[atTop] (fun x => x) := by
    rw [isLittleO_iff]
    intro c hc
    have ht := tendsto_rpow_neg_atTop (y := 1 - γ) (by linarith)
    filter_upwards [ht.eventually (gt_mem_nhds hc), eventually_gt_atTop 0] with x hx hx0
    rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_pos hx0,
      abs_of_pos (Real.rpow_pos_of_pos hx0 _)]
    have : x ^ γ = x ^ (-(1 - γ)) * x := by
      rw [← Real.rpow_add_one hx0.ne']; congr 1; ring
    rw [this]
    exact mul_le_mul_of_nonneg_right hx.le hx0.le
  have h2 : (fun x : ℝ => Real.log (x + 1)) =o[atTop] (fun x => x) := by
    have := Real.isLittleO_log_id_atTop.comp_tendsto
      (tendsto_atTop_add_const_right atTop 1 tendsto_id)
    refine this.trans_isBigO ?_
    refine IsBigO.of_bound 2 ?_
    filter_upwards [eventually_ge_atTop 1] with x hx
    simp only [Function.comp, id, Real.norm_eq_abs]
    rw [abs_of_pos (by linarith), abs_of_pos (by linarith)]; linarith
  have h3 : (fun _ : ℝ => Real.log 2) =o[atTop] (fun x => x) := isLittleO_const_id_atTop _
  have h := (h2.add h1).add h3
  have hl : 0 < Real.log 2 / 2 := by positivity
  filter_upwards [h.bound hl, eventually_gt_atTop 0] with x hx hx0
  rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_pos hx0] at hx
  have := le_abs_self (Real.log (x + 1) + x ^ γ + Real.log 2)
  have hlog : 0 < Real.log 2 := by positivity
  nlinarith

/-- **Logarithmic form of the wall.**  If `S, T` divide-cover `[n]` (`n ≥ 1`), every element
of `S` is `≤ exp(n^α)` and `|S|, |T| ≤ n^β`, then `(n - 1) log 2 ≤ log(n+1) + n^(α+2β)`. -/
theorem log_wall {n : ℕ} (hn : 1 ≤ n) {α β : ℝ} {S T : Finset ℕ}
    (h : DivisorProperty n S T) (hS : ∀ s ∈ S, (s : ℝ) ≤ Real.exp ((n : ℝ) ^ α))
    (hSc : (S.card : ℝ) ≤ (n : ℝ) ^ β) (hTc : (T.card : ℝ) ≤ (n : ℝ) ^ β) :
    ((n : ℝ) - 1) * Real.log 2 ≤ Real.log (n + 1) + (n : ℝ) ^ (α + 2 * β) := by
  set X := Real.exp ((n : ℝ) ^ α) with hX
  have hX1 : 1 ≤ X := Real.one_le_exp (Real.rpow_nonneg (Nat.cast_nonneg n) α)
  set M := ⌊X⌋₊ with hMdef
  have hM1 : 1 ≤ M := Nat.le_floor (by simpa using hX1)
  have hSM : ∀ s ∈ S, s ≤ M := fun s hs => Nat.le_floor (hS s hs)
  have hwall := counting_wall h hM1 hSM
  have hMX : (M : ℝ) ≤ X := Nat.floor_le (by linarith)
  set k := S.card * T.card with hk
  have hreal : (4 : ℝ) ^ (n / 2) ≤ ((n : ℝ) + 1) * X ^ k := by
    have := (Nat.cast_le (α := ℝ)).mpr hwall
    push_cast at this
    calc (4 : ℝ) ^ (n / 2) ≤ ((n : ℝ) + 1) * (M : ℝ) ^ k := this
      _ ≤ ((n : ℝ) + 1) * X ^ k := by
        gcongr
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hlog := Real.log_le_log (by positivity) hreal
  rw [Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow, hX,
    Real.log_exp] at hlog
  have h4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; norm_num
  have hhalf : ((n : ℝ) - 1) ≤ 2 * ((n / 2 : ℕ) : ℝ) := by
    have : n ≤ 2 * (n / 2) + 1 := by omega
    have : (n : ℝ) ≤ 2 * ((n / 2 : ℕ) : ℝ) + 1 := by exact_mod_cast this
    linarith
  have hkle : (k : ℝ) ≤ (n : ℝ) ^ (2 * β) := by
    rw [hk, Nat.cast_mul, two_mul, Real.rpow_add hnpos]
    exact mul_le_mul hSc hTc (Nat.cast_nonneg _) (Real.rpow_nonneg hnpos.le _)
  have hpow : (k : ℝ) * (n : ℝ) ^ α ≤ (n : ℝ) ^ (α + 2 * β) := by
    rw [Real.rpow_add hnpos, mul_comm ((n : ℝ) ^ α)]
    exact mul_le_mul_of_nonneg_right hkle (Real.rpow_nonneg hnpos.le _)
  have hl2 : 0 < Real.log 2 := by positivity
  nlinarith

/-- **The corrected Umans–Wang counting constraint `α ≥ 1 − 2β`.**
If for infinitely many `n` there are `S, T ⊆ ℕ` whose differences have the `n`-divisor
property, with all elements of `S` at most `exp(n^α)` and `|S|, |T| ≤ n^β`, then
`1 − 2β ≤ α`.  (The boundary is `α + 2β = 1`; it is *not* `α + β ≤ 1`.) -/
theorem alpha_ge_one_sub_two_beta {α β : ℝ}
    (hinf : ∃ᶠ n : ℕ in atTop, ∃ S T : Finset ℕ, DivisorProperty n S T ∧
      (∀ s ∈ S, (s : ℝ) ≤ Real.exp ((n : ℝ) ^ α)) ∧
      (S.card : ℝ) ≤ (n : ℝ) ^ β ∧ (T.card : ℝ) ≤ (n : ℝ) ^ β) :
    1 - 2 * β ≤ α := by
  by_contra hlt
  push_neg at hlt
  have hγ : α + 2 * β < 1 := by linarith
  have hev := (tendsto_natCast_atTop_atTop (R := ℝ)).eventually
    (eventually_linear_beats (α + 2 * β) hγ)
  obtain ⟨n, ⟨S, T, h, hS, hSc, hTc⟩, hlt', hn⟩ :=
    (hinf.and_eventually (hev.and (eventually_ge_atTop 1))).exists
  have := log_wall hn h hS hSc hTc
  linarith

/-- **Zero slack at the target.**  At `α = β = 1/3` the counting wall `α ≥ 1 − 2β` holds with
equality, while the trivial construction needs `α = 1 − β = 2/3`: the target sits exactly on
the wall, and any `α < 1/3` with `β = 1/3` is impossible. -/
theorem zero_slack :
    (1 : ℝ) - 2 * (1 / 3) = 1 / 3 ∧ (1 : ℝ) - 1 / 3 = 2 / 3 ∧
    ∀ α : ℝ, α < 1 / 3 → ¬ ∃ᶠ n : ℕ in atTop, ∃ S T : Finset ℕ, DivisorProperty n S T ∧
      (∀ s ∈ S, (s : ℝ) ≤ Real.exp ((n : ℝ) ^ α)) ∧
      (S.card : ℝ) ≤ (n : ℝ) ^ (1 / 3 : ℝ) ∧ (T.card : ℝ) ≤ (n : ℝ) ^ (1 / 3 : ℝ) := by
  refine ⟨by norm_num, by norm_num, fun α hα hinf => ?_⟩
  have := alpha_ge_one_sub_two_beta hinf
  linarith

/-! ## The trivial construction `α = 1 − β + o(1)` -/

/-- The block of indices `i ∈ [1,n]` with `(i-1)/b = j`. -/
def block (n b j : ℕ) : Finset ℕ := (Icc 1 n).filter (fun i => (i - 1) / b = j)

lemma block_card_le (n b j : ℕ) (hb : 1 ≤ b) : (block n b j).card ≤ b := by
  have hsub : block n b j ⊆ Icc (j * b + 1) (j * b + b) := by
    intro i hi
    obtain ⟨hi1, hij⟩ := Finset.mem_filter.mp hi
    obtain ⟨h1, _⟩ := Finset.mem_Icc.mp hi1
    have hlo : j * b ≤ i - 1 := by rw [← hij]; exact Nat.div_mul_le_self _ _
    have hhi : i - 1 < (j + 1) * b := by
      rw [← hij, mul_comm]; exact Nat.lt_mul_div_succ (i - 1) (by omega)
    have hjb : (j + 1) * b = j * b + b := by ring
    rw [Finset.mem_Icc]
    constructor
    · omega
    · omega
  calc (block n b j).card ≤ (Icc (j * b + 1) (j * b + b)).card := Finset.card_le_card hsub
    _ = b := by simp

lemma block_prod_le (n b j : ℕ) (hb : 1 ≤ b) (hn : 1 ≤ n) :
    ∏ i ∈ block n b j, i ≤ n ^ b := by
  calc ∏ i ∈ block n b j, i ≤ n ^ (block n b j).card := by
        refine Finset.prod_le_pow_card _ _ _ ?_
        intro i hi
        exact (Finset.mem_Icc.mp (Finset.mem_filter.mp hi).1).2
    _ ≤ n ^ b := Nat.pow_le_pow_right hn (block_card_le n b j hb)

/-- **The trivial cover.**  Cutting `[1,n]` into `⌈n/b⌉` blocks of length `b`, the sets
`S = {1 + ∏ block_j}` and `T = {1}` have the `n`-divisor property, with
`|S| ≤ ⌈n/b⌉`, `|T| = 1` and all elements `≤ 1 + n^b`.  Taking `b ≈ n^{1-β}` gives
`|S| ≈ n^β` and `log s ≲ n^{1-β} log n`, i.e. `α = 1 − β + o(1)`. -/
theorem trivial_block_cover (n b : ℕ) (hb : 1 ≤ b) (hn : 1 ≤ n) :
    ∃ S T : Finset ℕ, DivisorProperty n S T ∧ S.card ≤ (n + b - 1) / b ∧ T.card = 1 ∧
      (∀ s ∈ S, 1 ≤ s ∧ s ≤ 1 + n ^ b) ∧ (∀ t ∈ T, 1 ≤ t) := by
  refine ⟨(range ((n + b - 1) / b)).image (fun j => 1 + ∏ i ∈ block n b j, i), {1},
    ?_, ?_, by simp, ?_, by simp⟩
  · intro i hi1 hin
    refine ⟨1 + ∏ k ∈ block n b ((i - 1) / b), k, ?_, 1, by simp, ?_, ?_⟩
    · refine Finset.mem_image.mpr ⟨(i - 1) / b, Finset.mem_range.mpr ?_, rfl⟩
      have h1 : (i - 1) / b ≤ (n - 1) / b := Nat.div_le_div_right (by omega)
      have h2 : (n + b - 1) / b = (n - 1) / b + 1 := by
        rw [show n + b - 1 = (n - 1) + b by omega, Nat.add_div_right _ (by omega)]
      omega
    · have : 0 < ∏ k ∈ block n b ((i - 1) / b), k := by
        refine Finset.prod_pos ?_
        intro k hk
        exact (Finset.mem_Icc.mp (Finset.mem_filter.mp hk).1).1
      omega
    · rw [show 1 + ∏ k ∈ block n b ((i - 1) / b), k - 1 = ∏ k ∈ block n b ((i - 1) / b), k
        by omega]
      exact Finset.dvd_prod_of_mem _
        (Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨hi1, hin⟩, rfl⟩)
  · exact (Finset.card_image_le).trans (by simp)
  · intro s hs
    obtain ⟨j, _, rfl⟩ := Finset.mem_image.mp hs
    exact ⟨by omega, by have := block_prod_le n b j hb hn; omega⟩

/-! ## Lemma 6.2: the CRT core of the arithmetic-progression block -/

/-- **CRT progression (core of Umans–Wang Lemma 6.2).**  For pairwise coprime nonzero moduli
`U₀, …, U_{ℓ-1}` and any step `c`, there is a start `b` with `U_i ∣ b + (i+1)·c` for all
`i < ℓ`. -/
theorem crt_progression (ℓ : ℕ) (U : ℕ → ℕ) (hU : ∀ i ∈ range ℓ, U i ≠ 0)
    (hcop : (↑(range ℓ) : Set ℕ).Pairwise (Function.onFun Nat.Coprime U)) (c : ℕ) :
    ∃ b : ℕ, ∀ i < ℓ, U i ∣ b + (i + 1) * c := by
  obtain ⟨k, hk⟩ := Nat.chineseRemainderOfFinset
    (fun i => U i - (i + 1) * c % U i) U (range ℓ) hU hcop
  refine ⟨k, fun i hi => ?_⟩
  have hmem : i ∈ range ℓ := Finset.mem_range.mpr hi
  have hUi : 0 < U i := Nat.pos_of_ne_zero (hU i hmem)
  have hr : (i + 1) * c % U i < U i := Nat.mod_lt _ hUi
  have h1 : k + (i + 1) * c ≡ (U i - (i + 1) * c % U i) + (i + 1) * c % U i [MOD U i] :=
    Nat.ModEq.add (hk i hmem) (Nat.mod_modEq _ _).symm
  rw [Nat.sub_add_cancel hr.le] at h1
  exact (Nat.modEq_zero_iff_dvd).mp (h1.trans (Nat.modEq_zero_iff_dvd.mpr dvd_rfl))

/-- **Lemma 6.2, prime-hitting form.**  If every prime `≤ n` divides one of the pairwise
coprime blocks `U₀,…,U_{ℓ-1}` of a factorization, then for every step `c` some `ℓ`-term
progression `b + c, b + 2c, …, b + ℓc` contains a multiple of every prime `≤ n`.
Note this holds already for `ℓ = 1` (take `U₀` = the primorial): hitting the primes is
cheap; the entire content of Umans–Wang's use of Lemma 6.2 is the *size* of `b, c`, which
this existence statement does not control (cf. Lemma 6.3). -/
theorem progression_hits_primes (n ℓ : ℕ) (U : ℕ → ℕ) (hU : ∀ i ∈ range ℓ, U i ≠ 0)
    (hcop : (↑(range ℓ) : Set ℕ).Pairwise (Function.onFun Nat.Coprime U))
    (hcover : ∀ p, p.Prime → p ≤ n → ∃ i < ℓ, p ∣ U i) (c : ℕ) :
    ∃ b : ℕ, ∀ p, p.Prime → p ≤ n → ∃ i < ℓ, p ∣ b + (i + 1) * c := by
  obtain ⟨b, hb⟩ := crt_progression ℓ U hU hcop c
  exact ⟨b, fun p hp hpn => by
    obtain ⟨i, hi, hpi⟩ := hcover p hp hpn
    exact ⟨i, hi, hpi.trans (hb i hi)⟩⟩

/-! ## Sharp `lcm` form of the wall, and exact tightness at `|S| = |T| = 1` -/

/-- **`lcm` wall.**  `lcm(1,…,n) ≤ M^(|S|·|T|)` for any divide-cover with elements `≤ M`. -/
theorem lcm_wall {n M : ℕ} {S T : Finset ℕ} (h : DivisorProperty n S T) (hM : 1 ≤ M)
    (hS : ∀ s ∈ S, s ≤ M) : lcmUpTo n ≤ M ^ (S.card * T.card) :=
  (Nat.le_of_dvd (diffProd_pos S T) (lcm_dvd_diffProd h)).trans (diffProd_le hM hS)

/-- A single difference covers `[n]` iff it is a positive multiple of `lcm(1,…,n)`. -/
theorem singleton_cover_iff (n s t : ℕ) :
    DivisorProperty n {s} {t} ↔ (1 ≤ n → t < s) ∧ lcmUpTo n ∣ s - t := by
  constructor
  · intro h
    refine ⟨fun hn => ?_, ?_⟩
    · obtain ⟨s', hs', t', ht', hlt, _⟩ := h 1 le_rfl hn
      simp only [Finset.mem_singleton] at hs' ht'
      subst hs' ht'; exact hlt
    · unfold lcmUpTo
      refine Finset.lcm_dvd ?_
      intro i hi
      obtain ⟨h1, h2⟩ := Finset.mem_Icc.mp hi
      obtain ⟨s', hs', t', ht', _, hd⟩ := h i h1 h2
      simp only [Finset.mem_singleton] at hs' ht'
      subst hs' ht'; exact hd
  · rintro ⟨hlt, hd⟩ i h1 h2
    refine ⟨s, by simp, t, by simp, hlt (h1.trans h2), ?_⟩
    exact (Finset.dvd_lcm (f := id) (Finset.mem_Icc.mpr ⟨h1, h2⟩)).trans hd

/-- **Exact optimum for `|S| = |T| = 1`.**  The least possible largest element of a
one-against-one divide-cover of `[n]` (`n ≥ 1`, positive integers) is exactly
`lcm(1,…,n) + 1`: the `lcm` wall is attained with equality (up to the `+1`). -/
theorem singleton_optimum (n : ℕ) (hn : 1 ≤ n) :
    DivisorProperty n {lcmUpTo n + 1} {1} ∧
    ∀ s t : ℕ, 1 ≤ t → DivisorProperty n {s} {t} → lcmUpTo n + 1 ≤ s := by
  refine ⟨(singleton_cover_iff n _ 1).mpr ⟨fun _ => ?_, by simp⟩, fun s t ht h => ?_⟩
  · have := Nat.pos_of_ne_zero (lcmUpTo_ne_zero n); omega
  · obtain ⟨hlt, hd⟩ := (singleton_cover_iff n s t).mp h
    have hlt := hlt hn
    have := Nat.le_of_dvd (by omega) hd
    omega

end UMWWall