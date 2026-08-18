/-
# Renormalized factorization over an arbitrary discretely valued group (Cycle 4)

This file closes two of the open conjectures listed in `FUTURE_DIRECTIONS.md` for the
Conjecture-C thread of `Catalog/Probability/RenormalizedNormalizedFactorization.lean`:

* **C4 (transfer to other valued fields).**  Nothing in the Laurent-series proof uses the
  coefficientwise structure of `LaurentSeries K`.  All that is needed is a commutative group
  `G` (the group of units of the field), a homomorphism `val : G → ℤ`, and a uniformizer
  `π` with `val π = 1`.  This is packaged as `DiscreteVal G`.  In this generality:
  `realizable_iff` — for every `m ≥ 1`, every integer exponent `k` and every pole profile
  `d`, the set of `π ^ k * ∏_{i < m} f i` with `val (f i) = d i` is exactly the level set
  `{g | val g = k + ∑_{i<m} d i}`.
* **C1 (rigidity index).**  The fibre of the renormalized-product map over a realizable `g`
  is a torsor under the group of "twists" (`fibreEquivTwist`), and that twist group is in
  bijection with `Fin (m-1)` copies of the valuation-zero subgroup (`twistEquivPi`).  Hence
  `card_factorizations`: the fibre has exactly `#{u | val u = 0} ^ (m-1)` elements — the
  rigidity index is `m - 1`, so the fibre is a singleton **iff** `m = 1`
  (`rigidity_dichotomy`).

The two instantiations proved at the end are genuinely different worlds:

* `laurentVal K` — the Laurent series field `LaurentSeries K` over any field `K`, recovering
  the results of the companion file;
* `padicVal p` — the `p`-adic numbers `ℚ_[p]`, where the same dichotomy is new.

No `sorry`, no `native_decide`, no new axioms.
-/
import Mathlib

namespace Catalog.Probability.RenormalizedFactorizationValuation

open Finset

variable {G : Type*} [CommGroup G]

/-! ## The abstract setting: a `ℤ`-valued valuation with a uniformizer -/

/-- A `ℤ`-valued *discrete valuation datum* on a commutative group `G`: a homomorphism
`val : G → ℤ` together with a uniformizer of value `1` (so `val` is surjective).  For a
discretely valued field one takes `G = Fˣ`. -/
structure DiscreteVal (G : Type*) [CommGroup G] where
  /-- The valuation. -/
  val : G → ℤ
  /-- The valuation is a homomorphism. -/
  val_mul : ∀ a b, val (a * b) = val a + val b
  /-- A chosen element of valuation `1`. -/
  uniformizer : G
  /-- The uniformizer has valuation `1`. -/
  val_uniformizer : val uniformizer = 1

namespace DiscreteVal

variable (V : DiscreteVal G)

@[simp] lemma val_one : V.val 1 = 0 := by
  have := V.val_mul 1 1
  simp at this
  omega

@[simp] lemma val_inv (a : G) : V.val a⁻¹ = -V.val a := by
  have := V.val_mul a a⁻¹
  rw [mul_inv_cancel, V.val_one] at this
  omega

lemma val_div (a b : G) : V.val (a / b) = V.val a - V.val b := by
  rw [div_eq_mul_inv, V.val_mul, V.val_inv]; ring

lemma val_zpow (a : G) (n : ℤ) : V.val (a ^ n) = n * V.val a := by
  induction n using Int.induction_on with
  | zero => simp
  | succ k ih => rw [zpow_add_one, V.val_mul, ih]; ring
  | pred k ih => rw [zpow_sub_one, V.val_mul, ih, V.val_inv]; ring

@[simp] lemma val_uniformizer_zpow (n : ℤ) : V.val (V.uniformizer ^ n) = n := by
  rw [V.val_zpow, V.val_uniformizer]; ring

lemma val_prod {ι : Type*} (s : Finset ι) (f : ι → G) :
    V.val (∏ i ∈ s, f i) = ∑ i ∈ s, V.val (f i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih => rw [Finset.prod_insert ha, V.val_mul, ih, Finset.sum_insert ha]

lemma prod_uniformizer_zpow {ι : Type*} (s : Finset ι) (e : ι → ℤ) :
    ∏ i ∈ s, V.uniformizer ^ (e i) = V.uniformizer ^ (∑ i ∈ s, e i) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih => rw [Finset.prod_insert ha, ih, Finset.sum_insert ha, zpow_add]

/-! ## Renormalized products and their fibres -/

/-- The renormalized product `π ^ k * ∏_{i < m} f i`. -/
def renormProd (V : DiscreteVal G) (k : ℤ) (m : ℕ) (f : ℕ → G) : G :=
  V.uniformizer ^ k * ∏ i ∈ range m, f i

/-- `f` realizes the pole profile `d` on the window `[0, m)`, and is trivial outside it. -/
def HasProfile (V : DiscreteVal G) (m : ℕ) (d : ℕ → ℤ) (f : ℕ → G) : Prop :=
  (∀ i < m, V.val (f i) = d i) ∧ ∀ i, m ≤ i → f i = 1

/-- The fibre of the renormalized-product map: all profile-`d` families whose renormalized
product is `g`. -/
def factorizations (V : DiscreteVal G) (k : ℤ) (m : ℕ) (d : ℕ → ℤ) (g : G) : Set (ℕ → G) :=
  {f | HasProfile V m d f ∧ renormProd V k m f = g}

lemma val_renormProd {k : ℤ} {m : ℕ} {d : ℕ → ℤ} {f : ℕ → G} (hf : HasProfile V m d f) :
    V.val (renormProd V k m f) = k + ∑ i ∈ range m, d i := by
  rw [renormProd, V.val_mul, V.val_uniformizer_zpow, V.val_prod]
  congr 1
  exact Finset.sum_congr rfl fun i hi => hf.1 i (Finset.mem_range.mp hi)

/-- The canonical factorization: the slots `1, …, m-1` carry pure powers of the uniformizer
and slot `0` absorbs the whole discrepancy. -/
def canonFam (V : DiscreteVal G) (k : ℤ) (m : ℕ) (d : ℕ → ℤ) (g : G) : ℕ → G :=
  fun i => (if i = 0 then V.uniformizer ^ (-(k + ∑ j ∈ range m, d j)) * g else 1) *
      (if i < m then V.uniformizer ^ (d i) else 1)

lemma canonFam_hasProfile (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ) (g : G)
    (hg : V.val g = k + ∑ i ∈ range m, d i) : HasProfile V m d (canonFam V k m d g) := by
  constructor
  · intro i hi
    by_cases h0 : i = 0
    · subst h0
      have h : canonFam V k m d g 0
          = V.uniformizer ^ (-(k + ∑ j ∈ range m, d j)) * g * V.uniformizer ^ (d 0) := by
        simp [canonFam, hi]
      rw [h, V.val_mul, V.val_mul, V.val_uniformizer_zpow, V.val_uniformizer_zpow, hg]
      ring
    · simp [canonFam, h0, hi]
  · intro i hi
    have h0 : i ≠ 0 := by omega
    have h2 : ¬i < m := by omega
    simp [canonFam, h0, h2]

lemma canonFam_renormProd (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ) (g : G) :
    renormProd V k m (canonFam V k m d g) = g := by
  have h1 : ∏ i ∈ range m, canonFam V k m d g i
      = (∏ i ∈ range m, (if i = 0 then V.uniformizer ^ (-(k + ∑ j ∈ range m, d j)) * g else 1))
        * ∏ i ∈ range m, (if i < m then V.uniformizer ^ (d i) else 1) := by
    simp only [canonFam]
    rw [← Finset.prod_mul_distrib]
  have h2 : (∏ i ∈ range m, (if i = 0 then V.uniformizer ^ (-(k + ∑ j ∈ range m, d j)) * g else 1))
      = V.uniformizer ^ (-(k + ∑ j ∈ range m, d j)) * g := by
    rw [Finset.prod_eq_single 0]
    · rw [if_pos rfl]
    · intro b _ hb
      rw [if_neg hb]
    · intro h
      exact absurd (Finset.mem_range.mpr hm) h
  have h3 : (∏ i ∈ range m, (if i < m then V.uniformizer ^ (d i) else 1))
      = V.uniformizer ^ (∑ i ∈ range m, d i) := by
    rw [Finset.prod_congr rfl (fun i hi => by rw [if_pos (Finset.mem_range.mp hi)])]
    exact V.prod_uniformizer_zpow _ _
  rw [renormProd, h1, h2, h3]
  have hcomm : V.uniformizer ^ k * (V.uniformizer ^ (-(k + ∑ j ∈ range m, d j)) * g *
      V.uniformizer ^ (∑ i ∈ range m, d i))
      = (V.uniformizer ^ k * V.uniformizer ^ (-(k + ∑ j ∈ range m, d j)) *
        V.uniformizer ^ (∑ i ∈ range m, d i)) * g := by
    simp [mul_comm, mul_left_comm]
  rw [hcomm, ← zpow_add, ← zpow_add]
  simp

/-- **Realizability (abstract Conjecture C).**  For every `m ≥ 1`, every renormalizing exponent
`k` and every pole profile `d`, a group element is a renormalized product `π ^ k * ∏ f i` with
`val (f i) = d i` **iff** its valuation is `k + ∑ d i`.  The total valuation is the only
obstruction. -/
theorem realizable_iff (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ) (g : G) :
    (∃ f, f ∈ factorizations V k m d g) ↔ V.val g = k + ∑ i ∈ range m, d i := by
  constructor
  · rintro ⟨f, hf, hfg⟩
    rw [← hfg, V.val_renormProd hf]
  · intro hg
    exact ⟨canonFam V k m d g, V.canonFam_hasProfile k m hm d g hg,
      V.canonFam_renormProd k m hm d g⟩

/-- Set-level form of `realizable_iff`. -/
theorem setOf_renormProd_eq (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ) :
    {g : G | ∃ f, HasProfile V m d f ∧ renormProd V k m f = g}
      = {g : G | V.val g = k + ∑ i ∈ range m, d i} := by
  ext g
  exact V.realizable_iff k m hm d g

/-! ## The fibre is a torsor under the twist group -/

/-- The group of *twists*: families of valuation-`0` elements supported on `[0, m)` whose
product is `1`. -/
def twistGroup (V : DiscreteVal G) (m : ℕ) : Set (ℕ → G) :=
  {u | (∀ i < m, V.val (u i) = 0) ∧ (∀ i, m ≤ i → u i = 1) ∧ ∏ i ∈ range m, u i = 1}

/-- **Fibre = torsor.**  Once one factorization `f₀` of `g` is fixed, the whole fibre is in
bijection with the twist group, via `f ↦ f / f₀`. -/
def fibreEquivTwist (V : DiscreteVal G) (k : ℤ) (m : ℕ) (d : ℕ → ℤ) (g : G)
    (f₀ : ℕ → G) (hf₀ : f₀ ∈ factorizations V k m d g) :
    factorizations V k m d g ≃ twistGroup V m where
  toFun f := by
    refine ⟨fun i => (f : ℕ → G) i / f₀ i, ?_, ?_, ?_⟩
    · intro i hi
      show V.val ((f : ℕ → G) i / f₀ i) = 0
      rw [V.val_div, f.2.1.1 i hi, hf₀.1.1 i hi, sub_self]
    · intro i hi
      show (f : ℕ → G) i / f₀ i = 1
      rw [f.2.1.2 i hi, hf₀.1.2 i hi, div_self']
    · rw [Finset.prod_div_distrib]
      have h : V.uniformizer ^ k * ∏ i ∈ range m, (f : ℕ → G) i
          = V.uniformizer ^ k * ∏ i ∈ range m, f₀ i := by
        rw [← renormProd, ← renormProd, f.2.2, hf₀.2]
      rw [mul_left_cancel h, div_self']
  invFun u := by
    refine ⟨fun i => f₀ i * (u : ℕ → G) i, ⟨?_, ?_⟩, ?_⟩
    · intro i hi
      show V.val (f₀ i * (u : ℕ → G) i) = d i
      rw [V.val_mul, hf₀.1.1 i hi, u.2.1 i hi, add_zero]
    · intro i hi
      show f₀ i * (u : ℕ → G) i = 1
      rw [hf₀.1.2 i hi, u.2.2.1 i hi, mul_one]
    · rw [renormProd, Finset.prod_mul_distrib, u.2.2.2, mul_one, ← renormProd, hf₀.2]
  left_inv := by
    intro f
    apply Subtype.ext
    funext i
    simp
  right_inv := by
    intro u
    apply Subtype.ext
    funext i
    simp

/-! ## Rigidity: the fibre is a singleton exactly when `m = 1` -/

/-- For `m = 1` the factorization is unique: the single slot is forced. -/
theorem factorization_unique_of_m_eq_one (k : ℤ) (d : ℕ → ℤ) (g : G)
    {f f' : ℕ → G} (hf : f ∈ factorizations V k 1 d g) (hf' : f' ∈ factorizations V k 1 d g) :
    f = f' := by
  funext i
  rcases Nat.eq_zero_or_pos i with h0 | h0
  · subst h0
    have h : V.uniformizer ^ k * f 0 = V.uniformizer ^ k * f' 0 := by
      have h1 := hf.2
      have h2 := hf'.2
      rw [renormProd, Finset.prod_range_one] at h1 h2
      rw [h1, h2]
    exact mul_left_cancel h
  · rw [hf.1.2 i h0, hf'.1.2 i h0]

/-- The explicit twist supported on the two slots `0` and `1`. -/
def twoSlotTwist (u : G) : ℕ → G := fun i => if i = 0 then u else if i = 1 then u⁻¹ else 1

lemma twoSlotTwist_mem (m : ℕ) (hm : 2 ≤ m) {u : G} (hu : V.val u = 0) :
    twoSlotTwist u ∈ twistGroup V m := by
  refine ⟨?_, ?_, ?_⟩
  · intro i _
    by_cases h0 : i = 0
    · simp [twoSlotTwist, h0, hu]
    · by_cases h1 : i = 1 <;> simp [twoSlotTwist, h0, h1, hu]
  · intro i hi
    have h0 : i ≠ 0 := by omega
    have h1 : i ≠ 1 := by omega
    simp [twoSlotTwist, h0, h1]
  · have hsub : range 2 ⊆ range m := by
      intro x hx
      simp only [Finset.mem_range] at hx ⊢
      omega
    have h1 : ∏ i ∈ range 2, twoSlotTwist u i = ∏ i ∈ range m, twoSlotTwist u i := by
      refine Finset.prod_subset hsub ?_
      intro x _ hx
      have h0 : x ≠ 0 := by
        intro h; exact hx (by simp [h])
      have h1 : x ≠ 1 := by
        intro h; exact hx (by simp [h])
      simp [twoSlotTwist, h0, h1]
    rw [← h1]
    simp [twoSlotTwist, Finset.prod_range_succ]

/-- **Non-uniqueness for `m ≥ 2`.**  If the valuation-zero subgroup is nontrivial (which holds
in every discretely valued field, e.g. via `1 + π` or `-1`), then for `m ≥ 2` every realizable
target has at least two distinct factorizations. -/
theorem factorization_not_unique (k : ℤ) (m : ℕ) (hm : 2 ≤ m) (d : ℕ → ℤ) (g : G)
    {u : G} (hu : V.val u = 0) (hu1 : u ≠ 1)
    {f : ℕ → G} (hf : f ∈ factorizations V k m d g) :
    ∃ f' ∈ factorizations V k m d g, f' ≠ f := by
  have hm1 : 1 ≤ m := by omega
  set e := V.fibreEquivTwist k m d g f hf with he
  refine ⟨(e.symm ⟨twoSlotTwist u, V.twoSlotTwist_mem m hm hu⟩ : ℕ → G),
    (e.symm ⟨twoSlotTwist u, V.twoSlotTwist_mem m hm hu⟩).2, ?_⟩
  intro hcontra
  have h0 : f 0 * u = f 0 := by
    have : (e.symm ⟨twoSlotTwist u, V.twoSlotTwist_mem m hm hu⟩ : ℕ → G) 0 = f 0 * u := by
      simp [he, fibreEquivTwist, twoSlotTwist]
    rw [← this, hcontra]
  have h1 : f 0 * u = f 0 * 1 := by rw [mul_one]; exact h0
  exact hu1 (mul_left_cancel h1)

/-- **Rigidity dichotomy.**  Assuming the valuation-zero subgroup is nontrivial and the target
is realizable, the fibre of the renormalized-product map is a singleton **iff** `m = 1`. -/
theorem rigidity_dichotomy (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ) (g : G)
    (hg : V.val g = k + ∑ i ∈ range m, d i) {u : G} (hu : V.val u = 0) (hu1 : u ≠ 1) :
    (factorizations V k m d g).Subsingleton ↔ m = 1 := by
  constructor
  · intro hsub
    by_contra hm1
    have hm2 : 2 ≤ m := by omega
    obtain ⟨f, hf⟩ := (V.realizable_iff k m hm d g).mpr hg
    obtain ⟨f', hf', hne⟩ := V.factorization_not_unique k m hm2 d g hu hu1 hf
    exact hne (hsub hf' hf)
  · intro hm1
    subst hm1
    intro f hf f' hf'
    exact V.factorization_unique_of_m_eq_one k d g hf hf'

/-! ## The rigidity index: the fibre has `#{val = 0} ^ (m-1)` elements -/

/-- The twist family determined by `n` free valuation-zero elements: slot `i+1` carries the
`i`-th datum and slot `0` is forced to be the inverse of their product. -/
def piToFam (V : DiscreteVal G) (n : ℕ) (w : Fin n → {u : G // V.val u = 0}) : ℕ → G :=
  fun i => if i = 0 then (∏ j : Fin n, (w j : G))⁻¹
    else if h : i - 1 < n then (w ⟨i - 1, h⟩ : G) else 1

@[simp] lemma piToFam_zero (n : ℕ) (w : Fin n → {u : G // V.val u = 0}) :
    piToFam V n w 0 = (∏ j : Fin n, (w j : G))⁻¹ := by
  simp [piToFam]

lemma piToFam_succ (n : ℕ) (w : Fin n → {u : G // V.val u = 0}) (i : ℕ) :
    piToFam V n w (i + 1) = if h : i < n then (w ⟨i, h⟩ : G) else 1 := by
  simp [piToFam]

lemma val_prod_coe (n : ℕ) (w : Fin n → {u : G // V.val u = 0}) :
    V.val (∏ j : Fin n, (w j : G)) = 0 := by
  rw [V.val_prod]
  exact Finset.sum_eq_zero fun j _ => (w j).2

lemma piToFam_mem (n : ℕ) (w : Fin n → {u : G // V.val u = 0}) :
    piToFam V n w ∈ twistGroup V (n + 1) := by
  refine ⟨?_, ?_, ?_⟩
  · intro i _
    rcases Nat.eq_zero_or_pos i with h0 | h0
    · subst h0
      rw [piToFam_zero, V.val_inv, V.val_prod_coe, neg_zero]
    · obtain ⟨j, rfl⟩ : ∃ j, i = j + 1 := ⟨i - 1, by omega⟩
      rw [piToFam_succ]
      by_cases h : j < n
      · rw [dif_pos h]; exact (w ⟨j, h⟩).2
      · rw [dif_neg h]; exact V.val_one
  · intro i hi
    obtain ⟨j, rfl⟩ : ∃ j, i = j + 1 := ⟨i - 1, by omega⟩
    rw [piToFam_succ, dif_neg (by omega : ¬j < n)]
  · rw [Finset.prod_range_succ' (fun i => piToFam V n w i) n, piToFam_zero]
    have hshift : ∀ i ∈ range n, piToFam V n w (i + 1)
        = (fun i : ℕ => if h : i < n then (w ⟨i, h⟩ : G) else 1) i := fun i _ => piToFam_succ V n w i
    rw [Finset.prod_congr rfl hshift]
    have hfin : ∏ i ∈ range n, (fun i : ℕ => if h : i < n then (w ⟨i, h⟩ : G) else 1) i
        = ∏ j : Fin n, (w j : G) := by
      rw [← Fin.prod_univ_eq_prod_range (fun i : ℕ => if h : i < n then (w ⟨i, h⟩ : G) else 1) n]
      exact Finset.prod_congr rfl fun j _ => by simp
    rw [hfin, mul_inv_cancel]

/-- The twist group on `m = n + 1` slots is a free choice of `n` valuation-zero elements: the
zeroth slot is determined by the product condition.  This is the "rigidity index `m - 1`". -/
def twistEquivPi (V : DiscreteVal G) (n : ℕ) :
    twistGroup V (n + 1) ≃ (Fin n → {u : G // V.val u = 0}) where
  toFun u := fun j => ⟨(u : ℕ → G) (j + 1), u.2.1 (j + 1) (by omega)⟩
  invFun w := ⟨piToFam V n w, V.piToFam_mem n w⟩
  left_inv := by
    intro u
    apply Subtype.ext
    funext i
    simp only [piToFam]
    rcases Nat.eq_zero_or_pos i with h0 | h0
    · subst h0
      have hprod : (∏ j : Fin n, (u : ℕ → G) (j + 1)) = ∏ i ∈ range n, (u : ℕ → G) (i + 1) :=
        Fin.prod_univ_eq_prod_range (fun i : ℕ => (u : ℕ → G) (i + 1)) n
      have hone : (∏ i ∈ range n, (u : ℕ → G) (i + 1)) * (u : ℕ → G) 0 = 1 := by
        rw [← Finset.prod_range_succ' (fun i => (u : ℕ → G) i) n]
        exact u.2.2.2
      rw [if_pos rfl, hprod, eq_inv_of_mul_eq_one_left hone, inv_inv]
    · rw [if_neg (by omega : ¬i = 0)]
      by_cases h : i - 1 < n
      · rw [dif_pos h]
        exact congrArg (fun t : ℕ => (u : ℕ → G) t) (by omega : i - 1 + 1 = i)
      · rw [dif_neg h]
        exact (u.2.2.1 i (by omega)).symm
  right_inv := by
    intro w
    funext j
    apply Subtype.ext
    simp only [piToFam]
    rw [if_neg (by omega : ¬(j : ℕ) + 1 = 0), dif_pos (by omega : (j : ℕ) + 1 - 1 < n)]
    exact congrArg (fun t : Fin n => ((w t : {x : G // V.val x = 0}) : G)) (Fin.ext (by simp))

/-- **Rigidity index (abstract Conjecture C1).**  For `m = n + 1` slots the fibre over a
realizable target has exactly `#{u | val u = 0} ^ n` elements: the fibre is `n = m - 1`
independent copies of the valuation-zero group.  (Both sides are `0` when that group is
infinite and `n ≥ 1`, which is the correct reading of "infinitely many factorizations".) -/
theorem card_factorizations (k : ℤ) (n : ℕ) (d : ℕ → ℤ) (g : G)
    (hg : V.val g = k + ∑ i ∈ range (n + 1), d i) :
    Nat.card (factorizations V k (n + 1) d g)
      = Nat.card {u : G // V.val u = 0} ^ n := by
  obtain ⟨f₀, hf₀⟩ := (V.realizable_iff k (n + 1) (by omega) d g).mpr hg
  have h1 : Nat.card (factorizations V k (n + 1) d g) = Nat.card (twistGroup V (n + 1)) :=
    Nat.card_congr (V.fibreEquivTwist k (n + 1) d g f₀ hf₀)
  have h2 : Nat.card (twistGroup V (n + 1)) = Nat.card (Fin n → {u : G // V.val u = 0}) :=
    Nat.card_congr (V.twistEquivPi n)
  rw [h1, h2, Nat.card_fun, Nat.card_eq_fintype_card (α := Fin n), Fintype.card_fin]

end DiscreteVal

/-! ## Instantiation 1: Laurent series -/

open HahnSeries

/-- The `q`-adic valuation datum on the unit group of the Laurent series field. -/
noncomputable def laurentVal (K : Type*) [Field K] : DiscreteVal (LaurentSeries K)ˣ where
  val u := ((u : LaurentSeries K)).order
  val_mul a b := by
    simp only [Units.val_mul]
    exact HahnSeries.order_mul (x := (a : LaurentSeries K)) (y := (b : LaurentSeries K))
      (Units.ne_zero a) (Units.ne_zero b)
  uniformizer := Units.mk0 (HahnSeries.single (1 : ℤ) (1 : K)) (by simp)
  val_uniformizer := by
    simp [HahnSeries.order_single (one_ne_zero : (1 : K) ≠ 0)]

/-- **Laurent series, general profile.**  A unit of `LaurentSeries K` is a renormalized product
`q ^ k * ∏_{i<m} f i` of units with orders `d i` iff its order is `k + ∑ d i`. -/
theorem laurent_realizable_iff (K : Type*) [Field K] (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ)
    (g : (LaurentSeries K)ˣ) :
    (∃ f, f ∈ DiscreteVal.factorizations (laurentVal K) k m d g) ↔
      ((g : LaurentSeries K)).order = k + ∑ i ∈ range m, d i :=
  DiscreteVal.realizable_iff (laurentVal K) k m hm d g

/-- **Laurent series, rigidity dichotomy.**  With the simple-pole profile `d ≡ -1` and `k = m`,
the fibre over an order-`0` unit is a singleton iff `m = 1`; the twisting unit `1 + q` provides
the nontrivial valuation-zero element over any field. -/
theorem laurent_rigidity_dichotomy (K : Type*) [Field K] (k : ℤ) (m : ℕ) (hm : 1 ≤ m)
    (d : ℕ → ℤ) (g : (LaurentSeries K)ˣ)
    (hg : ((g : LaurentSeries K)).order = k + ∑ i ∈ range m, d i) :
    (DiscreteVal.factorizations (laurentVal K) k m d g).Subsingleton ↔ m = 1 := by
  set q : LaurentSeries K := HahnSeries.single (1 : ℤ) (1 : K) with hq
  have hq0 : q ≠ 0 := by simp [hq]
  have hqt : q.orderTop = ((1 : ℤ) : WithTop ℤ) := by
    rw [hq, HahnSeries.orderTop_single (a := (1 : ℤ)) (r := (1 : K)) one_ne_zero]
  have hq1 : (1 : LaurentSeries K).orderTop < q.orderTop := by
    rw [hqt, HahnSeries.orderTop_one]
    exact_mod_cast (by norm_num : ((0 : ℤ) : WithTop ℤ) < ((1 : ℤ) : WithTop ℤ))
  have h2 : (1 + q).orderTop = (0 : WithTop ℤ) := by
    have h := HahnSeries.orderTop_add_eq_left (x := (1 : LaurentSeries K)) (y := q) hq1
    rw [h, HahnSeries.orderTop_one]
  have hone : (1 + q) ≠ 0 := by
    intro h
    rw [h] at h2
    simp at h2
  have hval : (laurentVal K).val (Units.mk0 (1 + q) hone) = 0 := by
    have h3 : (((1 + q).order : ℤ) : WithTop ℤ) = (1 + q).orderTop :=
      HahnSeries.order_eq_orderTop_of_ne_zero hone
    rw [h2] at h3
    show (1 + q).order = 0
    exact_mod_cast h3
  have hne : (Units.mk0 (1 + q) hone) ≠ 1 := by
    intro h
    have h4 : (1 + q) = (1 : LaurentSeries K) := congrArg Units.val h
    exact hq0 (by simpa using h4)
  exact DiscreteVal.rigidity_dichotomy (laurentVal K) k m hm d g hg hval hne

/-! ## Instantiation 2: the `p`-adic numbers -/

variable (p : ℕ) [hp : Fact p.Prime]

/-- The `p`-adic valuation datum on `ℚ_[p]ˣ`. -/
noncomputable def padicVal : DiscreteVal (ℚ_[p])ˣ where
  val u := Padic.valuation (p := p) (u : ℚ_[p])
  val_mul a b := by
    simp only [Units.val_mul]
    exact Padic.valuation_mul (p := p) (Units.ne_zero a) (Units.ne_zero b)
  uniformizer := Units.mk0 (p : ℚ_[p]) (by
    exact_mod_cast (Nat.cast_ne_zero (R := ℚ_[p])).mpr hp.out.ne_zero)
  val_uniformizer := Padic.valuation_p (p := p)

/-- **`p`-adic realizability.**  For `m ≥ 1`, a `p`-adic unit is a renormalized product
`p ^ k * ∏_{i<m} x i` with `v_p (x i) = d i` iff `v_p` of it equals `k + ∑ d i`. -/
theorem padic_realizable_iff (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ) (g : (ℚ_[p])ˣ) :
    (∃ f, f ∈ DiscreteVal.factorizations (padicVal p) k m d g) ↔
      Padic.valuation (p := p) (g : ℚ_[p]) = k + ∑ i ∈ range m, d i :=
  DiscreteVal.realizable_iff (padicVal p) k m hm d g

/-- **`p`-adic rigidity dichotomy.**  The factorization of a `p`-adic number into `m` factors of
prescribed valuations is unique iff `m = 1`; for `m ≥ 2` the element `-1` already produces a
second factorization. -/
theorem padic_rigidity_dichotomy (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d : ℕ → ℤ) (g : (ℚ_[p])ˣ)
    (hg : Padic.valuation (p := p) (g : ℚ_[p]) = k + ∑ i ∈ range m, d i) :
    (DiscreteVal.factorizations (padicVal p) k m d g).Subsingleton ↔ m = 1 := by
  have hne0 : (-1 : ℚ_[p]) ≠ 0 := by norm_num
  have hval : (padicVal p).val (Units.mk0 (-1 : ℚ_[p]) hne0) = 0 := by
    have h := Padic.valuation_mul (p := p) hne0 hne0
    rw [show ((-1 : ℚ_[p]) * (-1 : ℚ_[p])) = 1 from by ring, Padic.valuation_one] at h
    show Padic.valuation (p := p) (-1 : ℚ_[p]) = 0
    omega
  have hne : (Units.mk0 (-1 : ℚ_[p]) hne0) ≠ 1 := by
    intro h
    have : (-1 : ℚ_[p]) = 1 := by
      simpa using congrArg (fun u : (ℚ_[p])ˣ => (u : ℚ_[p])) h
    norm_num at this
  exact DiscreteVal.rigidity_dichotomy (padicVal p) k m hm d g hg hval hne

end Catalog.Probability.RenormalizedFactorizationValuation