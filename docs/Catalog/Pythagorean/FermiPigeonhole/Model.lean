/-
# A finite product-measure model of the Drake / Fermi setting

We build, from scratch and with no measure theory, an explicit finite probability
space describing a universe of `N` habitable sites observed over `T` epochs.

Each site independently is either *lifeless* (`none`) or hosts a technological
civilization arising in exactly one of the `T` epochs (`some e`).  A site is
civilized with probability `p`, and, conditionally on being civilized, the epoch
is uniform on `Fin T`.  The resulting weight of an elementary outcome
`f : Fin N → Option (Fin T)` is the product over sites of the local weights

  `siteWeight none = 1 - p`,  `siteWeight (some e) = p / T`.

The main structural result of this file is `prb_cylinder`: the probability of a
*cylinder event* `{f | ∀ i, f i ∈ B i}` factorises as a product of local masses.
Every later estimate (first moment of the civilization count, probability of a
lifeless cosmos, union bound on contact) is derived from this single identity
together with the general `prb_union_bound`.
-/
import Mathlib

namespace Pythagorean.FermiPigeonhole

open Finset

/-- The sample space: each of `N` habitable sites is lifeless (`none`) or hosts a
civilization arising in one of `T` epochs. -/
abbrev Cosmos (N T : ℕ) := Fin N → Option (Fin T)

/-- Local weight of the state of a single site. -/
noncomputable def siteWeight (T : ℕ) (p : ℝ) : Option (Fin T) → ℝ
  | none => 1 - p
  | some _ => p / T

/-- Weight (probability) of an elementary outcome: the product of the local weights. -/
noncomputable def weight (N T : ℕ) (p : ℝ) (f : Cosmos N T) : ℝ :=
  ∏ i, siteWeight T p (f i)

/-- Probability of an event, i.e. the total weight of the outcomes satisfying it. -/
noncomputable def Prb (N T : ℕ) (p : ℝ) (A : Set (Cosmos N T)) : ℝ :=
  ∑ f : Cosmos N T, A.indicator (weight N T p) f

variable {N T : ℕ} {p : ℝ}

lemma siteWeight_nonneg (h0 : 0 ≤ p) (h1 : p ≤ 1) (x : Option (Fin T)) :
    0 ≤ siteWeight T p x := by
  cases x with
  | none => simpa [siteWeight] using h1
  | some e => exact div_nonneg h0 (by positivity)

lemma weight_nonneg (h0 : 0 ≤ p) (h1 : p ≤ 1) (f : Cosmos N T) :
    0 ≤ weight N T p f :=
  Finset.prod_nonneg fun _ _ => siteWeight_nonneg h0 h1 _

/-- The local weights of a single site sum to one. -/
lemma siteWeight_sum (hT : 0 < T) :
    ∑ x : Option (Fin T), siteWeight T p x = 1 := by
  have hT' : (T : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hT.ne'
  rw [Fintype.sum_option]
  simp only [siteWeight, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  field_simp
  ring

/-- **Cylinder factorisation.**  The probability that every site `i` lands in a
prescribed set `B i` of local states is the product of the local masses. -/
lemma prb_cylinder (B : Fin N → Finset (Option (Fin T))) :
    Prb N T p {f | ∀ i, f i ∈ B i} = ∏ i, ∑ x ∈ B i, siteWeight T p x := by
  classical
  have hsub : (Fintype.piFinset B) ⊆ (Finset.univ : Finset (Cosmos N T)) :=
    Finset.subset_univ _
  have h1 : ∑ f ∈ Fintype.piFinset B,
        Set.indicator {f : Cosmos N T | ∀ i, f i ∈ B i} (weight N T p) f
      = ∑ f : Cosmos N T,
        Set.indicator {f : Cosmos N T | ∀ i, f i ∈ B i} (weight N T p) f := by
    refine Finset.sum_subset hsub fun f _ hf => ?_
    exact Set.indicator_of_notMem (by simpa [Fintype.mem_piFinset] using hf) _
  have h2 : ∑ f ∈ Fintype.piFinset B,
        Set.indicator {f : Cosmos N T | ∀ i, f i ∈ B i} (weight N T p) f
      = ∑ f ∈ Fintype.piFinset B, weight N T p f :=
    Finset.sum_congr rfl fun f hf =>
      Set.indicator_of_mem
        (show f ∈ {g : Cosmos N T | ∀ i, g i ∈ B i} from Fintype.mem_piFinset.mp hf) _
  rw [Prb, ← h1, h2, Finset.prod_univ_sum]
  exact Finset.sum_congr rfl fun f _ => rfl

/-- Total mass one: `Prb` really is a probability. -/
lemma prb_univ (hT : 0 < T) : Prb N T p Set.univ = 1 := by
  classical
  have hev : (Set.univ : Set (Cosmos N T))
      = {f : Cosmos N T | ∀ i, f i ∈ (Finset.univ : Finset (Option (Fin T)))} := by
    ext f; simp
  rw [hev, prb_cylinder]
  simp only [siteWeight_sum (p := p) hT, Finset.prod_const_one]

/-- Complementary events have complementary probabilities. -/
lemma prb_add_compl (hT : 0 < T) (A : Set (Cosmos N T)) :
    Prb N T p A + Prb N T p Aᶜ = 1 := by
  have hsum : ∀ f : Cosmos N T,
      A.indicator (weight N T p) f + Aᶜ.indicator (weight N T p) f = weight N T p f := by
    intro f
    exact congrFun (Set.indicator_self_add_compl A (weight N T p)) f
  have htot : ∑ f : Cosmos N T, weight N T p f = 1 := by
    have h := prb_univ (N := N) (T := T) (p := p) hT
    rwa [Prb, Set.indicator_univ] at h
  rw [Prb, Prb, ← Finset.sum_add_distrib]
  rw [Finset.sum_congr rfl fun f _ => hsum f]
  exact htot

/-- Monotonicity of `Prb` in the event. -/
lemma prb_mono (h0 : 0 ≤ p) (h1 : p ≤ 1) {A B : Set (Cosmos N T)} (hAB : A ⊆ B) :
    Prb N T p A ≤ Prb N T p B := by
  refine Finset.sum_le_sum fun f _ => ?_
  exact Set.indicator_le_indicator_of_subset hAB (fun g => weight_nonneg h0 h1 g) f

lemma prb_nonneg (h0 : 0 ≤ p) (h1 : p ≤ 1) (A : Set (Cosmos N T)) : 0 ≤ Prb N T p A :=
  Finset.sum_nonneg fun f _ =>
    Set.indicator_apply_nonneg fun _ => weight_nonneg h0 h1 f

/-- **Union bound / first-moment bound.**  The probability that at least one of a
finite family of events occurs is at most the sum of their probabilities. -/
lemma prb_union_bound (h0 : 0 ≤ p) (h1 : p ≤ 1) {ι : Type*} (s : Finset ι)
    (A : ι → Set (Cosmos N T)) :
    Prb N T p {f | ∃ x ∈ s, f ∈ A x} ≤ ∑ x ∈ s, Prb N T p (A x) := by
  classical
  have key : ∀ f : Cosmos N T,
      Set.indicator {f : Cosmos N T | ∃ x ∈ s, f ∈ A x} (weight N T p) f
        ≤ ∑ x ∈ s, Set.indicator (A x) (weight N T p) f := by
    intro f
    by_cases hex : ∃ x ∈ s, f ∈ A x
    · obtain ⟨x₀, hx₀s, hx₀⟩ := hex
      have hle : Set.indicator (A x₀) (weight N T p) f
          ≤ ∑ x ∈ s, Set.indicator (A x) (weight N T p) f := by
        refine Finset.single_le_sum
          (f := fun x => Set.indicator (A x) (weight N T p) f) (fun x _ => ?_) hx₀s
        exact Set.indicator_apply_nonneg fun _ => weight_nonneg h0 h1 f
      have hmem : f ∈ {g : Cosmos N T | ∃ x ∈ s, g ∈ A x} := ⟨x₀, hx₀s, hx₀⟩
      have heq : Set.indicator {g : Cosmos N T | ∃ x ∈ s, g ∈ A x} (weight N T p) f
          = weight N T p f := Set.indicator_of_mem hmem _
      rw [Set.indicator_of_mem hx₀] at hle
      rw [heq]
      exact hle
    · have hnmem : f ∉ {g : Cosmos N T | ∃ x ∈ s, g ∈ A x} := hex
      have hz : Set.indicator {g : Cosmos N T | ∃ x ∈ s, g ∈ A x} (weight N T p) f = 0 :=
        Set.indicator_of_notMem hnmem _
      rw [hz]
      exact Finset.sum_nonneg fun x _ =>
        Set.indicator_apply_nonneg fun _ => weight_nonneg h0 h1 f
  calc Prb N T p {f | ∃ x ∈ s, f ∈ A x}
      ≤ ∑ f : Cosmos N T, ∑ x ∈ s, Set.indicator (A x) (weight N T p) f :=
        Finset.sum_le_sum fun f _ => key f
    _ = ∑ x ∈ s, ∑ f : Cosmos N T, Set.indicator (A x) (weight N T p) f := Finset.sum_comm
    _ = ∑ x ∈ s, Prb N T p (A x) := rfl

end Pythagorean.FermiPigeonhole