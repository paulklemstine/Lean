import Mathlib
import Bridges.HarveyMLegClosed

/-!
# Round 33: Harvey's `1/5` is pinned by an ORDER-FREE triangle

Harvey's deterministic factoring algorithm (arXiv:2010.05450, Prop. 4.3) is modelled in the
catalog (`Bridges.HarveyMLegClosed.costExp`, identical to
`Crypto.FactoringBarrier.HarveyBalance.costExp`) by the exponent cost
`max{ a, b, 1/2 - a/2 - b }` with `r = N^a` (Lehman pair budget), `m = N^b` (baby steps).

The question: can a deterministic large-order element (the Harvey–Hittmeir / GFHP line of
work) move the exponent `1/5`?  The order `ord_N(α)` enters the algorithm in two ways only:

* as a **correctness constraint** `m ≤ ord(α)` (the baby steps must be distinct; catalog
  `HarveyMLegClosed.babyChain_nodup`, sharp by `babyChain_collision`);
* as the **product-tree term** (spurious hash hits), a nonnegative additive term.

This file proves that neither can move `1/5`:

1. **Order-constrained optimum** (`orderValue`, `order_constrained_lower`,
   `order_constrained_attained`): with the order exponent `ω` (`ord α = N^ω`) the optimum is
   exactly `max(1/5, (1 - 2ω)/3)`.  So the order constraint is *slack* (zero shadow price)
   as soon as `ω ≥ 1/5` (`orderValue_eq_fifth_iff`, `order_shadow_price_zero`) and it only
   ever *hurts* below that threshold.  The minimiser is unique (`costExp_eq_fifth_iff`).
2. **Real-valued Prop 4.3 with all polylog factors** (`harveyTime_lower`,
   `harveyTime_attained`): `(N^{1/2}/(r^{1/2}m) + r)L⁴ + mL² ≥ N^{1/5}L^{16/5}` for all
   `r, m > 0`, attained up to the factor `3`.  Adding any nonnegative order-dependent
   product-tree term `P` (`free_order_cannot_help`) keeps the lower bound; making it free
   (`P = 0`) leaves the optimum in `[F, 3F]`, `F = N^{1/5}L^{16/5}`.
3. **Large-order production is dominated** (`order_production_dominated`,
   `order_production_total`): producing an element of order `N^ω` at GFHP-type cost
   `N^{ω/2}` never changes the cost at any point with `ω = b ≥ 0`, and the joint optimum
   including the production stays exactly `1/5`.
4. **The `(a,b)` pair-filter** (`generative_filter_value`, `evaluated_filter_value`):
   a filter that *generates* only a `1/s` fraction of the pairs (`s = N^σ`) gives exactly
   `1/5 - 3σ/5` (`1/6` iff `σ = 1/18`); a filter that must *evaluate* every pair gives only
   `1/5 - 2σ/5` (`1/6` iff `σ = 1/12`).  A sound residue sieve on residue-uniform good pairs
   is trivial (`sound_residue_sieve_trivial`).
5. **Large Euler gap** (`euler_exponent_reduction`, `euler_gap_gcd_split`):
   `a^{pq-1} = a^{q-1}` in `ZMod p`, so if `(p-1) ∣ (q-1)` then `gcd(x^{pq-1}-1, pq) = p`
   whenever `q ∤ x^{pq-1}-1` — the structured-promise split.

Everything is about the *cost model*; `N^{1/5}` is an upper bound on the deterministic record,
not a proven floor for factoring.
-/

namespace Bridges.OrderFreeTriangle

open Bridges.HarveyMLegClosed

/-! ## 1. The order-constrained optimum -/

/-- The optimum of Harvey's exponent cost under the correctness constraint `b ≤ ω`
(baby-step count `N^b` at most the order `N^ω`). -/
noncomputable def orderValue (ω : ℝ) : ℝ := max (1 / 5) ((1 - 2 * ω) / 3)

/-- **Lower bound.** Every admissible `(a, b)` with `b ≤ ω` costs at least `orderValue ω`. -/
theorem order_constrained_lower (ω a b : ℝ) (hb : b ≤ ω) : orderValue ω ≤ costExp a b := by
  have h15 := harvey_dual_certificate a b
  unfold orderValue
  refine max_le h15 ?_
  unfold costExp
  have h1 := le_max_left a (max b (1 / 2 - a / 2 - b))
  have h3 := le_trans (le_max_right b (1 / 2 - a / 2 - b)) (le_max_right a _)
  linarith

/-- **Attainment.** The bound `orderValue ω` is achieved by an admissible `(a, b)`. -/
theorem order_constrained_attained (ω : ℝ) :
    ∃ a b : ℝ, b ≤ ω ∧ costExp a b = orderValue ω := by
  rcases le_or_gt (1 / 5) ω with h | h
  · refine ⟨1 / 5, 1 / 5, h, ?_⟩
    unfold costExp orderValue
    simp only [max_def]
    split_ifs <;> linarith
  · refine ⟨(1 - 2 * ω) / 3, ω, le_rfl, ?_⟩
    unfold costExp orderValue
    have e : 1 / 2 - (1 - 2 * ω) / 3 / 2 - ω = (1 - 2 * ω) / 3 := by ring
    rw [e]
    simp only [max_def]
    split_ifs <;> linarith

/-- **The unique minimiser.** `costExp a b = 1/5` forces `a = b = 1/5`. -/
theorem costExp_eq_fifth_iff (a b : ℝ) : costExp a b = 1 / 5 ↔ a = 1 / 5 ∧ b = 1 / 5 := by
  constructor
  · intro h
    unfold costExp at h
    have h1 := le_max_left a (max b (1 / 2 - a / 2 - b))
    have h2 := le_trans (le_max_left b (1 / 2 - a / 2 - b)) (le_max_right a _)
    have h3 := le_trans (le_max_right b (1 / 2 - a / 2 - b)) (le_max_right a _)
    rw [h] at h1 h2 h3
    constructor <;> linarith
  · rintro ⟨rfl, rfl⟩
    unfold costExp; norm_num

/-- **Threshold.** The order constraint costs nothing iff `ω ≥ 1/5`. -/
theorem orderValue_eq_fifth_iff (ω : ℝ) : orderValue ω = 1 / 5 ↔ 1 / 5 ≤ ω := by
  unfold orderValue
  constructor
  · intro h
    have := le_max_right (1 / 5 : ℝ) ((1 - 2 * ω) / 3)
    rw [h] at this
    linarith
  · intro h
    exact max_eq_left (by linarith)

/-- Below the threshold the order constraint strictly hurts. -/
theorem orderValue_gt_of_lt (ω : ℝ) (h : ω < 1 / 5) : 1 / 5 < orderValue ω := by
  unfold orderValue
  exact lt_of_lt_of_le (by linarith) (le_max_right _ _)

/-- **Zero shadow price.** Above the threshold, any further increase of the order (e.g. an
element of maximal order `ω = 1`) leaves the optimum unchanged. -/
theorem order_shadow_price_zero (ω₁ ω₂ : ℝ) (h₁ : 1 / 5 ≤ ω₁) (h₂ : 1 / 5 ≤ ω₂) :
    orderValue ω₁ = orderValue ω₂ := by
  rw [(orderValue_eq_fifth_iff ω₁).2 h₁, (orderValue_eq_fifth_iff ω₂).2 h₂]

/-- **Order is not a lever.** No order exponent whatsoever yields an admissible point below
`1/5`, and the optimum `1/5` *requires* order at least `N^{1/5}` (unique minimiser). -/
theorem order_not_a_lever (ω a b : ℝ) (hb : b ≤ ω) :
    1 / 5 ≤ costExp a b ∧ (costExp a b = 1 / 5 → 1 / 5 ≤ ω) := by
  refine ⟨harvey_dual_certificate a b, fun h => ?_⟩
  have := ((costExp_eq_fifth_iff a b).1 h).2
  linarith

/-! ## 2. Prop 4.3 with its polylog factors -/

/-- Harvey's Prop 4.3 running time `(N^{1/2}/(r^{1/2} m) + r)·L⁴ + m·L²`, `L = lg N`. -/
noncomputable def harveyTime (N L r m : ℝ) : ℝ :=
  (Real.sqrt N / (Real.sqrt r * m) + r) * L ^ 4 + m * L ^ 2

/-- The predicted optimum `F(N) = N^{1/5}·L^{16/5}`. -/
noncomputable def harveyF (N L : ℝ) : ℝ := N ^ (1 / 5 : ℝ) * L ^ (16 / 5 : ℝ)

/-- The weighted product identity behind the `(1/5, 2/5, 2/5)` certificate:
`X·Y²·Z² = N·L¹⁶` for the three legs `X = rL⁴`, `Y = √N L⁴/(√r m)`, `Z = mL²`. -/
theorem legs_product (N L r m : ℝ) (hN : 0 ≤ N) (hr : 0 < r) (hm : 0 < m) :
    (r * L ^ 4) * (Real.sqrt N * L ^ 4 / (Real.sqrt r * m)) ^ 2 * (m * L ^ 2) ^ 2
      = N * L ^ 16 := by
  have hsr : 0 < Real.sqrt r := Real.sqrt_pos.2 hr
  rw [div_pow, mul_pow, mul_pow (Real.sqrt r), Real.sq_sqrt hN, Real.sq_sqrt hr.le]
  field_simp

/-- **The order-free lower bound with all polylog factors.** For every `r, m > 0`,
Harvey's running time is at least `N^{1/5}·L^{16/5}`. -/
theorem harveyTime_lower (N L r m : ℝ) (hN : 0 ≤ N) (hL : 0 ≤ L) (hr : 0 < r) (hm : 0 < m) :
    harveyF N L ≤ harveyTime N L r m := by
  set X := r * L ^ 4
  set Y := Real.sqrt N * L ^ 4 / (Real.sqrt r * m)
  set Z := m * L ^ 2
  have hX : 0 ≤ X := by positivity
  have hY : 0 ≤ Y := by positivity
  have hZ : 0 ≤ Z := by positivity
  have amgm := Real.geom_mean_le_arith_mean3_weighted (w₁ := 1 / 5) (w₂ := 2 / 5)
    (w₃ := 2 / 5) (by norm_num) (by norm_num) (by norm_num) hX hY hZ (by norm_num)
  have hprod : X ^ (1 / 5 : ℝ) * Y ^ (2 / 5 : ℝ) * Z ^ (2 / 5 : ℝ) = harveyF N L := by
    have e2Y : Y ^ (2 / 5 : ℝ) = (Y ^ 2) ^ (1 / 5 : ℝ) := by
      rw [← Real.rpow_natCast, ← Real.rpow_mul hY]; norm_num
    have e2Z : Z ^ (2 / 5 : ℝ) = (Z ^ 2) ^ (1 / 5 : ℝ) := by
      rw [← Real.rpow_natCast, ← Real.rpow_mul hZ]; norm_num
    rw [e2Y, e2Z, ← Real.mul_rpow hX (by positivity), ← Real.mul_rpow (by positivity)
      (by positivity), legs_product N L r m hN hr hm, Real.mul_rpow hN (by positivity)]
    unfold harveyF
    congr 1
    rw [← Real.rpow_natCast, ← Real.rpow_mul hL]; norm_num
  have hT : harveyTime N L r m = X + Y + Z := by
    simp only [harveyTime, X, Y, Z]; ring
  rw [hT, ← hprod]
  linarith

/-- On the parametrisation `N = u¹⁰`, `L = ℓ⁵`, the predicted optimum is `u²ℓ¹⁶`. -/
theorem harveyF_param (u ℓ : ℝ) (hu : 0 ≤ u) (hℓ : 0 ≤ ℓ) :
    harveyF (u ^ 10) (ℓ ^ 5) = u ^ 2 * ℓ ^ 16 := by
  unfold harveyF
  rw [← Real.rpow_natCast u, ← Real.rpow_mul hu, ← Real.rpow_natCast ℓ, ← Real.rpow_mul hℓ]
  norm_num

/-- **Attainment up to the factor 3.** At `r = N^{1/5}L^{-4/5}`, `m = N^{1/5}L^{6/5}`
(written in the parametrisation `N = u¹⁰`, `L = ℓ⁵`) all three legs equal `F`, so the
running time is exactly `3F`. -/
theorem harveyTime_attained (u ℓ : ℝ) (hu : 0 < u) (hℓ : 0 < ℓ) :
    harveyTime (u ^ 10) (ℓ ^ 5) (u ^ 2 / ℓ ^ 4) (u ^ 2 * ℓ ^ 6)
      = 3 * harveyF (u ^ 10) (ℓ ^ 5) := by
  rw [harveyF_param u ℓ hu.le hℓ.le]
  unfold harveyTime
  have h1 : Real.sqrt (u ^ 10) = u ^ 5 := by
    rw [show u ^ 10 = (u ^ 5) ^ 2 by ring]; exact Real.sqrt_sq (by positivity)
  have h2 : Real.sqrt (u ^ 2 / ℓ ^ 4) = u / ℓ ^ 2 := by
    rw [show u ^ 2 / ℓ ^ 4 = (u / ℓ ^ 2) ^ 2 by ring]; exact Real.sqrt_sq (by positivity)
  rw [h1, h2]
  field_simp
  ring

/-- **Free order-finding cannot help.** Whatever nonnegative product-tree term `P` the order
contributes (in particular `P = 0`, order-finding literally free), the total cost stays at
least `F = N^{1/5}L^{16/5}`. -/
theorem free_order_cannot_help (N L r m P : ℝ) (hN : 0 ≤ N) (hL : 0 ≤ L) (hr : 0 < r)
    (hm : 0 < m) (hP : 0 ≤ P) : harveyF N L ≤ harveyTime N L r m + P := by
  have := harveyTime_lower N L r m hN hL hr hm
  linarith

/-- **The free-order optimum is pinned in `[F, 3F]`.** With order-finding free, the best
total cost over all `r, m > 0` lies between `F` and `3F`: the exponent is exactly `1/5`. -/
theorem free_order_optimum_pinned (u ℓ : ℝ) (hu : 0 < u) (hℓ : 0 < ℓ) :
    (∀ r m : ℝ, 0 < r → 0 < m →
        harveyF (u ^ 10) (ℓ ^ 5) ≤ harveyTime (u ^ 10) (ℓ ^ 5) r m) ∧
      ∃ r m : ℝ, 0 < r ∧ 0 < m ∧
        harveyTime (u ^ 10) (ℓ ^ 5) r m ≤ 3 * harveyF (u ^ 10) (ℓ ^ 5) := by
  refine ⟨fun r m hr hm => harveyTime_lower _ _ r m (by positivity) (by positivity) hr hm,
    u ^ 2 / ℓ ^ 4, u ^ 2 * ℓ ^ 6, by positivity, by positivity, ?_⟩
  rw [harveyTime_attained u ℓ hu hℓ]

/-! ## 3. Large-order production is dominated -/

/-- **Dominance everywhere.** Producing the element of order `N^b` needed for `m = N^b`
baby steps at GFHP-type cost `N^{b/2}` never changes the cost exponent, for any `b ≥ 0`. -/
theorem order_production_dominated (a b : ℝ) (hb : 0 ≤ b) :
    max (costExp a b) (b / 2) = costExp a b := by
  apply max_eq_left
  unfold costExp
  exact le_trans (by linarith) (le_trans (le_max_left b _) (le_max_right a _))

/-- **Joint optimum including production.** Over all `(a, b, ω)` with `b ≤ ω` (correctness)
the cost `max(costExp a b, ω/2)` (algorithm + producing an order-`N^ω` element) is at least
`1/5`, and `1/5` is attained. -/
theorem order_production_total :
    (∀ a b ω : ℝ, b ≤ ω → 1 / 5 ≤ max (costExp a b) (ω / 2)) ∧
      ∃ a b ω : ℝ, b ≤ ω ∧ max (costExp a b) (ω / 2) = 1 / 5 := by
  refine ⟨fun a b ω _ => le_trans (harvey_dual_certificate a b) (le_max_left _ _),
    1 / 5, 1 / 5, 1 / 5, le_rfl, ?_⟩
  rw [order_production_dominated _ _ (by norm_num), (costExp_eq_fifth_iff _ _).2 ⟨rfl, rfl⟩]

/-- The `δ = N^{1/3}` instance: production cost exponent `1/6` is strictly below `1/5`. -/
theorem third_order_production_below : (1 / 3 : ℝ) / 2 < 1 / 5 := by norm_num

/-! ## 4. The `(a,b)` pair-filter -/

/-- A *generative* filter producing only a `1/s` fraction of the pairs (`s = N^σ`): both the
pair leg and the per-pair interior sum shrink by `σ`. -/
noncomputable def genFilterExp (σ a b : ℝ) : ℝ := cheapExp σ 0 σ a b

/-- An *evaluated* filter must still look at every pair: only the interior shrinks. -/
noncomputable def evalFilterExp (σ a b : ℝ) : ℝ := cheapExp 0 0 σ a b

/-- **Generative filter: optimum exactly `1/5 - 3σ/5`.** -/
theorem generative_filter_value (σ : ℝ) :
    (∀ a b, 1 / 5 - 3 * σ / 5 ≤ genFilterExp σ a b) ∧
      ∃ a b, genFilterExp σ a b = 1 / 5 - 3 * σ / 5 := by
  refine ⟨fun a b => ?_, ?_⟩
  · have := harvey_sensitivity σ 0 σ a b
    unfold genFilterExp; linarith
  · obtain ⟨a, b, h⟩ := harvey_sensitivity_attained σ 0 σ
    exact ⟨a, b, by unfold genFilterExp; rw [h]; ring⟩

/-- **Evaluated filter: optimum exactly `1/5 - 2σ/5`.** -/
theorem evaluated_filter_value (σ : ℝ) :
    (∀ a b, 1 / 5 - 2 * σ / 5 ≤ evalFilterExp σ a b) ∧
      ∃ a b, evalFilterExp σ a b = 1 / 5 - 2 * σ / 5 := by
  refine ⟨fun a b => ?_, ?_⟩
  · have := harvey_sensitivity 0 0 σ a b
    unfold evalFilterExp; linarith
  · obtain ⟨a, b, h⟩ := harvey_sensitivity_attained 0 0 σ
    exact ⟨a, b, by unfold evalFilterExp; rw [h]; ring⟩

/-- **The `1/6` targets.** A generative filter reaches `1/6` iff `s = N^{1/18}`; an
evaluated one needs `s = N^{1/12}`. -/
theorem sixth_targets (σ : ℝ) :
    (1 / 5 - 3 * σ / 5 = 1 / 6 ↔ σ = 1 / 18) ∧ (1 / 5 - 2 * σ / 5 = 1 / 6 ↔ σ = 1 / 12) := by
  constructor <;> constructor <;> intro h <;> linarith

/-- **Sound residue sieves on residue-uniform good pairs are trivial.** If every residue
class mod `ℓ` is the class of the good pair for some instance, a sieve (a set of accepted
classes) that never rejects the good pair accepts every class: compression `1`. -/
theorem sound_residue_sieve_trivial {ι : Type*} {ℓ : ℕ} [NeZero ℓ] (good : ι → ZMod ℓ)
    (huniform : Function.Surjective good) (A : Finset (ZMod ℓ)) (hsound : ∀ i, good i ∈ A) :
    A = Finset.univ ∧ A.card = ℓ := by
  have hA : A = Finset.univ := by
    ext c
    simp only [Finset.mem_univ, iff_true]
    obtain ⟨i, rfl⟩ := huniform c
    exact hsound i
  exact ⟨hA, by rw [hA, Finset.card_univ, ZMod.card]⟩

/-! ## 5. The large-Euler-gap promise class -/

/-- **Exponent reduction.** In `ZMod p`, `a^{pq-1} = a^{q-1}` for `a ≠ 0` (since
`pq - 1 = (q - 1) + q(p - 1)` and Fermat). -/
theorem euler_exponent_reduction (p q : ℕ) [hp : Fact p.Prime] (hq : 1 ≤ q) (a : ZMod p)
    (ha : a ≠ 0) : a ^ (p * q - 1) = a ^ (q - 1) := by
  have hp1 := hp.out.one_le
  have e : p * q - 1 = (q - 1) + q * (p - 1) := by
    obtain ⟨p', rfl⟩ : ∃ p', p = p' + 1 := ⟨p - 1, by omega⟩
    obtain ⟨q', rfl⟩ : ∃ q', q = q' + 1 := ⟨q - 1, by omega⟩
    simp only [Nat.add_sub_cancel]
    ring_nf; omega
  rw [e, pow_add, pow_mul', ZMod.pow_card_sub_one_eq_one ha, one_pow, mul_one]

/-- **The Euler-gap collapse.** If `(p - 1) ∣ (q - 1)` then `a^{pq-1} = 1` for every unit
`a` of `ZMod p`. -/
theorem euler_gap_collapse (p q : ℕ) [Fact p.Prime] (hq : 1 ≤ q) (hdiv : (p - 1) ∣ (q - 1))
    (a : ZMod p) (ha : a ≠ 0) : a ^ (p * q - 1) = 1 := by
  rw [euler_exponent_reduction p q hq a ha]
  obtain ⟨k, hk⟩ := hdiv
  rw [hk, pow_mul, ZMod.pow_card_sub_one_eq_one ha, one_pow]

/-- **The structured split.** For distinct primes `p, q` with `(p - 1) ∣ (q - 1)` and a base
`x` coprime to `p` with `q ∤ x^{pq-1} - 1`, the Fermat-test gcd reveals `p`:
`gcd(x^{pq-1} - 1, pq) = p`. -/
theorem euler_gap_gcd_split (p q x : ℕ) [hp : Fact p.Prime] (hq : q.Prime)
    (hdiv : (p - 1) ∣ (q - 1)) (hx : ¬ p ∣ x) (hqx : ¬ q ∣ x ^ (p * q - 1) - 1) :
    Nat.gcd (x ^ (p * q - 1) - 1) (p * q) = p := by
  have hx0 : (x : ZMod p) ≠ 0 := by
    rwa [Ne, ZMod.natCast_eq_zero_iff]
  have hcol := euler_gap_collapse p q hq.one_le hdiv (x : ZMod p) hx0
  have hpos : 1 ≤ x ^ (p * q - 1) := by
    rcases Nat.eq_zero_or_pos x with h | h
    · subst h; exact absurd (dvd_zero p) hx
    · exact Nat.one_le_pow _ _ h
  have hpd : p ∣ x ^ (p * q - 1) - 1 := by
    rw [← ZMod.natCast_eq_zero_iff, Nat.cast_sub hpos]
    push_cast
    rw [hcol, sub_self]
  set g := Nat.gcd (x ^ (p * q - 1) - 1) (p * q)
  have hpg : p ∣ g := Nat.dvd_gcd hpd (dvd_mul_right p q)
  obtain ⟨k, hk⟩ := hpg
  have hgpq : g ∣ p * q := Nat.gcd_dvd_right _ _
  rw [hk] at hgpq
  have hkq : k ∣ q := (Nat.mul_dvd_mul_iff_left hp.out.pos).1 hgpq
  rcases (Nat.dvd_prime hq).1 hkq with h1 | hq'
  · rw [hk, h1, mul_one]
  · exfalso
    apply hqx
    have : q ∣ g := ⟨p, by rw [hk, hq', mul_comm]⟩
    exact this.trans (Nat.gcd_dvd_left _ _)

end Bridges.OrderFreeTriangle