/-
# Renormalized products of normalized Laurent series

**Conjecture C (closed).**  Let `K` be a field and work in the field of formal
Laurent series `LaurentSeries K = HahnSeries ℤ K`, with uniformizer `q = single 1 1`.

Call a Laurent series *normalized* when it has a **simple pole**, i.e.
`orderTop f = -1`.  For `m ≥ 1` the *renormalized product* of a family
`f : ℕ → LaurentSeries K` is `q ^ m * ∏_{i < m} f i`.

The results proved here:

* `orderTop_renormProd` — the renormalized product of `m` normalized series has
  `orderTop = 0` (pole orders add, the `q ^ m` exactly compensates).
* `renormalized_prod_iff_orderTop_zero` — conversely **every** series of
  `orderTop = 0` arises this way, for every `m ≥ 1`.  So the realizable set is
  *exactly* the order-`0` locus: the pole order is the only obstruction.
* `renormalized_prod_iff_orderTop_sub` — the same statement with an arbitrary
  renormalizing power `q ^ k`: the realizable set is exactly the locus
  `orderTop g = k - m`.
* `factorization_unique_of_m_eq_one` — for `m = 1` the factorization **is**
  unique (this corrects the naive reading of "never unique").
* `factorization_not_unique` — for `m ≥ 2` it is never unique, and in fact
* `setOfFactorizations_infinite` — the factorization set is infinite, for every
  field `K`, including `K = 𝔽₂` where scalar rescaling gives nothing.

The obstruction/uniqueness dichotomy is governed by the group of order-`0`
units: the fibre of the factorization map is a torsor under `(𝒪ˣ)^{m-1}`, which
is trivial exactly when `m = 1`.  Two further research cycles are included:

* Cycle 2 — `factorization_ratio_units` / `twist_family_mem_factorizationSet` make the torsor
  structure precise, and `generatingFunction_renormalizable` /
  `generatingFunction_not_renormalizable` transport the whole dichotomy to probability
  generating functions: a finitely supported law is renormalizably factorizable iff it charges
  the atom `0`.
* Cycle 3 — `poleProfile_realizable_iff` removes the "simple pole" hypothesis entirely: for any
  integer pole profile `d` and integer exponent `k`, the realizable set is exactly
  `{g : orderTop g = k + ∑ d i}`.  Only the *total* valuation obstructs.
-/
import Mathlib

namespace Catalog.Probability.RenormalizedFactorization

open HahnSeries Finset

variable {K : Type*} [Field K]

/-! ## The uniformizer -/

/-- The uniformizer `q` of the Laurent series field, i.e. the monomial of degree `1`. -/
noncomputable def q (K : Type*) [Field K] : LaurentSeries K := HahnSeries.single 1 1

@[simp] lemma orderTop_q : (q K).orderTop = ((1 : ℤ) : WithTop ℤ) := by
  simp [q, HahnSeries.orderTop_single (a := (1 : ℤ)) (r := (1 : K)) one_ne_zero]

lemma q_ne_zero : q K ≠ 0 := by
  intro h
  simpa [h] using (orderTop_q (K := K))

@[simp] lemma orderTop_q_pow (k : ℕ) : ((q K) ^ k).orderTop = ((k : ℤ) : WithTop ℤ) := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, HahnSeries.orderTop_mul, ih, orderTop_q, ← WithTop.coe_add]
      push_cast
      ring_nf

/-! ## Order arithmetic in `WithTop ℤ` -/

/-- If a nonzero series has finite order `k`, its inverse has order `-k`. -/
lemma orderTop_inv {a : LaurentSeries K} {k : ℤ} (h : a.orderTop = (k : WithTop ℤ)) :
    (a⁻¹).orderTop = ((-k : ℤ) : WithTop ℤ) := by
  have ha : a ≠ 0 := by
    intro h0
    rw [h0] at h
    simp at h
  have hmul : (a * a⁻¹).orderTop = (0 : WithTop ℤ) := by
    rw [mul_inv_cancel₀ ha]
    simp
  rw [HahnSeries.orderTop_mul, h] at hmul
  cases hx : (a⁻¹).orderTop with
  | top => rw [hx] at hmul; simp at hmul
  | coe j =>
      rw [hx, ← WithTop.coe_add] at hmul
      have : k + j = 0 := by exact_mod_cast hmul
      have : j = -k := by omega
      rw [this]

@[simp] lemma orderTop_q_inv : ((q K)⁻¹).orderTop = ((-1 : ℤ) : WithTop ℤ) :=
  orderTop_inv (by simp)

@[simp] lemma orderTop_q_inv_pow (k : ℕ) :
    (((q K)⁻¹) ^ k).orderTop = ((-(k : ℤ) : ℤ) : WithTop ℤ) := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, HahnSeries.orderTop_mul, ih, orderTop_q_inv, ← WithTop.coe_add]
      congr 1
      push_cast
      ring

/-! ## Normalized series -/

/-- A Laurent series is *normalized* when it has a simple pole, `orderTop = -1`. -/
def Normalized (f : LaurentSeries K) : Prop := f.orderTop = ((-1 : ℤ) : WithTop ℤ)

lemma Normalized.ne_zero {f : LaurentSeries K} (hf : Normalized f) : f ≠ 0 := by
  intro h
  have htop : ((-1 : ℤ) : WithTop ℤ) = ⊤ := by
    rw [← hf, h, HahnSeries.orderTop_zero]
  exact WithTop.coe_ne_top htop

lemma normalized_q_inv : Normalized ((q K)⁻¹) := orderTop_q_inv

/-- Multiplying a normalized series by a unit of order `0` keeps it normalized. -/
lemma Normalized.mul_unit {u f : LaurentSeries K} (hu : u.orderTop = (0 : WithTop ℤ))
    (hf : Normalized f) : Normalized (u * f) := by
  unfold Normalized at *
  rw [HahnSeries.orderTop_mul, hu, hf, zero_add]

/-- The renormalized product `q ^ k * ∏_{i < m} f i`. -/
noncomputable def renormProd (k m : ℕ) (f : ℕ → LaurentSeries K) : LaurentSeries K :=
  (q K) ^ k * ∏ i ∈ Finset.range m, f i

/-! ## Order of a product of normalized series -/

/-- A product of `m` normalized series has order exactly `-m`: pole orders add. -/
lemma orderTop_prod_normalized (m : ℕ) (f : ℕ → LaurentSeries K)
    (hf : ∀ i < m, Normalized (f i)) :
    (∏ i ∈ Finset.range m, f i).orderTop = ((-(m : ℤ) : ℤ) : WithTop ℤ) := by
  induction m with
  | zero => simp
  | succ n ih =>
      rw [Finset.prod_range_succ, HahnSeries.orderTop_mul, ih (fun i hi => hf i (by omega)),
        hf n (by omega), ← WithTop.coe_add]
      congr 1
      push_cast
      ring

/-- The renormalized product of `m` normalized series has order exactly `k - m`. -/
theorem orderTop_renormProd_gen (k m : ℕ) (f : ℕ → LaurentSeries K)
    (hf : ∀ i < m, Normalized (f i)) :
    (renormProd k m f).orderTop = (((k : ℤ) - m : ℤ) : WithTop ℤ) := by
  rw [renormProd, HahnSeries.orderTop_mul, orderTop_q_pow, orderTop_prod_normalized m f hf,
    ← WithTop.coe_add]
  congr 1

/-- With the critical renormalization `k = m`, the product lands exactly on order `0`. -/
theorem orderTop_renormProd (m : ℕ) (f : ℕ → LaurentSeries K)
    (hf : ∀ i < m, Normalized (f i)) : (renormProd m m f).orderTop = (0 : WithTop ℤ) := by
  simpa using orderTop_renormProd_gen m m f hf

/-! ## The canonical factorization -/

/-- The canonical family realizing `g`: put the whole series in the first slot. -/
noncomputable def canon (m : ℕ) (g : LaurentSeries K) : ℕ → LaurentSeries K :=
  fun i => if i = 0 then (q K)⁻¹ * g else if i < m then (q K)⁻¹ else 1

lemma canon_prod (m : ℕ) (g : LaurentSeries K) (hm : 1 ≤ m) :
    ∏ i ∈ Finset.range m, canon m g i = ((q K)⁻¹) ^ m * g := by
  obtain ⟨n, rfl⟩ : ∃ n, m = n + 1 := ⟨m - 1, by omega⟩
  rw [Finset.prod_range_succ']
  have h1 : ∀ i ∈ Finset.range n, canon (n + 1) g (i + 1) = (q K)⁻¹ := by
    intro i hi
    simp only [Finset.mem_range] at hi
    simp [canon, show i + 1 < n + 1 by omega]
  rw [Finset.prod_congr rfl h1, Finset.prod_const, Finset.card_range]
  have h0 : canon (n + 1) g 0 = (q K)⁻¹ * g := by simp [canon]
  rw [h0, pow_succ]
  ring

lemma canon_normalized (m : ℕ) {g : LaurentSeries K} (hg : g.orderTop = (0 : WithTop ℤ))
    (i : ℕ) (hi : i < m) : Normalized (canon m g i) := by
  by_cases h0 : i = 0
  · subst h0
    have h := Normalized.mul_unit hg (normalized_q_inv (K := K))
    rw [mul_comm] at h
    simpa [canon] using h
  · simpa [canon, h0, hi] using (normalized_q_inv (K := K))

lemma canon_tail (m : ℕ) (g : LaurentSeries K) {i : ℕ} (hi : m ≤ i) (hi0 : i ≠ 0) :
    canon m g i = 1 := by
  simp [canon, hi0, Nat.not_lt.mpr hi]

lemma renormProd_canon (m : ℕ) (g : LaurentSeries K) (hm : 1 ≤ m) :
    renormProd m m (canon m g) = g := by
  rw [renormProd, canon_prod m g hm, ← mul_assoc, ← mul_pow, mul_inv_cancel₀ (q_ne_zero (K := K)),
    one_pow, one_mul]

/-! ## Main theorem: the realizable set is exactly the order-zero locus -/

/-- **Conjecture C, main statement.**  For every `m ≥ 1`, a Laurent series is a renormalized
product `q ^ m * ∏_{i < m} f i` of `m` normalized series if and only if it has order `0`.
Thus the pole order is the *only* obstruction to such a factorization. -/
theorem renormalized_prod_iff_orderTop_zero (m : ℕ) (hm : 1 ≤ m) (g : LaurentSeries K) :
    (∃ f : ℕ → LaurentSeries K, (∀ i < m, Normalized (f i)) ∧ renormProd m m f = g) ↔
      g.orderTop = (0 : WithTop ℤ) := by
  constructor
  · rintro ⟨f, hf, rfl⟩
    exact orderTop_renormProd m f hf
  · intro hg
    exact ⟨canon m g, canon_normalized m hg, renormProd_canon m g hm⟩

/-- Set-level form of the main theorem. -/
theorem setOf_renormalized_prod_eq (m : ℕ) (hm : 1 ≤ m) :
    {g : LaurentSeries K | ∃ f : ℕ → LaurentSeries K,
        (∀ i < m, Normalized (f i)) ∧ renormProd m m f = g} =
      {g : LaurentSeries K | g.orderTop = (0 : WithTop ℤ)} := by
  ext g
  exact renormalized_prod_iff_orderTop_zero m hm g

/-- **Arbitrary renormalization exponent.**  For `m ≥ 1` and any `k`, the series realized as
`q ^ k * ∏_{i < m} f i` with all `f i` normalized are exactly those of order `k - m`. -/
theorem renormalized_prod_iff_orderTop_sub (k m : ℕ) (hm : 1 ≤ m) (g : LaurentSeries K) :
    (∃ f : ℕ → LaurentSeries K, (∀ i < m, Normalized (f i)) ∧ renormProd k m f = g) ↔
      g.orderTop = (((k : ℤ) - m : ℤ) : WithTop ℤ) := by
  constructor
  · rintro ⟨f, hf, rfl⟩
    exact orderTop_renormProd_gen k m f hf
  · intro hg
    -- rescale the canonical family by `q ^ (m - k)` resp. `q ^ (k - m)`
    refine ⟨canon m ((q K) ^ m * (q K)⁻¹ ^ k * g), ?_, ?_⟩
    · refine canon_normalized m ?_
      rw [HahnSeries.orderTop_mul, HahnSeries.orderTop_mul, orderTop_q_pow, hg,
        orderTop_q_inv_pow, ← WithTop.coe_add, ← WithTop.coe_add]
      rw [show ((m : ℤ) + -(k : ℤ) + ((k : ℤ) - (m : ℤ))) = 0 from by ring]
      rfl
    · rw [renormProd, canon_prod m _ hm]
      have hc : ∀ j : ℕ, ((q K) ^ j * ((q K)⁻¹) ^ j : LaurentSeries K) = 1 := by
        intro j
        rw [← mul_pow, mul_inv_cancel₀ (q_ne_zero (K := K)), one_pow]
      have hrw : (q K) ^ k * (((q K)⁻¹) ^ m * ((q K) ^ m * ((q K)⁻¹) ^ k * g))
          = ((q K) ^ k * ((q K)⁻¹) ^ k) * ((q K) ^ m * ((q K)⁻¹) ^ m) * g := by ring
      rw [hrw, hc, hc, one_mul, one_mul]

/-! ## Uniqueness for `m = 1`, and its failure for `m ≥ 2` -/

/-- For `m = 1` the factorization **is** unique: the single factor is forced to be `q⁻¹ g`.
This is the sharp boundary of the non-uniqueness phenomenon. -/
theorem factorization_unique_of_m_eq_one (g : LaurentSeries K) (f f' : ℕ → LaurentSeries K)
    (h : renormProd 1 1 f = g) (h' : renormProd 1 1 f' = g) : f 0 = f' 0 := by
  simp only [renormProd, pow_one, Finset.prod_range_one] at h h'
  have := h.trans h'.symm
  exact mul_left_cancel₀ (q_ne_zero (K := K)) this

/-- The twist of a family by a unit `u`: multiply slot `0` by `u` and slot `1` by `u⁻¹`. -/
noncomputable def twist (u : LaurentSeries K) (f : ℕ → LaurentSeries K) : ℕ → LaurentSeries K :=
  fun i => if i = 0 then u * f 0 else if i = 1 then u⁻¹ * f 1 else f i

lemma prod_range_split_two (n : ℕ) (h : ℕ → LaurentSeries K) :
    ∏ i ∈ Finset.range (n + 2), h i
      = (∏ i ∈ Finset.range n, h (i + 1 + 1)) * h (0 + 1) * h 0 := by
  rw [Finset.prod_range_succ', Finset.prod_range_succ']

lemma prod_twist (m : ℕ) (hm : 2 ≤ m) (u : LaurentSeries K) (hu : u ≠ 0)
    (f : ℕ → LaurentSeries K) :
    ∏ i ∈ Finset.range m, twist u f i = ∏ i ∈ Finset.range m, f i := by
  obtain ⟨n, rfl⟩ : ∃ n, m = n + 2 := ⟨m - 2, by omega⟩
  rw [prod_range_split_two, prod_range_split_two]
  have h1 : ∀ i ∈ Finset.range n, twist u f (i + 1 + 1) = f (i + 1 + 1) := by
    intro i _
    simp [twist]
  rw [Finset.prod_congr rfl h1]
  simp only [twist]
  norm_num
  field_simp

lemma twist_normalized {u : LaurentSeries K} (hu : u.orderTop = (0 : WithTop ℤ))
    (huinv : (u⁻¹).orderTop = (0 : WithTop ℤ)) (m : ℕ) (f : ℕ → LaurentSeries K)
    (hf : ∀ i < m, Normalized (f i)) : ∀ i < m, Normalized (twist u f i) := by
  intro i hi
  by_cases h0 : i = 0
  · subst h0
    simpa [twist] using Normalized.mul_unit hu (hf 0 (by omega))
  · by_cases h1 : i = 1
    · subst h1
      simpa [twist, h0] using Normalized.mul_unit huinv (hf 1 (by omega))
    · simpa [twist, h0, h1] using hf i hi

/-- The distinguished unit `1 + q ^ (n+1)`, of order `0`, used to twist factorizations. -/
noncomputable def unitAt (K : Type*) [Field K] (n : ℕ) : LaurentSeries K := 1 + (q K) ^ (n + 1)

lemma orderTop_unitAt (n : ℕ) : (unitAt K n).orderTop = (0 : WithTop ℤ) := by
  rw [unitAt, HahnSeries.orderTop_add_eq_left]
  · simp
  · rw [orderTop_q_pow]
    simp only [HahnSeries.orderTop_one]
    exact_mod_cast Int.natCast_pos.mpr (Nat.succ_pos n)

lemma unitAt_ne_zero (n : ℕ) : unitAt K n ≠ 0 := by
  intro h
  have := orderTop_unitAt (K := K) n
  rw [h] at this
  simp at this

lemma orderTop_unitAt_inv (n : ℕ) : ((unitAt K n)⁻¹).orderTop = (0 : WithTop ℤ) := by
  simpa using orderTop_inv (a := unitAt K n) (k := 0) (by simpa using orderTop_unitAt (K := K) n)

lemma unitAt_injective : Function.Injective (unitAt K) := by
  intro a b hab
  by_contra hne
  have hq : (q K) ^ (a + 1) = (q K) ^ (b + 1) := by
    have := hab
    unfold unitAt at this
    exact add_left_cancel this
  have : ((a : ℤ) + 1 : ℤ) = ((b : ℤ) + 1 : ℤ) := by
    have h1 := orderTop_q_pow (K := K) (a + 1)
    have h2 := orderTop_q_pow (K := K) (b + 1)
    rw [hq, h2] at h1
    have : ((b + 1 : ℕ) : ℤ) = ((a + 1 : ℕ) : ℤ) := by exact_mod_cast h1
    push_cast at this ⊢
    omega
  exact hne (by omega)

/-- **Non-uniqueness.**  For every `m ≥ 2` and every realizable target `g`, there are two
genuinely different normalized factorizations of `g`.  (For `m = 1` this fails, by
`factorization_unique_of_m_eq_one`.) -/
theorem factorization_not_unique (m : ℕ) (hm : 2 ≤ m) (g : LaurentSeries K)
    (hg : g.orderTop = (0 : WithTop ℤ)) :
    ∃ f f' : ℕ → LaurentSeries K,
      (∀ i < m, Normalized (f i)) ∧ renormProd m m f = g ∧
      (∀ i < m, Normalized (f' i)) ∧ renormProd m m f' = g ∧
      ∃ i < m, f i ≠ f' i := by
  refine ⟨canon m g, twist (unitAt K 0) (canon m g), canon_normalized m hg,
    renormProd_canon m g (by omega),
    twist_normalized (orderTop_unitAt 0) (orderTop_unitAt_inv 0) m _ (canon_normalized m hg),
    ?_, 0, by omega, ?_⟩
  · rw [renormProd, prod_twist m hm _ (unitAt_ne_zero 0), ← renormProd, renormProd_canon m g
      (by omega)]
  · have e0 : twist (unitAt K 0) (canon m g) 0 = unitAt K 0 * canon m g 0 := by simp [twist]
    rw [e0]
    intro hcon
    have hne : canon m g 0 ≠ 0 := (canon_normalized m hg 0 (by omega)).ne_zero
    have hcan : unitAt K 0 * canon m g 0 = 1 * canon m g 0 := by rw [one_mul, ← hcon]
    have hu1 : unitAt K 0 = 1 := mul_right_cancel₀ hne hcan
    have hz : ((q K) ^ (0 + 1) : LaurentSeries K) = 0 := by
      have h2 : (1 : LaurentSeries K) + (q K) ^ (0 + 1) = 1 + 0 := by
        rw [add_zero]
        exact hu1
      exact add_left_cancel h2
    exact (pow_ne_zero _ (q_ne_zero (K := K))) hz

/-! ## The factorization set is infinite for `m ≥ 2` -/

/-- Normalized factorizations of `g` into `m` factors, normalized off the window by `1`. -/
def factorizationSet (m : ℕ) (g : LaurentSeries K) : Set (ℕ → LaurentSeries K) :=
  {f | (∀ i < m, Normalized (f i)) ∧ (∀ i, m ≤ i → f i = 1) ∧ renormProd m m f = g}

lemma canon_mem_factorizationSet (m : ℕ) (hm : 1 ≤ m) {g : LaurentSeries K}
    (hg : g.orderTop = (0 : WithTop ℤ)) : canon m g ∈ factorizationSet m g :=
  ⟨canon_normalized m hg, fun i hi => canon_tail m g hi (by omega), renormProd_canon m g hm⟩

/-- **Massive non-uniqueness.**  For `m ≥ 2` the set of normalized factorizations of any
order-`0` series is infinite — over *every* field, including `𝔽₂`, where no scalar rescaling
is available: the twisting units `1 + q^{n+1}` already produce infinitely many. -/
theorem setOfFactorizations_infinite (m : ℕ) (hm : 2 ≤ m) (g : LaurentSeries K)
    (hg : g.orderTop = (0 : WithTop ℤ)) : (factorizationSet m g).Infinite := by
  have hmem : ∀ n : ℕ, twist (unitAt K n) (canon m g) ∈ factorizationSet m g := by
    intro n
    refine ⟨twist_normalized (orderTop_unitAt n) (orderTop_unitAt_inv n) m _
      (canon_normalized m hg), ?_, ?_⟩
    · intro i hi
      have h0 : i ≠ 0 := by omega
      have h1 : i ≠ 1 := by omega
      simp only [twist, if_neg h0, if_neg h1]
      exact canon_tail m g hi h0
    · rw [renormProd, prod_twist m hm _ (unitAt_ne_zero n), ← renormProd,
        renormProd_canon m g (by omega)]
  have hinj : Function.Injective (fun n : ℕ => twist (unitAt K n) (canon m g)) := by
    intro a b hab
    have h0 : unitAt K a * canon m g 0 = unitAt K b * canon m g 0 := by
      have := congrFun hab 0
      simpa [twist] using this
    have hne : canon m g 0 ≠ 0 := (canon_normalized m hg 0 (by omega)).ne_zero
    exact unitAt_injective (mul_right_cancel₀ hne h0)
  exact Set.infinite_of_injective_forall_mem hinj hmem



/-! ## Cycle 2, part I: the fibre of the factorization map is a torsor

The order-`0` locus `OrdZero K` is exactly the unit group of the valuation ring, and the set of
normalized factorizations of a fixed `g` is a torsor under the subgroup of `(OrdZero K)^m` cut
out by "product `= 1`".  This explains *why* `m = 1` is rigid and `m ≥ 2` is not: for `m = 1`
that subgroup is trivial. -/

/-- The order-`0` locus of the Laurent series field (units of the valuation ring). -/
def OrdZero (K : Type*) [Field K] : Set (LaurentSeries K) :=
  {g | g.orderTop = (0 : WithTop ℤ)}

lemma one_mem_ordZero : (1 : LaurentSeries K) ∈ OrdZero K := by
  simp [OrdZero]

lemma mul_mem_ordZero {a b : LaurentSeries K} (ha : a ∈ OrdZero K) (hb : b ∈ OrdZero K) :
    a * b ∈ OrdZero K := by
  simp only [OrdZero, Set.mem_setOf_eq] at *
  rw [HahnSeries.orderTop_mul, ha, hb, add_zero]

lemma inv_mem_ordZero {a : LaurentSeries K} (ha : a ∈ OrdZero K) : a⁻¹ ∈ OrdZero K := by
  simp only [OrdZero, Set.mem_setOf_eq] at *
  simpa using orderTop_inv (a := a) (k := 0) (by simpa using ha)

lemma ordZero_ne_zero {a : LaurentSeries K} (ha : a ∈ OrdZero K) : a ≠ 0 := by
  intro h
  have : ((0 : ℤ) : WithTop ℤ) = ⊤ := by
    simpa [h] using ha.symm
  exact WithTop.coe_ne_top this

lemma prod_ne_zero_of_normalized (m : ℕ) (f : ℕ → LaurentSeries K)
    (hf : ∀ i < m, Normalized (f i)) : ∏ i ∈ Finset.range m, f i ≠ 0 := by
  rw [Finset.prod_ne_zero_iff]
  intro i hi
  exact (hf i (Finset.mem_range.mp hi)).ne_zero

/-- **Fibre ⊆ torsor.**  Two normalized factorizations of the same `g` differ slotwise by
order-`0` units whose product is `1`. -/
theorem factorization_ratio_units (m : ℕ) (g : LaurentSeries K) {f f' : ℕ → LaurentSeries K}
    (hf : f ∈ factorizationSet m g) (hf' : f' ∈ factorizationSet m g) :
    (∀ i < m, f' i / f i ∈ OrdZero K) ∧ ∏ i ∈ Finset.range m, (f' i / f i) = 1 := by
  obtain ⟨hfn, -, hfp⟩ := hf
  obtain ⟨hfn', -, hfp'⟩ := hf'
  constructor
  · intro i hi
    have h1 : (f i)⁻¹.orderTop = ((1 : ℤ) : WithTop ℤ) := by
      simpa using orderTop_inv (a := f i) (k := -1) (hfn i hi)
    simp only [OrdZero, Set.mem_setOf_eq, div_eq_mul_inv]
    rw [HahnSeries.orderTop_mul, hfn' i hi, h1, ← WithTop.coe_add]
    norm_num
  · have hprod : ∏ i ∈ Finset.range m, f i = ∏ i ∈ Finset.range m, f' i := by
      rw [renormProd] at hfp hfp'
      exact mul_left_cancel₀ (pow_ne_zero m (q_ne_zero (K := K))) (hfp.trans hfp'.symm)
    rw [Finset.prod_div_distrib, ← hprod, div_self (prod_ne_zero_of_normalized m f hfn)]

/-- **Torsor ⊆ fibre.**  Twisting a normalized factorization slotwise by order-`0` units whose
product is `1` produces another normalized factorization of the same `g`. -/
theorem twist_family_mem_factorizationSet (m : ℕ) (g : LaurentSeries K)
    {f : ℕ → LaurentSeries K} (hf : f ∈ factorizationSet m g) (u : ℕ → LaurentSeries K)
    (hu : ∀ i < m, u i ∈ OrdZero K) (hu1 : ∏ i ∈ Finset.range m, u i = 1) :
    (fun i => if i < m then u i * f i else 1) ∈ factorizationSet m g := by
  obtain ⟨hfn, -, hfp⟩ := hf
  refine ⟨?_, ?_, ?_⟩
  · intro i hi
    simpa [hi] using Normalized.mul_unit (hu i hi) (hfn i hi)
  · intro i hi
    simp [Nat.not_lt.mpr hi]
  · have hcongr : ∀ i ∈ Finset.range m, (if i < m then u i * f i else 1) = u i * f i := by
      intro i hi
      simp [Finset.mem_range.mp hi]
    rw [renormProd, Finset.prod_congr rfl hcongr, Finset.prod_mul_distrib, hu1, one_mul,
      ← renormProd, hfp]

/-! ## Cycle 2, part II: probability generating functions

A finitely supported weight sequence `c : ℕ → K` (for `K = ℝ`, the law of an `ℕ`-valued random
variable) has generating function `∑_{n < N} c n q^n`.  Its pole order is `0` precisely when the
atom at `0` is charged, and that is exactly the condition for the renormalized factorization to
exist. -/

/-- The generating function `∑_{n < N} c n · q ^ n`, as a Laurent series. -/
noncomputable def coeffSeries (c : ℕ → K) (N : ℕ) : LaurentSeries K :=
  ∑ n ∈ Finset.range N, HahnSeries.single (n : ℤ) (c n)

lemma le_orderTop_sum {ι : Type*} (s : Finset ι) (F : ι → LaurentSeries K) (b : WithTop ℤ)
    (h : ∀ i ∈ s, b ≤ (F i).orderTop) : b ≤ (∑ i ∈ s, F i).orderTop := by
  classical
  induction s using Finset.cons_induction with
  | empty => simp
  | cons a s ha ih =>
      rw [Finset.sum_cons]
      refine le_trans (le_min (h a (by simp)) (ih fun i hi => h i (by simp [hi]))) ?_
      exact HahnSeries.min_orderTop_le_orderTop_add

/-- The shifted part of a generating function has strictly positive order. -/
lemma orderTop_shifted_pos (c : ℕ → K) (n0 : ℕ) :
    (0 : WithTop ℤ) <
      (∑ i ∈ Finset.range n0, HahnSeries.single ((i + 1 : ℕ) : ℤ) (c (i + 1))).orderTop := by
  have hb : ((1 : ℤ) : WithTop ℤ) ≤
      (∑ i ∈ Finset.range n0, HahnSeries.single ((i + 1 : ℕ) : ℤ) (c (i + 1))).orderTop := by
    refine le_orderTop_sum _ _ _ ?_
    intro i _
    by_cases hci : c (i + 1) = 0
    · simp [hci]
    · rw [HahnSeries.orderTop_single hci]
      exact_mod_cast (by omega : (1 : ℤ) ≤ ((i + 1 : ℕ) : ℤ))
  refine lt_of_lt_of_le ?_ hb
  exact_mod_cast (by norm_num : (0 : ℤ) < 1)

/-- **Order-zero criterion for generating functions.**  If the mass at `0` is nonzero, the
generating function sits exactly on the order-`0` locus. -/
theorem orderTop_coeffSeries_eq_zero (c : ℕ → K) (N : ℕ) (hN : 1 ≤ N) (h0 : c 0 ≠ 0) :
    (coeffSeries c N).orderTop = (0 : WithTop ℤ) := by
  obtain ⟨n0, rfl⟩ : ∃ n0, N = n0 + 1 := ⟨N - 1, by omega⟩
  rw [coeffSeries, Finset.sum_range_succ', HahnSeries.orderTop_add_eq_right]
  · simpa using HahnSeries.orderTop_single (a := ((0 : ℕ) : ℤ)) h0
  · rw [show (HahnSeries.single (((0 : ℕ) : ℤ)) (c 0)).orderTop = (0 : WithTop ℤ) by
      simpa using HahnSeries.orderTop_single (a := ((0 : ℕ) : ℤ)) h0]
    exact orderTop_shifted_pos c n0

/-- If the mass at `0` vanishes, the generating function has strictly positive order (possibly
`⊤`, when it is the zero series). -/
theorem orderTop_coeffSeries_pos_of_zero_mass (c : ℕ → K) (N : ℕ) (h0 : c 0 = 0) :
    (0 : WithTop ℤ) < (coeffSeries c N).orderTop := by
  cases N with
  | zero => simp [coeffSeries]
  | succ n0 =>
      rw [coeffSeries, Finset.sum_range_succ']
      simpa [h0] using orderTop_shifted_pos c n0

/-- **Probability bridge (existence).**  The generating function of a finitely supported weight
sequence charging `0` factors, for every `m ≥ 1`, as `q ^ m` times `m` normalized series. -/
theorem generatingFunction_renormalizable (c : ℕ → K) (N m : ℕ) (hN : 1 ≤ N) (hm : 1 ≤ m)
    (h0 : c 0 ≠ 0) :
    ∃ f : ℕ → LaurentSeries K,
      (∀ i < m, Normalized (f i)) ∧ renormProd m m f = coeffSeries c N :=
  (renormalized_prod_iff_orderTop_zero m hm _).2 (orderTop_coeffSeries_eq_zero c N hN h0)

/-- **Probability bridge (obstruction).**  If the atom at `0` is uncharged, no such factorization
can exist: the pole order obstruction is genuinely visible on generating functions. -/
theorem generatingFunction_not_renormalizable (c : ℕ → K) (N m : ℕ) (hm : 1 ≤ m) (h0 : c 0 = 0) :
    ¬ ∃ f : ℕ → LaurentSeries K,
      (∀ i < m, Normalized (f i)) ∧ renormProd m m f = coeffSeries c N := by
  intro h
  have hz := (renormalized_prod_iff_orderTop_zero m hm _).1 h
  have hpos := orderTop_coeffSeries_pos_of_zero_mass c N h0
  rw [hz] at hpos
  exact lt_irrefl _ hpos

/-- **Probability corollary.**  For a real weight sequence with positive mass at `0` (e.g. the law
of an `ℕ`-valued random variable with `P(X = 0) > 0`), the generating function admits infinitely
many normalized factorizations as soon as `m ≥ 2`. -/
theorem realGeneratingFunction_factorizations_infinite (p : ℕ → ℝ) (N m : ℕ) (hN : 1 ≤ N)
    (hm : 2 ≤ m) (hp0 : 0 < p 0) :
    (factorizationSet m (coeffSeries p N)).Infinite :=
  setOfFactorizations_infinite m hm _ (orderTop_coeffSeries_eq_zero p N hN (ne_of_gt hp0))



/-! ## Cycle 3: arbitrary pole profiles — only the total valuation obstructs

Dropping the requirement that every factor have a *simple* pole, we allow an arbitrary integer
profile `d : ℕ → ℤ` of pole orders and an arbitrary integer renormalization exponent `k`.  The
realizable set is then exactly the locus `orderTop g = k + ∑_{i<m} d i`: the individual pole
orders are pure gauge, only their sum is an obstruction. -/

lemma orderTop_q_zpow (k : ℤ) : ((q K) ^ k).orderTop = ((k : ℤ) : WithTop ℤ) := by
  cases k with
  | ofNat n =>
      rw [Int.ofNat_eq_natCast, zpow_natCast]
      simp [orderTop_q_pow (K := K) n]
  | negSucc n =>
      rw [zpow_negSucc]
      have h := orderTop_q_pow (K := K) (n + 1)
      have := orderTop_inv (a := (q K) ^ (n + 1)) (k := ((n + 1 : ℕ) : ℤ)) h
      rw [this]
      norm_cast

lemma prod_q_zpow (s : Finset ℕ) (e : ℕ → ℤ) :
    ∏ i ∈ s, (q K) ^ (e i) = (q K) ^ (∑ i ∈ s, e i) := by
  classical
  induction s using Finset.cons_induction with
  | empty => simp
  | cons a s ha ih =>
      rw [Finset.prod_cons, Finset.sum_cons, ih, zpow_add₀ (q_ne_zero (K := K))]

/-- The renormalized product with an integer renormalization exponent. -/
noncomputable def renormProdZ (k : ℤ) (m : ℕ) (f : ℕ → LaurentSeries K) : LaurentSeries K :=
  (q K) ^ k * ∏ i ∈ Finset.range m, f i

/-- `f` has pole profile `d` on the window `[0, m)`. -/
def HasPoleProfile (m : ℕ) (d : ℕ → ℤ) (f : ℕ → LaurentSeries K) : Prop :=
  ∀ i < m, (f i).orderTop = ((d i : ℤ) : WithTop ℤ)

lemma orderTop_prod_profile (m : ℕ) (d : ℕ → ℤ) (f : ℕ → LaurentSeries K)
    (hf : HasPoleProfile m d f) :
    (∏ i ∈ Finset.range m, f i).orderTop = ((∑ i ∈ Finset.range m, d i : ℤ) : WithTop ℤ) := by
  induction m with
  | zero => simp
  | succ n ih =>
      rw [Finset.prod_range_succ, HahnSeries.orderTop_mul, ih (fun i hi => hf i (by omega)),
        hf n (by omega), ← WithTop.coe_add, Finset.sum_range_succ]

/-- **Pole profiles: total valuation is the only obstruction.**  For `m ≥ 1`, any integer
renormalization exponent `k` and any profile `d`, the series of the form `q ^ k * ∏_{i<m} f i`
with `orderTop (f i) = d i` are exactly those with `orderTop g = k + ∑_{i<m} d i`. -/
theorem poleProfile_realizable_iff (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ)
    (g : LaurentSeries K) :
    (∃ f : ℕ → LaurentSeries K, HasPoleProfile m d f ∧ renormProdZ k m f = g) ↔
      g.orderTop = ((k + ∑ i ∈ Finset.range m, d i : ℤ) : WithTop ℤ) := by
  have hq : q K ≠ (0 : LaurentSeries K) := q_ne_zero
  constructor
  · rintro ⟨f, hf, rfl⟩
    rw [renormProdZ, HahnSeries.orderTop_mul, orderTop_q_zpow, orderTop_prod_profile m d f hf,
      ← WithTop.coe_add]
  · intro hg
    obtain ⟨n, rfl⟩ : ∃ n, m = n + 1 := ⟨m - 1, by omega⟩
    set S : ℤ := ∑ i ∈ Finset.range (n + 1), d i with hS
    refine ⟨fun i => if i = 0 then (q K) ^ (d 0) * ((q K) ^ (-(k + S)) * g)
      else (q K) ^ (d i), ?_, ?_⟩
    · intro i hi
      by_cases h0 : i = 0
      · subst h0
        have hu : ((q K) ^ (-(k + S)) * g).orderTop = (0 : WithTop ℤ) := by
          rw [HahnSeries.orderTop_mul, orderTop_q_zpow, hg, ← WithTop.coe_add,
            show -(k + S) + (k + S) = 0 from by ring]
          rfl
        show ((q K) ^ (d 0) * ((q K) ^ (-(k + S)) * g)).orderTop = ((d 0 : ℤ) : WithTop ℤ)
        rw [HahnSeries.orderTop_mul, orderTop_q_zpow, hu, add_zero]
      · simp only [if_neg h0]
        exact orderTop_q_zpow (d i)
    · rw [renormProdZ, Finset.prod_range_succ']
      have h1 : ∀ i ∈ Finset.range n,
          (if i + 1 = 0 then (q K) ^ (d 0) * ((q K) ^ (-(k + S)) * g)
            else (q K) ^ (d (i + 1))) = (q K) ^ (d (i + 1)) := by
        intro i _
        simp
      rw [Finset.prod_congr rfl h1, prod_q_zpow, if_pos (rfl : (0 : ℕ) = 0)]
      simp only [← mul_assoc, ← zpow_add₀ hq]
      rw [show k + ((∑ i ∈ Finset.range n, d (i + 1)) + (d 0 + -(k + S))) = 0 from by
        rw [hS, Finset.sum_range_succ']
        ring]
      rw [zpow_zero, one_mul]

/-- The classical statement is the constant profile `d ≡ -1` with `k = m`: the realizable set is
the order-`0` locus. -/
theorem poleProfile_simplePole_eq_orderTop_zero (m : ℕ) (hm : 1 ≤ m) (g : LaurentSeries K) :
    (∃ f : ℕ → LaurentSeries K, HasPoleProfile m (fun _ => (-1 : ℤ)) f ∧
        renormProdZ (m : ℤ) m f = g) ↔ g.orderTop = (0 : WithTop ℤ) := by
  rw [poleProfile_realizable_iff (m : ℤ) m hm _ g]
  simp

/-!
## Lab Notes (experimental data behind the theorems)

Exhaustive enumeration over truncations `mod q^D` (see `ComputationalEvidence.md`):

* `K = 𝔽₂`, target `g = 1`, `m = 2`: the number of normalized factorizations mod `q^D` is
  `1, 2, 4, 8, 16, 32` for `D = 1,…,6`, i.e. `2^{D-1} = #(𝒪/q^D)ˣ`.
* `K = 𝔽₃`, same experiment: `2, 6, 18` for `D = 1,2,3`, i.e. `(p-1)p^{D-1}`.
  Both match the torsor description proved in `factorization_ratio_units` /
  `twist_family_mem_factorizationSet`, and their unbounded growth is the finite shadow of
  `setOfFactorizations_infinite`.
* `K = 𝔽₂`, `m = 1`: exactly one factorization at every truncation — the datum that falsified
  the naive "never unique" reading and led to `factorization_unique_of_m_eq_one`.
* `K = 𝔽₂`, image sweep for `m = 1,2,3` and `D ≤ 4`: the image of the renormalized product map
  is exactly the set of truncations of `orderTop`-`0` series, independent of `m`
  (`renormalized_prod_iff_orderTop_zero`).
-/

end Catalog.Probability.RenormalizedFactorization