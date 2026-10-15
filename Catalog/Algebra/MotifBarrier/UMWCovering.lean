import Mathlib

/-!
# The Umans–Wang divisibility covering and its counting wall `α + 2β ≥ 1`

A *divisibility covering* of the index set `[n] = {1,…,n}` is a pair of finite
sets `S, T ⊆ ℤ` such that every `i ∈ [n]` divides some difference `s − t`
(`IsDivCovering`).  This is the object behind the Umans–Wang route
(arXiv:2511.10851), which replaces a baby-step/giant-step search by a covering.

## Results (all unconditional, 0 sorries)

* `counting_wall` — **exact finite wall.**  If `S ∩ T = ∅`, entries lie in `[0, M]`
  and `(S,T)` covers `[2n]`, then `4^n ≤ (2n+1)·M^{|S|·|T|}`.  Proof: every
  `i ≤ 2n` divides `X = |∏(s−t)| ≠ 0`, hence (Legendre/Kummer: `p^{v_p(C(2n,n))} ≤ 2n`)
  the central binomial coefficient divides `X` (`choose_dvd_of_forall_dvd`), and
  `C(2n,n) ≥ 4^n/(2n+1)`.
* `asymptotic_wall_asymm` / `asymptotic_wall` — **the exponent wall**
  `α + β₁ + β₂ ≥ 1`, in particular `α + 2β ≥ 1`; zero slack at `α = β = 1/3`.
* `single_anchor_wall` — single-anchor (star) coverings obey `α + β ≥ 1`.
* `disjoint_guard_needed` — without `S ∩ T = ∅` the wall is false.
* `lcm_covering`, `single_pair_optimal`, `four_pow_le_lcm` — the `(α,β) = (1,0)` end
  is realised by `{lcm(1..n)}, {0}`, optimally among single pairs, and the wall
  specialises to the classical bound `4^n ≤ (2n+1)·lcm(1..2n)`.
* `bsgs_covering` (+ `bsgsS_card`, `bsgsT_card`, `bsgs_disjoint`, `bsgs_bounds`) —
  the `(α,β) = (0,1/2)` end is realised by the **baby-step/giant-step sets
  themselves**: `S = {k² + kj}`, `T = {r}`, `j,r < k`, cover `[k²]` with entries `≤ 2k²`.

Both ends of the wall are therefore constructed; the interior zero-slack point
`(1/3, 1/3)` is **not** constructed here.
-/

namespace Catalog.Algebra.MotifBarrier.UMW

/-- `S, T` form a divisibility covering of `[n]`. -/
def IsDivCovering (n : ℕ) (S T : Finset ℤ) : Prop :=
  ∀ i : ℕ, 1 ≤ i → i ≤ n → ∃ s ∈ S, ∃ t ∈ T, (i : ℤ) ∣ s - t

/-- The product of all differences `s − t`. -/
def diffProd (S T : Finset ℤ) : ℤ := ∏ s ∈ S, ∏ t ∈ T, (s - t)

theorem IsDivCovering.mono {n n' : ℕ} {S T : Finset ℤ} (h : n' ≤ n)
    (hc : IsDivCovering n S T) : IsDivCovering n' S T :=
  fun i h1 h2 => hc i h1 (h2.trans h)

theorem IsDivCovering.translate {n : ℕ} {S T : Finset ℤ} (c : ℤ)
    (hc : IsDivCovering n S T) :
    IsDivCovering n (S.image (· + c)) (T.image (· + c)) := by
  intro i h1 h2
  obtain ⟨s, hs, t, ht, hd⟩ := hc i h1 h2
  refine ⟨s + c, Finset.mem_image_of_mem _ hs, t + c, Finset.mem_image_of_mem _ ht, ?_⟩
  simpa using hd

theorem IsDivCovering.dvd_diffProd {n : ℕ} {S T : Finset ℤ} (hc : IsDivCovering n S T)
    {i : ℕ} (h1 : 1 ≤ i) (h2 : i ≤ n) : (i : ℤ) ∣ diffProd S T := by
  obtain ⟨s, hs, t, ht, hd⟩ := hc i h1 h2
  exact hd.trans ((Finset.dvd_prod_of_mem (fun t => s - t) ht).trans
    (Finset.dvd_prod_of_mem (fun s => ∏ t ∈ T, (s - t)) hs))

theorem diffProd_ne_zero {S T : Finset ℤ} (hdisj : Disjoint S T) : diffProd S T ≠ 0 := by
  unfold diffProd
  rw [Finset.prod_ne_zero_iff]
  intro s hs
  rw [Finset.prod_ne_zero_iff]
  intro t ht
  exact sub_ne_zero.mpr (fun h => Finset.disjoint_left.mp hdisj hs (h ▸ ht))

theorem natAbs_diffProd_le {S T : Finset ℤ} (M : ℕ)
    (hS : ∀ s ∈ S, 0 ≤ s ∧ s ≤ M) (hT : ∀ t ∈ T, 0 ≤ t ∧ t ≤ M) :
    (diffProd S T).natAbs ≤ M ^ (S.card * T.card) := by
  unfold diffProd
  rw [show (∏ s ∈ S, ∏ t ∈ T, (s - t)).natAbs = ∏ s ∈ S, (∏ t ∈ T, (s - t)).natAbs from
    map_prod Int.natAbsHom _ _, mul_comm, pow_mul]
  apply Finset.prod_le_pow_card
  intro s hs
  rw [show (∏ t ∈ T, (s - t)).natAbs = ∏ t ∈ T, (s - t).natAbs from
    map_prod Int.natAbsHom _ _]
  apply Finset.prod_le_pow_card
  intro t ht
  have := hS s hs
  have := hT t ht
  omega

/-- If every `i ∈ [m]` divides `X ≠ 0`, then so does every binomial `m.choose k`. -/
theorem choose_dvd_of_forall_dvd {m k X : ℕ} (hk : k ≤ m) (hX : X ≠ 0)
    (h : ∀ i, 1 ≤ i → i ≤ m → i ∣ X) : m.choose k ∣ X := by
  have hC : m.choose k ≠ 0 := (Nat.choose_pos hk).ne'
  rw [← Nat.factorization_le_iff_dvd hC hX]
  intro p
  by_cases hp : p.Prime
  · have he : (m.choose k).factorization p ≤ Nat.log p m := Nat.factorization_choose_le_log
    by_cases hm : m = 0
    · subst hm
      simp at he
      simp [he]
    have hle : p ^ (m.choose k).factorization p ≤ m :=
      (Nat.pow_le_pow_right hp.pos he).trans (Nat.pow_log_le_self p hm)
    exact (hp.pow_dvd_iff_le_factorization hX).mp
      (h _ (Nat.one_le_pow _ _ hp.pos) hle)
  · simp [Nat.factorization_eq_zero_of_not_prime _ hp]

/-- **The UMW counting wall (exact, finite form).** -/
theorem counting_wall {n M : ℕ} {S T : Finset ℤ} (hc : IsDivCovering (2 * n) S T)
    (hdisj : Disjoint S T)
    (hS : ∀ s ∈ S, 0 ≤ s ∧ s ≤ M) (hT : ∀ t ∈ T, 0 ≤ t ∧ t ≤ M) :
    4 ^ n ≤ (2 * n + 1) * M ^ (S.card * T.card) := by
  set X := (diffProd S T).natAbs with hXdef
  have hX : X ≠ 0 := Int.natAbs_ne_zero.mpr (diffProd_ne_zero hdisj)
  have hdvd : ∀ i, 1 ≤ i → i ≤ 2 * n → i ∣ X := fun i h1 h2 =>
    Int.natCast_dvd.mp (hc.dvd_diffProd h1 h2)
  have hC : n.centralBinom ∣ X := by
    rw [Nat.centralBinom_eq_two_mul_choose]
    exact choose_dvd_of_forall_dvd (by omega) hX hdvd
  have h1 : n.centralBinom ≤ X := Nat.le_of_dvd (Nat.pos_of_ne_zero hX) hC
  have h2 : X ≤ M ^ (S.card * T.card) := natAbs_diffProd_le M hS hT
  calc 4 ^ n ≤ (2 * n + 1) * n.centralBinom := Nat.four_pow_le_two_mul_add_one_mul_central_binom n
    _ ≤ (2 * n + 1) * M ^ (S.card * T.card) := Nat.mul_le_mul_left _ (h1.trans h2)


/-- **The counting wall in logarithmic form.** -/
theorem counting_wall_log {n M : ℕ} {S T : Finset ℤ} (hc : IsDivCovering (2 * n) S T)
    (hdisj : Disjoint S T) (hM : 1 ≤ M)
    (hS : ∀ s ∈ S, 0 ≤ s ∧ s ≤ M) (hT : ∀ t ∈ T, 0 ≤ t ∧ t ≤ M) :
    (n : ℝ) * Real.log 4 ≤
      Real.log (2 * n + 1) + ((S.card : ℝ) * T.card) * Real.log M := by
  have h := counting_wall hc hdisj hS hT
  have hR : ((4 : ℝ) ^ n) ≤ (2 * n + 1) * (M : ℝ) ^ (S.card * T.card) := by
    exact_mod_cast h
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hlog := Real.log_le_log (by positivity) hR
  rw [Real.log_pow, Real.log_mul (by positivity) (by positivity), Real.log_pow] at hlog
  push_cast at hlog
  linarith

/-- **The UMW counting wall, asymptotic asymmetric form: `α + β₁ + β₂ ≥ 1`.**

Suppose that for arbitrarily large `n` there is a disjoint divisibility covering
of `[2n]` with `|S| ≤ (2n)^β₁`, `|T| ≤ (2n)^β₂` and entries in `[0, M]`,
`log M ≤ (2n)^α`.  Then `α + β₁ + β₂ ≥ 1`. -/
theorem asymptotic_wall_asymm (α β₁ β₂ : ℝ)
    (h : ∀ N : ℕ, ∃ n ≥ N, ∃ (S T : Finset ℤ) (M : ℕ), IsDivCovering (2 * n) S T ∧
      Disjoint S T ∧ 1 ≤ M ∧ (∀ s ∈ S, 0 ≤ s ∧ s ≤ M) ∧ (∀ t ∈ T, 0 ≤ t ∧ t ≤ M) ∧
      (S.card : ℝ) ≤ (2 * n : ℝ) ^ β₁ ∧ (T.card : ℝ) ≤ (2 * n : ℝ) ^ β₂ ∧
      Real.log M ≤ (2 * n : ℝ) ^ α) :
    1 ≤ α + β₁ + β₂ := by
  by_contra hlt
  push_neg at hlt
  set γ := α + β₁ + β₂ with hγ
  set δ : ℝ := max γ (1 / 2) with hδ
  have hδ1 : δ < 1 := max_lt hlt (by norm_num)
  have hδ0 : 0 < δ := lt_of_lt_of_le (by norm_num) (le_max_right _ _)
  have hγδ : γ ≤ δ := le_max_left _ _
  -- the constant
  set C : ℝ := (2 ^ δ / δ + 1) / Real.log 2 with hC
  have hev : ∀ᶠ x : ℝ in Filter.atTop, C < x ^ (1 - δ) :=
    (tendsto_rpow_atTop (by linarith)).eventually_gt_atTop C
  obtain ⟨X, hX⟩ := Filter.eventually_atTop.mp hev
  obtain ⟨n, hn, S, T, M, hc, hdisj, hM, hS, hT, hSc, hTc, hlogM⟩ := h (⌈max X 1⌉₊ + 1)
  have hn1 : (1 : ℝ) ≤ n := by
    have : 1 ≤ n := by omega
    exact_mod_cast this
  have hxX : X ≤ (2 * n : ℝ) := by
    have h1 : (⌈max X 1⌉₊ : ℝ) ≤ n := by exact_mod_cast (by omega : ⌈max X 1⌉₊ ≤ n)
    have h2 := Nat.le_ceil (max X 1)
    have h3 := le_max_left X 1
    linarith
  set x : ℝ := 2 * n with hx
  have hx1 : 1 ≤ x := by linarith
  have hx0 : 0 < x := by linarith
  have hwall := counting_wall_log hc hdisj hM hS hT
  have hlogM0 : 0 ≤ Real.log M := Real.log_nonneg (by exact_mod_cast hM)
  -- the product term is at most x^γ ≤ x^δ
  have hprod : ((S.card : ℝ) * T.card) * Real.log M ≤ x ^ δ := by
    calc ((S.card : ℝ) * T.card) * Real.log M ≤ (x ^ β₁ * x ^ β₂) * x ^ α := by
          apply mul_le_mul (mul_le_mul hSc hTc (by positivity) (by positivity)) hlogM
            hlogM0 (by positivity)
      _ = x ^ γ := by
          rw [← Real.rpow_add hx0, ← Real.rpow_add hx0, hγ]; ring_nf
      _ ≤ x ^ δ := Real.rpow_le_rpow_of_exponent_le hx1 hγδ
  -- the log term is at most (2x)^δ/δ
  have hlog1 : Real.log (2 * n + 1) ≤ 2 ^ δ / δ * x ^ δ := by
    have := Real.log_le_rpow_div (x := 2 * n + 1) (by positivity) hδ0
    have h2 : (2 * n + 1 : ℝ) ^ δ ≤ (2 * x) ^ δ :=
      Real.rpow_le_rpow (by positivity) (by linarith) hδ0.le
    rw [Real.mul_rpow (by norm_num) hx0.le] at h2
    calc Real.log (2 * n + 1) ≤ (2 * n + 1 : ℝ) ^ δ / δ := this
      _ ≤ 2 ^ δ * x ^ δ / δ := by gcongr
      _ = 2 ^ δ / δ * x ^ δ := by ring
  have hlog4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; norm_num
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  -- x log 2 ≤ (2^δ/δ + 1) x^δ
  have hmain : x * Real.log 2 ≤ (2 ^ δ / δ + 1) * x ^ δ := by
    have : (n : ℝ) * Real.log 4 = x * Real.log 2 := by rw [hlog4, hx]; ring
    nlinarith
  -- but x^(1-δ) > C
  have hbig := hX x hxX
  have hsplit : x = x ^ (1 - δ) * x ^ δ := by
    rw [← Real.rpow_add hx0]; simp
  have hxδ : 0 < x ^ δ := by positivity
  have : C * Real.log 2 = 2 ^ δ / δ + 1 := by rw [hC]; field_simp
  have h5 : x * Real.log 2 > (2 ^ δ / δ + 1) * x ^ δ := by
    rw [hsplit, ← this]
    have := mul_lt_mul_of_pos_right hbig hxδ
    nlinarith
  linarith

/-- **The UMW counting wall, symmetric form: `α + 2β ≥ 1`.** -/
theorem asymptotic_wall (α β : ℝ)
    (h : ∀ N : ℕ, ∃ n ≥ N, ∃ (S T : Finset ℤ) (M : ℕ), IsDivCovering (2 * n) S T ∧
      Disjoint S T ∧ 1 ≤ M ∧ (∀ s ∈ S, 0 ≤ s ∧ s ≤ M) ∧ (∀ t ∈ T, 0 ≤ t ∧ t ≤ M) ∧
      (S.card : ℝ) ≤ (2 * n : ℝ) ^ β ∧ (T.card : ℝ) ≤ (2 * n : ℝ) ^ β ∧
      Real.log M ≤ (2 * n : ℝ) ^ α) :
    1 ≤ α + 2 * β := by
  have := asymptotic_wall_asymm α β β h
  linarith

/-- **Single-anchor (star) coverings obey the strictly worse wall `α + β ≥ 1`.**
If `T` is a single anchor (`|T| ≤ 1`) then the asymmetric wall with `β₂ = 0`
applies: at `β = 1/3` such a covering needs `α ≥ 2/3`, twice the zero-slack value. -/
theorem single_anchor_wall (α β : ℝ)
    (h : ∀ N : ℕ, ∃ n ≥ N, ∃ (S T : Finset ℤ) (M : ℕ), IsDivCovering (2 * n) S T ∧
      Disjoint S T ∧ 1 ≤ M ∧ (∀ s ∈ S, 0 ≤ s ∧ s ≤ M) ∧ (∀ t ∈ T, 0 ≤ t ∧ t ≤ M) ∧
      (S.card : ℝ) ≤ (2 * n : ℝ) ^ β ∧ T.card ≤ 1 ∧
      Real.log M ≤ (2 * n : ℝ) ^ α) :
    1 ≤ α + β := by
  have := asymptotic_wall_asymm α β 0 (fun N => by
    obtain ⟨n, hn, S, T, M, h1, h2, h3, h4, h5, h6, h7, h8⟩ := h N
    refine ⟨n, hn, S, T, M, h1, h2, h3, h4, h5, h6, ?_, h8⟩
    rw [Real.rpow_zero]; exact_mod_cast h7)
  linarith

/-- The guard `S ∩ T = ∅` is load-bearing: without it the singleton pair `{0},{0}`
covers every `[n]` (the difference `0` is divisible by everything). -/
theorem disjoint_guard_needed (n : ℕ) : IsDivCovering n {0} {0} := by
  intro i _ _
  exact ⟨0, Finset.mem_singleton_self _, 0, Finset.mem_singleton_self _, by simp⟩

/-- **Endpoint `(α, β) = (1, 0)`: the lcm covering.**  `S = {lcm(1..n)}, T = {0}`. -/
theorem lcm_covering (n : ℕ) :
    IsDivCovering n {(((Finset.Icc 1 n).lcm id : ℕ) : ℤ)} {0} := by
  intro i h1 h2
  refine ⟨_, Finset.mem_singleton_self _, 0, Finset.mem_singleton_self _, ?_⟩
  rw [sub_zero]
  exact Int.natCast_dvd_natCast.mpr
    (Finset.dvd_lcm (s := Finset.Icc 1 n) (f := id) (Finset.mem_Icc.mpr ⟨h1, h2⟩))

/-- **The lcm endpoint is exactly optimal among single-pair coverings.**  If one
difference `s − t ≠ 0` (entries in `[0, M]`) is divisible by every `i ∈ [n]`, then
`lcm(1,…,n) ≤ M`. -/
theorem single_pair_optimal {n M : ℕ} {s t : ℤ} (hst : s ≠ t)
    (hc : IsDivCovering n {s} {t}) (hs : 0 ≤ s ∧ s ≤ M) (ht : 0 ≤ t ∧ t ≤ M) :
    (Finset.Icc 1 n).lcm id ≤ M := by
  have hd : (Finset.Icc 1 n).lcm id ∣ (s - t).natAbs := by
    apply Finset.lcm_dvd
    intro i hi
    obtain ⟨h1, h2⟩ := Finset.mem_Icc.mp hi
    obtain ⟨s', hs', t', ht', hdv⟩ := hc i h1 h2
    rw [Finset.mem_singleton] at hs' ht'
    subst hs' ht'
    exact Int.natCast_dvd.mp hdv
  have hne : (s - t).natAbs ≠ 0 := Int.natAbs_ne_zero.mpr (sub_ne_zero.mpr hst)
  have := Nat.le_of_dvd (Nat.pos_of_ne_zero hne) hd
  omega

/-- **A corollary of the wall at the `(1,0)` endpoint:** the classical bound
`4^n ≤ (2n+1)·lcm(1,…,2n)`. -/
theorem four_pow_le_lcm (n : ℕ) :
    4 ^ n ≤ (2 * n + 1) * (Finset.Icc 1 (2 * n)).lcm id := by
  set L := (Finset.Icc 1 (2 * n)).lcm id with hL
  have hLpos : 0 < L := by
    apply Nat.pos_of_ne_zero
    rw [hL, Ne, Finset.lcm_eq_zero_iff]
    simp
  have := counting_wall (n := n) (M := L) (lcm_covering (2 * n))
    (by simp) (by simp [hL]) (by simp)
  simpa using this

/-- The baby-step/giant-step covering: giant steps `S = {k² + k j : j < k}`,
baby steps `T = {r : r < k}`. -/
def bsgsS (k : ℕ) : Finset ℤ := (Finset.range k).image (fun j : ℕ => ((k * k + k * j : ℕ) : ℤ))
/-- Baby steps. -/
def bsgsT (k : ℕ) : Finset ℤ := (Finset.range k).image (fun r : ℕ => (r : ℤ))

/-- **Endpoint `(α, β) = (0, 1/2)`: the baby-step/giant-step motif is itself a
divisibility covering of `[k²]`.** -/
theorem bsgs_covering (k : ℕ) : IsDivCovering (k * k) (bsgsS k) (bsgsT k) := by
  intro i h1 h2
  have hk : 1 ≤ k := by
    rcases Nat.eq_zero_or_pos k with h | h
    · subst h; omega
    · exact h
  set a := k * k - k + 1 with ha
  set q := (a + i - 1) / i with hq
  have hdm0 := Nat.div_add_mod (a + i - 1) i
  have hmod0 := Nat.mod_lt (a + i - 1) (show i > 0 by omega)
  rw [← hq] at hdm0
  have hq1 : q * i ≤ a + i - 1 := by rw [mul_comm]; omega
  have hq2 : a + i - 1 < q * i + i := by rw [mul_comm]; omega
  have hkk : k ≤ k * k := Nat.le_mul_of_pos_left k hk
  set d := q * i - a with hd
  have hda : q * i = a + d := by omega
  have hdlt : d < k * k := by omega
  have hdk : d / k < k := (Nat.div_lt_iff_lt_mul (by omega)).mpr hdlt
  have hmod : d % k < k := Nat.mod_lt _ (by omega)
  have hdm : k * (d / k) + d % k = d := Nat.div_add_mod d k
  refine ⟨((k * k + k * (d / k) : ℕ) : ℤ), Finset.mem_image_of_mem _ (Finset.mem_range.mpr hdk),
    ((k - 1 - d % k : ℕ) : ℤ), Finset.mem_image_of_mem _ (Finset.mem_range.mpr (by omega)),
    ⟨q, ?_⟩⟩
  have e : k * k + k * (d / k) = (k - 1 - d % k) + q * i := by omega
  have e' : ((k * k + k * (d / k) : ℕ) : ℤ) = ((k - 1 - d % k : ℕ) : ℤ) + (q : ℤ) * i := by
    exact_mod_cast e
  rw [e']; ring

theorem bsgsS_card (k : ℕ) : (bsgsS k).card = k := by
  rcases Nat.eq_zero_or_pos k with h | h
  · subst h; simp [bsgsS]
  rw [bsgsS, Finset.card_image_of_injective _ (fun x y hxy => by
    simp only [Nat.cast_inj] at hxy
    exact Nat.eq_of_mul_eq_mul_left h (by omega)), Finset.card_range]

theorem bsgsT_card (k : ℕ) : (bsgsT k).card = k := by
  rw [bsgsT, Finset.card_image_of_injective _ Nat.cast_injective, Finset.card_range]

theorem bsgs_disjoint (k : ℕ) : Disjoint (bsgsS k) (bsgsT k) := by
  rw [Finset.disjoint_left]
  intro x hx hx'
  simp only [bsgsS, bsgsT, Finset.mem_image, Finset.mem_range] at hx hx'
  obtain ⟨j, hj, rfl⟩ := hx
  obtain ⟨r, hr, hr'⟩ := hx'
  have : r = k * k + k * j := by exact_mod_cast hr'
  have : k ≤ k * k := Nat.le_mul_of_pos_left k (by omega)
  omega

theorem bsgs_bounds (k : ℕ) :
    (∀ s ∈ bsgsS k, 0 ≤ s ∧ s ≤ ((2 * k * k : ℕ) : ℤ)) ∧
    (∀ t ∈ bsgsT k, 0 ≤ t ∧ t ≤ ((2 * k * k : ℕ) : ℤ)) := by
  constructor
  · intro s hs
    simp only [bsgsS, Finset.mem_image, Finset.mem_range] at hs
    obtain ⟨j, hj, rfl⟩ := hs
    refine ⟨by positivity, ?_⟩
    have : k * j ≤ k * k := Nat.mul_le_mul_left _ hj.le
    exact_mod_cast (by nlinarith : k * k + k * j ≤ 2 * k * k)
  · intro t ht
    simp only [bsgsT, Finset.mem_image, Finset.mem_range] at ht
    obtain ⟨r, hr, rfl⟩ := ht
    refine ⟨by positivity, ?_⟩
    exact_mod_cast (by nlinarith : r ≤ 2 * k * k)

/-- **The BSGS endpoint is consistent with (and sits on) the wall.**  Feeding the
baby-step/giant-step covering into the counting wall gives
`4^n ≤ (2n+1)(2k²)^{k²}` whenever `2n ≤ k²`. -/
theorem bsgs_on_wall {n k : ℕ} (h : 2 * n ≤ k * k) :
    4 ^ n ≤ (2 * n + 1) * (2 * k * k) ^ (k * k) := by
  have := counting_wall (M := 2 * k * k) ((bsgs_covering k).mono h) (bsgs_disjoint k)
    (bsgs_bounds k).1 (bsgs_bounds k).2
  rwa [bsgsS_card, bsgsT_card] at this

/-- **Zero slack at `α = β = 1/3`.** -/
theorem zero_slack_at_third : (1 / 3 : ℝ) + 2 * (1 / 3) = 1 := by norm_num

/-- Both explicit endpoints lie exactly on the wall line `α + 2β = 1`. -/
theorem endpoints_on_wall : (1 : ℝ) + 2 * 0 = 1 ∧ (0 : ℝ) + 2 * (1 / 2) = 1 := by
  constructor <;> norm_num

end Catalog.Algebra.MotifBarrier.UMW