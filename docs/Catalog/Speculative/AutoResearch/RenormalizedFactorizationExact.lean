/-
# Renormalized factorization: gauge invariance of the pole profile and the split exact
# sequence behind the rigidity dichotomy (Cycle 5)

This file closes the two remaining structural conjectures of the Conjecture-C thread
(see `FUTURE_DIRECTIONS.md`), building directly on the abstract discretely-valued setting of
`Catalog/Probability/RenormalizedFactorizationValuation.lean`.

* **C2 (sharp form): the pole profile is pure gauge.**  Two pole profiles `d`, `d'` with the
  same total `∑_{i<m} d i` have *the same* realizable set (`realizable_set_eq_of_sum_eq`) and
  *equinumerous* fibres (`profileEquiv`): the explicit bijection is the monomial gauge
  transformation `f i ↦ f i * π ^ (d' i - d i)`, whose exponents sum to `0` and therefore leave
  the renormalized product untouched.  Consequently rigidity is profile-independent
  (`subsingleton_iff_subsingleton_of_sum_eq`).

* **C5 (exact sequence).**  "The total valuation is the only obstruction" and "the factorization
  is never unique for `m ≥ 2`" are the two halves of the short exact sequence

  `1 ⟶ ker(Π) ⟶ (𝒪ˣ)^m ⟶ 𝒪ˣ ⟶ 1`,   `𝒪ˣ = {u | val u = 0}`,

  where `Π` is the product homomorphism.  We prove that the sequence is exact and **split**
  (`prodHom_surjective`, `prodHom_comp_sectionHom`), that its kernel is *freely* `m - 1` copies
  of `𝒪ˣ` as a group (`kerEquivPi`, a `MulEquiv`, strictly stronger than the bare bijection of
  the previous cycle), that the whole middle group splits as `ker × 𝒪ˣ`
  (`piEquivKerProd`), and finally that the fibre of the renormalized-product map over any
  realizable target is in bijection with that kernel (`fibreEquivKer`).  This is the exact
  sense in which the rigidity index is the corank `m - 1` of the product map.

No `sorry`, no `native_decide`, no new axioms.
-/
import Probability.RenormalizedFactorizationValuation

namespace Catalog.Probability.RenormalizedFactorizationValuation

open Finset

namespace DiscreteVal

variable {G : Type*} [CommGroup G] (V : DiscreteVal G)

/-! ## Part 1 (C2).  The pole profile is a gauge choice -/

/-- Rewriting a profile that agrees with another on the window `[0, m)`. -/
lemma hasProfile_congr {m : ℕ} {d d' : ℕ → ℤ} (h : ∀ i < m, d i = d' i) {f : ℕ → G}
    (hf : HasProfile V m d f) : HasProfile V m d' f :=
  ⟨fun i hi => (hf.1 i hi).trans (h i hi), hf.2⟩

/-- The *monomial gauge transformation*: multiply the `i`-th slot by `π ^ (e i)` inside the
window `[0, m)`. -/
def gauge (V : DiscreteVal G) (m : ℕ) (e : ℕ → ℤ) (f : ℕ → G) : ℕ → G :=
  fun i => if i < m then f i * V.uniformizer ^ (e i) else f i

lemma gauge_hasProfile {m : ℕ} {d : ℕ → ℤ} (e : ℕ → ℤ) {f : ℕ → G} (hf : HasProfile V m d f) :
    HasProfile V m (fun i => d i + e i) (V.gauge m e f) := by
  constructor
  · intro i hi
    simp only [gauge, if_pos hi, V.val_mul, V.val_uniformizer_zpow, hf.1 i hi]
  · intro i hi
    simp only [gauge, if_neg (by omega : ¬ i < m)]
    exact hf.2 i hi

/-- A gauge transformation with exponents summing to `0` does not change the renormalized
product: this is exactly why the individual pole orders are unobservable. -/
lemma renormProd_gauge {k : ℤ} {m : ℕ} {e : ℕ → ℤ} (he : ∑ i ∈ range m, e i = 0) (f : ℕ → G) :
    renormProd V k m (V.gauge m e f) = renormProd V k m f := by
  have hsplit : ∏ i ∈ range m, V.gauge m e f i
      = (∏ i ∈ range m, f i) * ∏ i ∈ range m, V.uniformizer ^ (e i) := by
    rw [← Finset.prod_mul_distrib]
    exact Finset.prod_congr rfl fun i hi => by
      simp only [gauge, if_pos (Finset.mem_range.mp hi)]
  simp only [renormProd, hsplit, V.prod_uniformizer_zpow, he, zpow_zero, mul_one]

lemma gauge_neg_gauge (m : ℕ) (e : ℕ → ℤ) (f : ℕ → G) :
    V.gauge m (fun i => -e i) (V.gauge m e f) = f := by
  funext i
  by_cases h : i < m
  · simp [gauge, h, mul_assoc]
  · simp [gauge, h]

lemma gauge_gauge_neg (m : ℕ) (e : ℕ → ℤ) (f : ℕ → G) :
    V.gauge m e (V.gauge m (fun i => -e i) f) = f := by
  funext i
  by_cases h : i < m
  · simp [gauge, h, mul_assoc]
  · simp [gauge, h]

lemma sum_neg_range {m : ℕ} {e : ℕ → ℤ} (he : ∑ i ∈ range m, e i = 0) :
    ∑ i ∈ range m, (-e i) = 0 := by
  simpa using congrArg Neg.neg he

/-- **Gauge equivalence of fibres.**  Shifting the pole profile by an exponent vector `e` of
total weight `0` is a bijection between the corresponding fibres. -/
def gaugeEquiv (V : DiscreteVal G) (k : ℤ) (m : ℕ) (d e : ℕ → ℤ)
    (he : ∑ i ∈ range m, e i = 0) (g : G) :
    factorizations V k m d g ≃ factorizations V k m (fun i => d i + e i) g where
  toFun f := ⟨V.gauge m e f, V.gauge_hasProfile e f.2.1, by
    rw [V.renormProd_gauge he]; exact f.2.2⟩
  invFun f := ⟨V.gauge m (fun i => -e i) f,
    V.hasProfile_congr (fun i _ => by ring) (V.gauge_hasProfile (fun i => -e i) f.2.1), by
      rw [V.renormProd_gauge (sum_neg_range he)]; exact f.2.2⟩
  left_inv f := Subtype.ext (V.gauge_neg_gauge m e f)
  right_inv f := Subtype.ext (V.gauge_gauge_neg m e f)

/-- **Conjecture C2, sharp form (fibres).**  Any two pole profiles with the same total weight
have equinumerous fibres over the same target: the profile is unobservable. -/
def profileEquiv (V : DiscreteVal G) (k : ℤ) (m : ℕ) (d d' : ℕ → ℤ)
    (hdd : ∑ i ∈ range m, d i = ∑ i ∈ range m, d' i) (g : G) :
    factorizations V k m d g ≃ factorizations V k m d' g := by
  have he : ∑ i ∈ range m, (d' i - d i) = 0 := by
    rw [Finset.sum_sub_distrib, ← hdd, sub_self]
  refine (V.gaugeEquiv k m d (fun i => d' i - d i) he g).trans (Equiv.setCongr ?_)
  unfold factorizations
  ext f
  constructor
  · rintro ⟨hp, hq⟩
    exact ⟨V.hasProfile_congr (fun i _ => by ring) hp, hq⟩
  · rintro ⟨hp, hq⟩
    exact ⟨V.hasProfile_congr (fun i _ => by ring) hp, hq⟩

/-- **Conjecture C2, sharp form (realizable sets).**  Only the total weight `∑ d i` is visible:
profiles with equal totals realize exactly the same set of targets. -/
theorem realizable_set_eq_of_sum_eq (k : ℤ) (m : ℕ) (hm : 1 ≤ m) (d d' : ℕ → ℤ)
    (hdd : ∑ i ∈ range m, d i = ∑ i ∈ range m, d' i) :
    {g : G | ∃ f, HasProfile V m d f ∧ renormProd V k m f = g}
      = {g : G | ∃ f, HasProfile V m d' f ∧ renormProd V k m f = g} := by
  rw [V.setOf_renormProd_eq k m hm d, V.setOf_renormProd_eq k m hm d', hdd]

/-- Rigidity does not see the profile either. -/
theorem subsingleton_iff_subsingleton_of_sum_eq (k : ℤ) (m : ℕ) (d d' : ℕ → ℤ)
    (hdd : ∑ i ∈ range m, d i = ∑ i ∈ range m, d' i) (g : G) :
    (factorizations V k m d g).Subsingleton ↔ (factorizations V k m d' g).Subsingleton := by
  rw [← Set.subsingleton_coe, ← Set.subsingleton_coe]
  exact (V.profileEquiv k m d d' hdd g).subsingleton_congr

/-! ## Part 2 (C5).  The split short exact sequence `1 → ker Π → (𝒪ˣ)^m → 𝒪ˣ → 1` -/

/-- The valuation-zero subgroup `𝒪ˣ = {u | val u = 0}` of `G`. -/
def valZero (V : DiscreteVal G) : Subgroup G where
  carrier := {u | V.val u = 0}
  mul_mem' := by
    intro a b ha hb
    simp only [Set.mem_setOf_eq] at *
    rw [V.val_mul, ha, hb, add_zero]
  one_mem' := by simp
  inv_mem' := by
    intro a ha
    simp only [Set.mem_setOf_eq] at *
    rw [V.val_inv, ha, neg_zero]

@[simp] lemma mem_valZero {u : G} : u ∈ valZero V ↔ V.val u = 0 := Iff.rfl

/-- The product homomorphism `Π : (𝒪ˣ)^m → 𝒪ˣ` whose fibres are the twist groups. -/
def prodHom (V : DiscreteVal G) (m : ℕ) : (Fin m → valZero V) →* valZero V where
  toFun w := ∏ j, w j
  map_one' := by simp
  map_mul' w w' := by simp [Finset.prod_mul_distrib]

lemma prodHom_apply (m : ℕ) (w : Fin m → valZero V) :
    prodHom V m w = ∏ j, w j := rfl

/-- The canonical splitting `𝒪ˣ → (𝒪ˣ)^{m}`: put everything in slot `0`. -/
def sectionHom (V : DiscreteVal G) (n : ℕ) : valZero V →* (Fin (n + 1) → valZero V) where
  toFun a := Fin.cons a 1
  map_one' := by funext j; refine Fin.cases ?_ ?_ j <;> simp
  map_mul' a b := by funext j; refine Fin.cases ?_ ?_ j <;> simp

@[simp] lemma prodHom_sectionHom (n : ℕ) (a : valZero V) :
    prodHom V (n + 1) (sectionHom V n a) = a := by
  show ∏ j, (Fin.cons a (1 : Fin n → valZero V) : Fin (n + 1) → valZero V) j = a
  rw [Fin.prod_cons]
  simp

/-- **The sequence splits.** -/
theorem prodHom_comp_sectionHom (n : ℕ) :
    (prodHom V (n + 1)).comp (sectionHom V n) = MonoidHom.id (valZero V) :=
  MonoidHom.ext fun a => prodHom_sectionHom V n a

/-- **Right exactness.**  Every valuation-zero element is a product of `m ≥ 1` valuation-zero
elements. -/
theorem prodHom_surjective (n : ℕ) : Function.Surjective (prodHom V (n + 1)) :=
  fun a => ⟨sectionHom V n a, prodHom_sectionHom V n a⟩

/-- **The kernel is free of rank `m - 1`.**  As a *group*, `ker Π ≅ (𝒪ˣ)^{m-1}`: slots
`1, …, m-1` are arbitrary and slot `0` is forced.  This is the group-theoretic form of the
rigidity index. -/
def kerEquivPi (V : DiscreteVal G) (n : ℕ) :
    (prodHom V (n + 1)).ker ≃* (Fin n → valZero V) where
  toFun w := fun j => (w : Fin (n + 1) → valZero V) j.succ
  invFun v := ⟨Fin.cons (∏ j, v j)⁻¹ v, by
    show ∏ j, (Fin.cons (∏ j, v j)⁻¹ v : Fin (n + 1) → valZero V) j = 1
    rw [Fin.prod_cons, inv_mul_cancel]⟩
  left_inv w := by
    apply Subtype.ext
    have hk : ∏ j, (w : Fin (n + 1) → valZero V) j = 1 := w.2
    rw [Fin.prod_univ_succ] at hk
    funext j
    refine Fin.cases ?_ ?_ j
    · simpa using (eq_inv_of_mul_eq_one_left hk).symm
    · intro i; simp
  right_inv v := by funext j; simp
  map_mul' w w' := rfl

/-- The middle group of the sequence splits as `ker Π × 𝒪ˣ`. -/
def piEquivKerProd (V : DiscreteVal G) (n : ℕ) :
    (Fin (n + 1) → valZero V) ≃* (prodHom V (n + 1)).ker × valZero V where
  toFun w := (⟨w * (sectionHom V n (prodHom V (n + 1) w))⁻¹, by
      rw [MonoidHom.mem_ker, map_mul, map_inv, prodHom_sectionHom, mul_inv_cancel]⟩,
    prodHom V (n + 1) w)
  invFun x := (x.1 : Fin (n + 1) → valZero V) * sectionHom V n x.2
  left_inv w := by
    simp only [mul_assoc, inv_mul_cancel, mul_one]
  right_inv x := by
    have hx : prodHom V (n + 1) (x.1 : Fin (n + 1) → valZero V) = 1 :=
      MonoidHom.mem_ker.mp x.1.2
    have h2 : prodHom V (n + 1) ((x.1 : Fin (n + 1) → valZero V) * sectionHom V n x.2) = x.2 := by
      rw [map_mul, hx, one_mul, prodHom_sectionHom]
    refine Prod.ext ?_ ?_
    · apply Subtype.ext
      show (x.1 : Fin (n + 1) → valZero V) * sectionHom V n x.2 *
        (sectionHom V n (prodHom V (n + 1)
          ((x.1 : Fin (n + 1) → valZero V) * sectionHom V n x.2)))⁻¹
          = (x.1 : Fin (n + 1) → valZero V)
      rw [h2, mul_assoc, mul_inv_cancel, mul_one]
    · exact h2
  map_mul' w w' := by
    refine Prod.ext ?_ ?_
    · apply Subtype.ext
      show (w * w') * (sectionHom V n (prodHom V (n + 1) (w * w')))⁻¹
          = ((w * (sectionHom V n (prodHom V (n + 1) w))⁻¹ : Fin (n + 1) → valZero V)) *
            (w' * (sectionHom V n (prodHom V (n + 1) w'))⁻¹)
      rw [map_mul (prodHom V (n + 1)), map_mul (sectionHom V n), mul_inv]
      simp only [mul_assoc, mul_left_comm]
    · exact map_mul (prodHom V (n + 1)) w w'

/-! ### The fibre of the renormalized-product map is the kernel -/

/-- The valuation-zero subtype and the valuation-zero subgroup are the same thing. -/
def valZeroEquiv (V : DiscreteVal G) : {u : G // V.val u = 0} ≃ valZero V :=
  Equiv.subtypeEquivRight fun _ => Iff.rfl

/-- **Conjecture C5.**  The fibre of the renormalized-product map over any realizable target is
in bijection with `ker Π`.  Together with `prodHom_surjective` this exhibits the two halves of
Conjecture C — "the total valuation is the only obstruction" (right exactness) and
"the factorization is never unique for `m ≥ 2`" (nontriviality of the kernel) — as the two ends
of one short exact sequence. -/
def fibreEquivKer (V : DiscreteVal G) (k : ℤ) (n : ℕ) (d : ℕ → ℤ) (g : G)
    (f₀ : ℕ → G) (hf₀ : f₀ ∈ factorizations V k (n + 1) d g) :
    factorizations V k (n + 1) d g ≃ (prodHom V (n + 1)).ker :=
  (V.fibreEquivTwist k (n + 1) d g f₀ hf₀).trans
    ((V.twistEquivPi n).trans
      ((Equiv.piCongrRight fun _ => valZeroEquiv V).trans (kerEquivPi V n).toEquiv.symm))

/-- The fibre is a singleton iff the kernel is trivial, i.e. iff `m = 1` or `𝒪ˣ = 1`. -/
theorem subsingleton_factorizations_iff_subsingleton_ker (k : ℤ) (n : ℕ) (d : ℕ → ℤ) (g : G)
    (f₀ : ℕ → G) (hf₀ : f₀ ∈ factorizations V k (n + 1) d g) :
    (factorizations V k (n + 1) d g).Subsingleton ↔
      Subsingleton ((prodHom V (n + 1)).ker) := by
  rw [← Set.subsingleton_coe]
  exact (V.fibreEquivKer k n d g f₀ hf₀).subsingleton_congr

end DiscreteVal

/-! ## Instantiations -/

/-- **Laurent series: the pole profile is gauge.**  Distributing the same total pole order
differently among the `m` factors gives exactly the same realizable set of Laurent series. -/
theorem laurent_realizable_set_eq_of_sum_eq (K : Type*) [Field K] (k : ℤ) (m : ℕ) (hm : 1 ≤ m)
    (d d' : ℕ → ℤ) (hdd : ∑ i ∈ Finset.range m, d i = ∑ i ∈ Finset.range m, d' i) :
    {g : (LaurentSeries K)ˣ | ∃ f, DiscreteVal.HasProfile (laurentVal K) m d f ∧
        DiscreteVal.renormProd (laurentVal K) k m f = g}
      = {g : (LaurentSeries K)ˣ | ∃ f, DiscreteVal.HasProfile (laurentVal K) m d' f ∧
        DiscreteVal.renormProd (laurentVal K) k m f = g} :=
  DiscreteVal.realizable_set_eq_of_sum_eq (laurentVal K) k m hm d d' hdd

/-- **`p`-adic numbers: the valuation profile is gauge.** -/
theorem padic_realizable_set_eq_of_sum_eq (p : ℕ) [Fact p.Prime] (k : ℤ) (m : ℕ) (hm : 1 ≤ m)
    (d d' : ℕ → ℤ) (hdd : ∑ i ∈ Finset.range m, d i = ∑ i ∈ Finset.range m, d' i) :
    {g : (ℚ_[p])ˣ | ∃ f, DiscreteVal.HasProfile (padicVal p) m d f ∧
        DiscreteVal.renormProd (padicVal p) k m f = g}
      = {g : (ℚ_[p])ˣ | ∃ f, DiscreteVal.HasProfile (padicVal p) m d' f ∧
        DiscreteVal.renormProd (padicVal p) k m f = g} :=
  DiscreteVal.realizable_set_eq_of_sum_eq (padicVal p) k m hm d d' hdd

end Catalog.Probability.RenormalizedFactorizationValuation