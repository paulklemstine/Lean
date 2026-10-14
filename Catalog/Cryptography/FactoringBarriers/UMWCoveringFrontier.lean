import Mathlib

/-!
# The UMW covering frontier: a machine-checked sandwich around the open door

Companion to round 36 (the Umans–Wang `(α,β)` divisibility-covering, arXiv:2511.10851).
No covering at `(1/3,1/3)` is constructed or refuted here.  What is proved, with
**no `sorry` and no axiom**, is the exact region the round-36 discussion talks about:

* `DivCover n S T` — every `i ∈ [1,n]` divides some positive difference `s - t`
  (`t < s`, so the "disjoint guard" is built in: `s = t` never counts).
* **Counting wall** (`counting_wall`): `4^k ≤ 2k · M^(|S|·|T|)` for any cover of
  `[1,2k]` with elements `≤ M`.  Route: cover ⇒ `lcm(1..2k) ∣ ∏(s-t)`
  (`lcmUpTo_dvd_diffProd`), Kummer/Legendre ⇒ `C(2k,k) ∣ lcm(1..2k)`
  (`centralBinom_dvd_lcmUpTo`), and `4^k ≤ 2k·C(2k,k)`.
* **Exponent constraint** (`exponent_constraint`, `Feasible.constraint`):
  in the double-exponential unit `M ≤ exp(n^α)`, every feasible triple satisfies
  `α + βS + βT ≥ 1`; at `βS = βT = β` this is UMW's `α ≥ 1 - 2β`.
* **Trivial covering** (`trivial_feasible`): block products with `T = {0}` achieve
  every `α > 1 - β`.  Hence the **one-sided frontier is exactly `α = 1 - β`**
  (`one_sided_frontier`): with `|T| ≤ 1` no construction can beat the trivial one,
  so any `(1/3,1/3)` covering must be genuinely two-sided.
* **The sandwich** (`umw_sandwich`): at `β = 1/3`, feasible ⇒ `α ≥ 1/3`, and every
  `α > 2/3` is feasible.  The open content is exactly `α ∈ [1/3, 2/3]`.
* `empirical_point_dominated`: the round's empirical frontier `(1/2, 2/3)` is already
  inside the trivially-feasible region (even `(2/5, 2/3, 0)` is feasible).
* **α-unit trap** (`measuredAlpha_exp`, `measuredAlpha_le`, `single_log_unit_diverges`):
  `ln ln M / ln n` recovers `α` exactly, while `ln M / ln n` diverges.
* `large_prime_wall`: `y^{π(n)-π(y)} ≤ M^{|S||T|}` — the per-prime budget.
* `resultant_bridge`: for disjoint integer `S,T`, `lcm(1..n)` divides the nonzero
  resultant-type product `∏_{s∈S} P_T(s)` with `P_T = ∏_{t∈T}(X - t)`;
  `overlap_trivializes` shows the disjointness guard cannot be dropped.
-/

namespace Cryptography.FactoringBarriers.UMWFrontier

open Finset

/-- `S,T` form a divisibility covering of `[1,n]`. -/
def DivCover (n : ℕ) (S T : Finset ℕ) : Prop :=
  ∀ i, 1 ≤ i → i ≤ n → ∃ s ∈ S, ∃ t ∈ T, t < s ∧ i ∣ s - t

/-- The ordered positive differences. -/
def posPairs (S T : Finset ℕ) : Finset (ℕ × ℕ) := (S ×ˢ T).filter (fun p => p.2 < p.1)

/-- Product of all positive differences `s - t`. -/
def diffProd (S T : Finset ℕ) : ℕ := ∏ p ∈ posPairs S T, (p.1 - p.2)

/-- `lcm(1,…,n)`. -/
def lcmUpTo (n : ℕ) : ℕ := (Icc 1 n).lcm id

theorem DivCover.mono {n m : ℕ} {S T : Finset ℕ} (h : DivCover m S T) (hnm : n ≤ m) :
    DivCover n S T := fun i h1 hi => h i h1 (hi.trans hnm)

theorem diffProd_pos (S T : Finset ℕ) : 0 < diffProd S T := by
  unfold diffProd
  refine Finset.prod_pos ?_
  intro p hp
  simp only [posPairs, mem_filter] at hp
  omega

theorem lcmUpTo_dvd_diffProd {n : ℕ} {S T : Finset ℕ} (h : DivCover n S T) :
    lcmUpTo n ∣ diffProd S T := by
  unfold lcmUpTo
  rw [Finset.lcm_dvd_iff]
  intro i hi
  rw [mem_Icc] at hi
  obtain ⟨s, hs, t, ht, hts, hdvd⟩ := h i hi.1 hi.2
  have hmem : (s, t) ∈ posPairs S T := by
    simp [posPairs, hs, ht, hts]
  exact hdvd.trans (Finset.dvd_prod_of_mem (fun p : ℕ × ℕ => p.1 - p.2) hmem)

theorem lcmUpTo_pos (n : ℕ) : 0 < lcmUpTo n := by
  unfold lcmUpTo
  apply Nat.pos_of_ne_zero
  rw [Ne, Finset.lcm_eq_zero_iff]
  simp

theorem centralBinom_dvd_lcmUpTo (k : ℕ) : k.centralBinom ∣ lcmUpTo (2 * k) := by
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · simp
  have hC : k.centralBinom ≠ 0 := (Nat.centralBinom_pos k).ne'
  have hL : lcmUpTo (2 * k) ≠ 0 := (lcmUpTo_pos _).ne'
  rw [← Nat.factorization_le_iff_dvd hC hL]
  intro p
  by_cases hp : p.Prime
  · rw [← hp.pow_dvd_iff_le_factorization hL]
    have hle : p ^ k.centralBinom.factorization p ≤ 2 * k := by
      rw [Nat.centralBinom_eq_two_mul_choose]
      exact Nat.pow_factorization_choose_le (by omega)
    have h1 : 1 ≤ p ^ k.centralBinom.factorization p := Nat.one_le_pow _ _ hp.pos
    unfold lcmUpTo
    exact Finset.dvd_lcm (f := id) (mem_Icc.mpr ⟨h1, hle⟩)
  · simp [Nat.factorization_eq_zero_of_not_prime _ hp]

theorem card_posPairs_le (S T : Finset ℕ) : (posPairs S T).card ≤ S.card * T.card := by
  unfold posPairs
  exact (card_filter_le _ _).trans (card_product S T).le

theorem diffProd_le {S T : Finset ℕ} {M : ℕ} (hM1 : 1 ≤ M) (hM : ∀ s ∈ S, s ≤ M) :
    diffProd S T ≤ M ^ (S.card * T.card) := by
  unfold diffProd
  have h1 : ∏ p ∈ posPairs S T, (p.1 - p.2) ≤ ∏ _p ∈ posPairs S T, M := by
    apply Finset.prod_le_prod' 
    intro p hp
    simp only [posPairs, mem_filter, mem_product] at hp
    have := hM p.1 hp.1.1
    omega
  rw [prod_const] at h1
  exact h1.trans (Nat.pow_le_pow_right hM1 (card_posPairs_le S T))

/-- **The counting wall (explicit, natural-number form).** -/
theorem counting_wall {k M : ℕ} {S T : Finset ℕ} (hk : 0 < k) (h : DivCover (2 * k) S T)
    (hM : ∀ s ∈ S, s ≤ M) : 4 ^ k ≤ 2 * k * M ^ (S.card * T.card) := by
  have h1 := Nat.four_pow_le_two_mul_self_mul_centralBinom k hk
  have h2 : k.centralBinom ≤ diffProd S T :=
    Nat.le_of_dvd (diffProd_pos S T) ((centralBinom_dvd_lcmUpTo k).trans (lcmUpTo_dvd_diffProd h))
  have hM1 : 1 ≤ M := by
    obtain ⟨s, hs, t, _, hts, _⟩ := h 1 le_rfl (by omega)
    have := hM s hs
    omega
  have h3 := diffProd_le (T := T) hM1 hM
  calc 4 ^ k ≤ 2 * k * k.centralBinom := h1
    _ ≤ 2 * k * M ^ (S.card * T.card) := Nat.mul_le_mul_left _ (h2.trans h3)

open Real Filter in
/-- **The counting wall, real form.** -/
theorem real_wall {n : ℕ} (hn : 2 ≤ n) {S T : Finset ℕ} (h : DivCover n S T)
    {α βS βT : ℝ} (hS : (S.card : ℝ) ≤ (n : ℝ) ^ βS) (hT : (T.card : ℝ) ≤ (n : ℝ) ^ βT)
    (hM : ∀ s ∈ S, (s : ℝ) ≤ exp ((n : ℝ) ^ α)) :
    ((n : ℝ) - 1) * log 2 ≤ log n + (n : ℝ) ^ (α + βS + βT) := by
  set k := n / 2 with hk
  have hk0 : 0 < k := by omega
  have h2k : 2 * k ≤ n := by omega
  have hnk : (n : ℝ) - 1 ≤ 2 * k := by
    have : n ≤ 2 * k + 1 := by omega
    have : (n : ℝ) ≤ 2 * k + 1 := by exact_mod_cast this
    linarith
  set E := exp ((n : ℝ) ^ α) with hE
  set M := ⌊E⌋₊ with hMdef
  have hMS : ∀ s ∈ S, s ≤ M := fun s hs => Nat.le_floor (hM s hs)
  have hwall := counting_wall hk0 (h.mono h2k) hMS
  set m := S.card * T.card with hm
  have hMR : (M : ℝ) ≤ E := Nat.floor_le (exp_pos _).le
  have hnpos : (0 : ℝ) < n := by exact_mod_cast (by omega : 0 < n)
  -- cast to ℝ
  have hR : (4 : ℝ) ^ k ≤ n * E ^ m := by
    have h1 : ((4 ^ k : ℕ) : ℝ) ≤ ((2 * k * M ^ m : ℕ) : ℝ) := by exact_mod_cast hwall
    push_cast at h1
    have h2 : (2 * k : ℝ) ≤ n := by exact_mod_cast h2k
    have h3 : (M : ℝ) ^ m ≤ E ^ m := pow_le_pow_left₀ (Nat.cast_nonneg _) hMR m
    calc (4 : ℝ) ^ k ≤ 2 * k * (M : ℝ) ^ m := h1
      _ ≤ n * E ^ m := mul_le_mul h2 h3 (by positivity) hnpos.le
  have hlog := Real.log_le_log (by positivity) hR
  rw [Real.log_mul hnpos.ne' (by positivity), Real.log_pow, Real.log_pow, hE, Real.log_exp] at hlog
  have h4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; norm_num
  have hmR : (m : ℝ) ≤ (n : ℝ) ^ βS * (n : ℝ) ^ βT := by
    rw [hm]; push_cast
    exact mul_le_mul hS hT (Nat.cast_nonneg _) (by positivity)
  have hpow : (m : ℝ) * (n : ℝ) ^ α ≤ (n : ℝ) ^ (α + βS + βT) := by
    rw [Real.rpow_add hnpos, Real.rpow_add hnpos]
    have : (0 : ℝ) ≤ (n : ℝ) ^ α := by positivity
    nlinarith
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [h4] at hlog
  nlinarith

open Real Filter in
theorem eventually_gap {γ : ℝ} (hγ : γ < 1) :
    ∀ᶠ x : ℝ in atTop, Real.log x + x ^ γ < (x - 1) * Real.log 2 := by
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  set c := Real.log 2 / 4 with hc
  have hc0 : 0 < c := by positivity
  have ev1 := Real.isLittleO_log_id_atTop.def hc0
  have ev2 : ∀ᶠ x : ℝ in atTop, x ^ (-(1 - γ)) < c :=
    (tendsto_rpow_neg_atTop (by linarith : 0 < 1 - γ)).eventually (gt_mem_nhds hc0)
  filter_upwards [ev1, ev2, eventually_ge_atTop (4 : ℝ)] with x h1 h2 h3
  have hx0 : 0 < x := by linarith
  simp only [id, Real.norm_eq_abs, abs_of_pos hx0] at h1
  have h1' : Real.log x ≤ c * x := (le_abs_self _).trans h1
  have h2' : x ^ γ ≤ c * x := by
    have : x ^ γ = x ^ (-(1 - γ)) * x := by
      rw [← Real.rpow_add_one hx0.ne']; ring_nf
    rw [this]; exact mul_le_mul_of_nonneg_right h2.le hx0.le
  nlinarith

open Real Filter in
/-- **The exponent constraint `α ≥ 1 - βS - βT`.** -/
theorem exponent_constraint {α βS βT : ℝ} (hsub : α + βS + βT < 1) :
    ∀ᶠ n : ℕ in atTop, ∀ S T : Finset ℕ,
      (S.card : ℝ) ≤ (n : ℝ) ^ βS → (T.card : ℝ) ≤ (n : ℝ) ^ βT →
      (∀ s ∈ S, (s : ℝ) ≤ exp ((n : ℝ) ^ α)) → ¬ DivCover n S T := by
  have ev := tendsto_natCast_atTop_atTop.eventually (eventually_gap hsub)
  filter_upwards [ev, eventually_ge_atTop 2] with n hgap hn S T hS hT hM hcov
  have := real_wall hn hcov hS hT hM
  linarith

end Cryptography.FactoringBarriers.UMWFrontier

namespace Cryptography.FactoringBarriers.UMWFrontier
open Finset

/-- The `j`-th block product `(jL+1)(jL+2)⋯(jL+L)`. -/
def block (L j : ℕ) : ℕ := ∏ i ∈ Icc (j * L + 1) (j * L + L), i

/-- The trivial (one-sided) covering set: all block products. -/
def trivS (n L : ℕ) : Finset ℕ := (range ((n + L - 1) / L)).image (block L)

theorem block_pos (L j : ℕ) : 0 < block L j :=
  Finset.prod_pos (fun i hi => by rw [mem_Icc] at hi; omega)

theorem trivial_cover (n L : ℕ) (hL : 0 < L) : DivCover n (trivS n L) {0} := by
  intro i hi hin
  set j := (i - 1) / L with hj
  have h1 := Nat.div_add_mod (i - 1) L
  have h2 := Nat.mod_lt (i - 1) hL
  have h3 := Nat.div_add_mod (n + L - 1) L
  have h4 := Nat.mod_lt (n + L - 1) hL
  set B := (n + L - 1) / L with hB
  have hjB : j < B := by
    have : L * j < L * B := by
      rw [mul_comm L j, mul_comm L B] at *
      omega
    exact Nat.lt_of_mul_lt_mul_left this
  refine ⟨block L j, mem_image.mpr ⟨j, mem_range.mpr hjB, rfl⟩, 0, mem_singleton_self _,
    block_pos L j, ?_⟩
  rw [Nat.sub_zero]
  apply Finset.dvd_prod_of_mem
  rw [mem_Icc]
  rw [mul_comm L j] at h1
  constructor <;> omega

theorem card_trivS_le (n L : ℕ) : (trivS n L).card ≤ (n + L - 1) / L :=
  card_image_le.trans (card_range _).le

theorem block_le (L j c : ℕ) (hc : j * L + L ≤ c) : block L j ≤ c ^ L := by
  unfold block
  calc ∏ i ∈ Icc (j * L + 1) (j * L + L), i ≤ ∏ _i ∈ Icc (j * L + 1) (j * L + L), c :=
        Finset.prod_le_prod' (fun i hi => by rw [mem_Icc] at hi; omega)
    _ = c ^ L := by rw [prod_const, Nat.card_Icc]; congr 1; omega

theorem trivS_le (n L : ℕ) (hL : 0 < L) : ∀ s ∈ trivS n L, s ≤ (n + L) ^ L := by
  intro s hs
  obtain ⟨j, hj, rfl⟩ := mem_image.mp hs
  rw [mem_range] at hj
  apply block_le
  have h3 := Nat.div_mul_le_self (n + L - 1) L
  have : (j + 1) * L ≤ (n + L - 1) / L * L := Nat.mul_le_mul_right L hj
  rw [add_mul, one_mul] at this
  omega

end Cryptography.FactoringBarriers.UMWFrontier

namespace Cryptography.FactoringBarriers.UMWFrontier
open Finset Real Filter

/-- `(α, βS, βT)` is **feasible**: for all large `n` there is a divisibility covering
of `[1,n]` with `|S| ≤ n^βS`, `|T| ≤ n^βT` and all elements of `S` at most `exp(n^α)`. -/
def Feasible (α βS βT : ℝ) : Prop :=
  ∀ᶠ n : ℕ in atTop, ∃ S T : Finset ℕ, (S.card : ℝ) ≤ (n : ℝ) ^ βS ∧
    (T.card : ℝ) ≤ (n : ℝ) ^ βT ∧ (∀ s ∈ S, (s : ℝ) ≤ exp ((n : ℝ) ^ α)) ∧ DivCover n S T

/-- **Necessity:** every feasible triple obeys `α + βS + βT ≥ 1`. -/
theorem Feasible.constraint {α βS βT : ℝ} (h : Feasible α βS βT) : 1 ≤ α + βS + βT := by
  by_contra hlt
  push_neg at hlt
  obtain ⟨n, hn1, hn2⟩ := (h.and (exponent_constraint hlt)).exists
  obtain ⟨S, T, hS, hT, hM, hc⟩ := hn1
  exact hn2 S T hS hT hM hc

theorem Feasible.mono {α α' βS βS' βT βT' : ℝ} (h : Feasible α βS βT) (hα : α ≤ α')
    (hS : βS ≤ βS') (hT : βT ≤ βT') : Feasible α' βS' βT' := by
  filter_upwards [h, eventually_ge_atTop 1] with n ⟨S, T, h1, h2, h3, h4⟩ hn
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  refine ⟨S, T, h1.trans (Real.rpow_le_rpow_of_exponent_le hn1 hS),
    h2.trans (Real.rpow_le_rpow_of_exponent_le hn1 hT), fun s hs => (h3 s hs).trans ?_, h4⟩
  exact Real.exp_le_exp.mpr (Real.rpow_le_rpow_of_exponent_le hn1 hα)

/-- Analytic input for the block construction. -/
theorem eventually_block_bound {α β : ℝ} (hβ0 : 0 < β) (hα : 1 - β < α) :
    ∀ᶠ x : ℝ in atTop, 1 ≤ x ∧ 2 ≤ x ^ β ∧ 3 * x ^ (1 - β) * Real.log (4 * x) ≤ x ^ α := by
  set δ := α - (1 - β) with hδ
  have hδ0 : 0 < δ := by linarith
  have ev1 := (isLittleO_log_rpow_atTop hδ0).def (by norm_num : (0 : ℝ) < 1 / 6)
  have ev2 := (tendsto_rpow_atTop hδ0).eventually (eventually_ge_atTop (6 * Real.log 4))
  have ev3 := (tendsto_rpow_atTop hβ0).eventually (eventually_ge_atTop (2 : ℝ))
  filter_upwards [ev1, ev2, ev3, eventually_ge_atTop (1 : ℝ)] with x h1 h2 h3 hx
  have hx0 : 0 < x := by linarith
  refine ⟨hx, h3, ?_⟩
  have hxd : 0 ≤ x ^ δ := by positivity
  rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_nonneg hxd] at h1
  have hlog : Real.log (4 * x) ≤ x ^ δ / 3 := by
    rw [Real.log_mul (by norm_num) hx0.ne']
    have := le_abs_self (Real.log x)
    linarith
  have hsplit : x ^ α = x ^ (1 - β) * x ^ δ := by
    rw [← Real.rpow_add hx0]; congr 1; ring
  rw [hsplit]
  have : 0 ≤ x ^ (1 - β) := by positivity
  nlinarith

/-- **Sufficiency (the trivial covering):** for `0 < β ≤ 1` and every `α > 1 - β`, the
block-product covering with `T = {0}` is feasible. -/
theorem trivial_feasible {α β : ℝ} (hβ0 : 0 < β) (hβ1 : β ≤ 1) (hα : 1 - β < α) :
    Feasible α β 0 := by
  filter_upwards [tendsto_natCast_atTop_atTop.eventually (eventually_block_bound hβ0 hα)]
    with n ⟨hn1, hnβ, hbound⟩
  set x : ℝ := (n : ℝ) with hx
  have hx0 : 0 < x := by linarith
  set L := ⌈2 * x ^ (1 - β)⌉₊ with hLdef
  have hu1 : 1 ≤ x ^ (1 - β) := Real.one_le_rpow hn1 (by linarith)
  have hux : x ^ (1 - β) ≤ x := by
    have := Real.rpow_le_rpow_of_exponent_le hn1 (by linarith : 1 - β ≤ 1)
    simpa using this
  have hLge : 2 * x ^ (1 - β) ≤ L := Nat.le_ceil _
  have hLle : (L : ℝ) < 2 * x ^ (1 - β) + 1 := Nat.ceil_lt_add_one (by positivity)
  have hLpos : 0 < L := by
    have : (0 : ℝ) < L := by linarith
    exact_mod_cast this
  refine ⟨trivS n L, {0}, ?_, ?_, ?_, trivial_cover n L hLpos⟩
  · -- size bound
    have hB := card_trivS_le n L
    have hBL := Nat.div_mul_le_self (n + L - 1) L
    set B := (n + L - 1) / L
    have hBL' : (B : ℝ) * L < x + L := by
      have h0 : B * L < n + L := by omega
      have h0' : ((B * L : ℕ) : ℝ) < ((n + L : ℕ) : ℝ) := by exact_mod_cast h0
      push_cast at h0'
      linarith
    have hsplit : x = x ^ (1 - β) * x ^ β := by
      rw [← Real.rpow_add hx0]; simp
    have hB' : (B : ℝ) < x ^ β := by
      have hLR : (0 : ℝ) < L := by exact_mod_cast hLpos
      have h1 : (B : ℝ) * L < x ^ β * L := by
        have : x + L ≤ x ^ β * L := by
          have : x ^ β * (2 * x ^ (1 - β)) ≤ x ^ β * L :=
            mul_le_mul_of_nonneg_left hLge (by positivity)
          nlinarith
        linarith
      exact lt_of_mul_lt_mul_right h1 hLR.le
    have : ((trivS n L).card : ℝ) ≤ B := by exact_mod_cast hB
    linarith
  · simp
  · intro s hs
    have h1 := trivS_le n L hLpos s hs
    have hsR : (s : ℝ) ≤ ((n : ℝ) + L) ^ L := by exact_mod_cast h1
    refine hsR.trans ?_
    have hL3 : (L : ℝ) ≤ 3 * x ^ (1 - β) := by linarith
    have hnL : x + L ≤ 4 * x := by linarith
    have hpos : 0 < x + L := by positivity
    rw [← Real.exp_log (by positivity : (0 : ℝ) < (x + L) ^ L), Real.exp_le_exp, Real.log_pow]
    have hlog : Real.log (x + L) ≤ Real.log (4 * x) := Real.log_le_log hpos hnL
    have hlog0 : 0 ≤ Real.log (x + L) := Real.log_nonneg (by linarith)
    calc (L : ℝ) * Real.log (x + L) ≤ 3 * x ^ (1 - β) * Real.log (4 * x) :=
          mul_le_mul hL3 hlog hlog0 (by positivity)
      _ ≤ x ^ α := hbound

end Cryptography.FactoringBarriers.UMWFrontier

namespace Cryptography.FactoringBarriers.UMWFrontier
open Finset Real Filter

/-- **The one-sided frontier is exactly `α = 1 - β`.** -/
theorem one_sided_frontier {α β : ℝ} (hβ0 : 0 < β) (hβ1 : β ≤ 1) :
    (Feasible α β 0 → 1 - β ≤ α) ∧ (1 - β < α → Feasible α β 0) := by
  refine ⟨fun h => ?_, trivial_feasible hβ0 hβ1⟩
  have := h.constraint
  linarith

/-- **The UMW sandwich at `β = 1/3`.** -/
theorem umw_sandwich :
    (∀ α : ℝ, Feasible α (1 / 3) (1 / 3) → 1 / 3 ≤ α) ∧
    (∀ α : ℝ, 2 / 3 < α → Feasible α (1 / 3) (1 / 3)) := by
  refine ⟨fun α h => ?_, fun α hα => ?_⟩
  · have := h.constraint
    linarith
  · exact (trivial_feasible (by norm_num) (by norm_num) (by linarith)).mono le_rfl le_rfl
      (by norm_num)

/-- **The empirical frontier point `(1/2, 2/3)` is dominated by the trivial covering.** -/
theorem empirical_point_dominated : Feasible (2 / 5) (2 / 3) 0 ∧ Feasible (1 / 2) (2 / 3) (2 / 3) := by
  have h : Feasible (2 / 5) (2 / 3) 0 := trivial_feasible (by norm_num) (by norm_num) (by norm_num)
  exact ⟨h, h.mono (by norm_num) le_rfl (by norm_num)⟩

/-! ## The α-unit trap -/

/-- The measured exponent of a construction with largest element `M`. -/
noncomputable def measuredAlpha (n M : ℝ) : ℝ := Real.log (Real.log M) / Real.log n

theorem measuredAlpha_exp {n α : ℝ} (hn : 1 < n) : measuredAlpha n (exp (n ^ α)) = α := by
  have hn0 : 0 < n := by linarith
  have hl : 0 < Real.log n := Real.log_pos hn
  unfold measuredAlpha
  rw [Real.log_exp, Real.log_rpow hn0]
  field_simp

theorem measuredAlpha_le {n M α : ℝ} (hn : 1 < n) (hM1 : 1 < M) (hM : M ≤ exp (n ^ α)) :
    measuredAlpha n M ≤ α := by
  have hn0 : 0 < n := by linarith
  have hl : 0 < Real.log n := Real.log_pos hn
  unfold measuredAlpha
  rw [div_le_iff₀ hl]
  have h1 : Real.log M ≤ n ^ α := by
    have := Real.log_le_log (by linarith) hM
    rwa [Real.log_exp] at this
  have h2 := Real.log_le_log (Real.log_pos hM1) h1
  rwa [Real.log_rpow hn0] at h2

/-- The single-logarithm "exponent" `log M / log n` of `M = exp(n^α)` diverges. -/
theorem single_log_unit_diverges {α : ℝ} (hα : 0 < α) :
    Tendsto (fun x : ℝ => Real.log (exp (x ^ α)) / Real.log x) atTop atTop := by
  simp only [Real.log_exp]
  rw [tendsto_atTop]
  intro B
  have hB : 0 < max B 1 := lt_of_lt_of_le one_pos (le_max_right _ _)
  have ev := (isLittleO_log_rpow_atTop hα).def (inv_pos.mpr hB)
  filter_upwards [ev, eventually_ge_atTop (3 : ℝ)] with x h1 h3
  have hx0 : 0 < x := by linarith
  have hl : 0 < Real.log x := Real.log_pos (by linarith)
  rw [Real.norm_eq_abs, Real.norm_eq_abs, abs_of_pos hl,
    abs_of_nonneg (by positivity : (0 : ℝ) ≤ x ^ α)] at h1
  rw [le_div_iff₀ hl]
  have : max B 1 * Real.log x ≤ x ^ α := by
    have := mul_le_mul_of_nonneg_left h1 hB.le
    rwa [← mul_assoc, mul_inv_cancel₀ hB.ne', one_mul] at this
  nlinarith [le_max_left B 1]

end Cryptography.FactoringBarriers.UMWFrontier

namespace Cryptography.FactoringBarriers.UMWFrontier
open Finset

/-! ## The large-prime budget -/

theorem dvd_lcmUpTo {n i : ℕ} (h1 : 1 ≤ i) (hi : i ≤ n) : i ∣ lcmUpTo n :=
  Finset.dvd_lcm (f := id) (mem_Icc.mpr ⟨h1, hi⟩)

/-- **The large-prime wall.** -/
theorem large_prime_wall {n M y : ℕ} {S T : Finset ℕ} (h : DivCover n S T) (hM1 : 1 ≤ M)
    (hM : ∀ s ∈ S, s ≤ M) :
    y ^ ((Ioc y n).filter Nat.Prime).card ≤ M ^ (S.card * T.card) := by
  set P := (Ioc y n).filter Nat.Prime with hP
  have hdvd : ∏ p ∈ P, p ∣ diffProd S T := by
    apply Finset.prod_primes_dvd
    · intro p hp
      exact (mem_filter.mp hp).2.prime
    · intro p hp
      have hp' := mem_filter.mp hp
      have hpn := (mem_Ioc.mp hp'.1).2
      exact (dvd_lcmUpTo hp'.2.one_lt.le hpn).trans (lcmUpTo_dvd_diffProd h)
  have h1 : y ^ P.card ≤ ∏ p ∈ P, p := by
    rw [← prod_const]
    exact Finset.prod_le_prod' (fun p hp => (mem_Ioc.mp (mem_filter.mp hp).1).1.le)
  exact h1.trans ((Nat.le_of_dvd (diffProd_pos S T) hdvd).trans (diffProd_le hM1 hM))

/-! ## The polynomial (resultant) bridge and the disjointness guard -/

/-- Integer divisibility covering. -/
def DivCoverZ (n : ℕ) (S T : Finset ℤ) : Prop :=
  ∀ i : ℕ, 1 ≤ i → i ≤ n → ∃ s ∈ S, ∃ t ∈ T, (i : ℤ) ∣ s - t

open Polynomial in
/-- **The resultant bridge.** -/
theorem resultant_bridge {n : ℕ} {S T : Finset ℤ} (hdisj : Disjoint S T)
    (h : DivCoverZ n S T) :
    ((lcmUpTo n : ℕ) : ℤ) ∣ ∏ s ∈ S, (∏ t ∈ T, (X - C t)).eval s ∧
      ∏ s ∈ S, (∏ t ∈ T, (X - C t)).eval s ≠ 0 := by
  have hid : ∏ s ∈ S, (∏ t ∈ T, (X - C t)).eval s = ∏ s ∈ S, ∏ t ∈ T, (s - t) := by
    simp [Polynomial.eval_prod]
  rw [hid]
  constructor
  · rw [Int.natCast_dvd]
    unfold lcmUpTo
    rw [Finset.lcm_dvd_iff]
    intro i hi
    rw [mem_Icc] at hi
    obtain ⟨s, hs, t, ht, hdiv⟩ := h i hi.1 hi.2
    have : (i : ℤ) ∣ ∏ s ∈ S, ∏ t ∈ T, (s - t) :=
      hdiv.trans ((Finset.dvd_prod_of_mem (fun t => s - t) ht).trans
        (Finset.dvd_prod_of_mem (fun s => ∏ t ∈ T, (s - t)) hs))
    rw [Int.natCast_dvd] at this
    simpa using this
  · rw [Finset.prod_ne_zero_iff]
    intro s hs
    rw [Finset.prod_ne_zero_iff]
    intro t ht
    have : s ≠ t := fun hst => Finset.disjoint_left.mp hdisj hs (hst ▸ ht)
    exact sub_ne_zero.mpr this

/-- **The disjointness guard is essential.** -/
theorem overlap_trivializes (n : ℕ) (a : ℤ) : DivCoverZ n {a} {a} := by
  intro i _ _
  exact ⟨a, mem_singleton_self a, a, mem_singleton_self a, by simp⟩

end Cryptography.FactoringBarriers.UMWFrontier