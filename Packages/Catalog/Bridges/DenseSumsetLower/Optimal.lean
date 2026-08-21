/-
# Towards the optimal constant `1` for progression sumsets

`Bridges.DenseSumsetLower.Window` narrows the extremal constant for sumsets of two
arithmetic progressions inside a `δ`-dense subset of `[n]` to the range `[1, 3/2]`.  The
lower end is proved (`DenseSumsetLower.eventually_exists_sumset_sharp`); this file develops
the machinery for pushing the upper end down to `1`.

The loss in the `3/2` bound is that the union bound treats every pair of progressions
alike, paying `n³` for `(t, d₁, d₂)` while only guaranteeing the `2k-1` points of an
L-shaped witness.  In fact `2k-1` points is the truth only when `d₁ = d₂`, and that case
costs merely `n²` parameters.  Writing `d₁ = g e₁`, `d₂ = g e₂` with `gcd(e₁,e₂) = 1`, the
sumset contains a full `k × min(max(e₁,e₂), k)` block, so the witness grows with
`Q = max(e₁,e₂)` while the number of parameters with a given `Q` stays `O(n²)`.

This file contains:

* `DenseSumsetLower.exists_card_eq_avoiding_weighted` — a first-moment principle allowing
  the witnesses to have *different* sizes, with the real-valued condition
  `∑ (m/n)^{L i} < 1`;
* `DenseSumsetLower.blockWitness` and `card_blockWitness` — the `k × r` block inside a
  sumset of two progressions, and its exact cardinality when `r ≤ e₁`.
-/
import Bridges.DeltaDenseSumsetAvoidance
import Bridges.DenseSumsetLower.Sharp

namespace DenseSumsetLower

open Finset Pointwise Filter DeltaDense

/-! ## A first-moment principle with variable witness sizes -/

/-- **Weighted first moment.**  Let `W i` be a family of subsets of `ℕ`, indexed by a finite
set `I`, with `|W i| ≥ L i ≥ 1`.  If `∑_{i ∈ I} (m/n)^{L i} < 1` then some `m`-element
subset of `[n]` contains no `W i`.

This refines `DeltaDense.exists_card_eq_avoiding_family`, where all the `L i` are equal. -/
theorem exists_card_eq_avoiding_weighted {ι : Type*} [DecidableEq ι] {n m : ℕ}
    (I : Finset ι) (W : ι → Finset ℕ) (L : ι → ℕ)
    (hW : ∀ i ∈ I, L i ≤ (W i).card) (hmn : m ≤ n) (hm : 1 ≤ m)
    (hcond : ∑ i ∈ I, ((m : ℝ) / n) ^ (L i) < 1) :
    ∃ S ⊆ range n, S.card = m ∧ ∀ i ∈ I, ¬ (W i ⊆ S) := by
  classical
  have hn0 : 0 < n := lt_of_lt_of_le hm hmn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
  set Fam : Finset (Finset ℕ) := (range n).powersetCard m with hFam
  have hcardFam : Fam.card = n.choose m := by
    rw [hFam, Finset.card_powersetCard, Finset.card_range]
  set Bad : Finset (Finset ℕ) :=
    I.biUnion (fun i => Fam.filter (fun S => W i ⊆ S)) with hBad
  -- each bad class is small
  have hterm : ∀ i ∈ I,
      ((Fam.filter (fun S => W i ⊆ S)).card : ℝ) ≤ (n.choose m : ℝ) * ((m : ℝ) / n) ^ (L i) := by
    intro i hi
    by_cases hLm : L i ≤ m
    · by_cases hsub : W i ⊆ range n
      · obtain ⟨P, hPW, hPcard⟩ := Finset.exists_subset_card_eq (hW i hi)
        have hmono : Fam.filter (fun S => W i ⊆ S) ⊆ Fam.filter (fun S => P ⊆ S) := by
          intro S hS
          rw [Finset.mem_filter] at hS ⊢
          exact ⟨hS.1, hPW.trans hS.2⟩
        have hcnt : (Fam.filter (fun S => W i ⊆ S)).card ≤ (n - L i).choose (m - L i) := by
          refine le_trans (Finset.card_le_card hmono) ?_
          rw [hFam, card_filter_superset n m (hPW.trans hsub) (by omega), hPcard]
        have hchoose : ((n - L i).choose (m - L i) : ℝ) * (n : ℝ) ^ (L i)
            ≤ (n.choose m : ℝ) * (m : ℝ) ^ (L i) := by
          exact_mod_cast choose_ratio_sub hLm hmn
        have hpow : (0 : ℝ) < (n : ℝ) ^ (L i) := by positivity
        have hstep : ((n - L i).choose (m - L i) : ℝ)
            ≤ (n.choose m : ℝ) * ((m : ℝ) / n) ^ (L i) := by
          rw [div_pow, ← mul_div_assoc, le_div_iff₀ hpow]
          exact hchoose
        calc ((Fam.filter (fun S => W i ⊆ S)).card : ℝ)
            ≤ ((n - L i).choose (m - L i) : ℝ) := by exact_mod_cast hcnt
          _ ≤ (n.choose m : ℝ) * ((m : ℝ) / n) ^ (L i) := hstep
      · have he : (Fam.filter (fun S => W i ⊆ S)) = ∅ := by
          rw [Finset.filter_eq_empty_iff]
          intro S hS hcon
          rw [hFam, Finset.mem_powersetCard] at hS
          exact hsub (hcon.trans hS.1)
        rw [he]
        simp only [Finset.card_empty, Nat.cast_zero]
        positivity
    · have he : (Fam.filter (fun S => W i ⊆ S)) = ∅ := by
        rw [Finset.filter_eq_empty_iff]
        intro S hS hcon
        rw [hFam, Finset.mem_powersetCard] at hS
        have := Finset.card_le_card hcon
        have := hW i hi
        omega
      rw [he]
      simp only [Finset.card_empty, Nat.cast_zero]
      positivity
  have hBadcard : (Bad.card : ℝ) < (Fam.card : ℝ) := by
    have h1 : (Bad.card : ℝ) ≤ ∑ i ∈ I, ((Fam.filter (fun S => W i ⊆ S)).card : ℝ) := by
      have := Finset.card_biUnion_le (s := I) (t := fun i => Fam.filter (fun S => W i ⊆ S))
      calc (Bad.card : ℝ) ≤ ((∑ i ∈ I, (Fam.filter (fun S => W i ⊆ S)).card : ℕ) : ℝ) := by
            exact_mod_cast this
        _ = ∑ i ∈ I, ((Fam.filter (fun S => W i ⊆ S)).card : ℝ) := by push_cast; ring
    have h2 : ∑ i ∈ I, ((Fam.filter (fun S => W i ⊆ S)).card : ℝ)
        ≤ ∑ i ∈ I, (n.choose m : ℝ) * ((m : ℝ) / n) ^ (L i) := Finset.sum_le_sum hterm
    have h3 : ∑ i ∈ I, (n.choose m : ℝ) * ((m : ℝ) / n) ^ (L i)
        = (n.choose m : ℝ) * ∑ i ∈ I, ((m : ℝ) / n) ^ (L i) := by
      rw [Finset.mul_sum]
    have hpos : (0 : ℝ) < (n.choose m : ℝ) := by
      have : 0 < n.choose m := Nat.choose_pos hmn
      exact_mod_cast this
    have h4 : (n.choose m : ℝ) * ∑ i ∈ I, ((m : ℝ) / n) ^ (L i) < (n.choose m : ℝ) := by
      calc (n.choose m : ℝ) * ∑ i ∈ I, ((m : ℝ) / n) ^ (L i)
          < (n.choose m : ℝ) * 1 := by
            exact mul_lt_mul_of_pos_left hcond hpos
        _ = (n.choose m : ℝ) := by ring
    rw [hcardFam]
    linarith
  have hBadlt : Bad.card < Fam.card := by exact_mod_cast hBadcard
  have hne : (Fam \ Bad).Nonempty := by
    rw [← Finset.card_pos]
    have := Finset.card_le_card_sdiff_add_card (s := Fam) (t := Bad)
    omega
  obtain ⟨S, hS⟩ := hne
  rw [Finset.mem_sdiff] at hS
  obtain ⟨hSfam, hSbad⟩ := hS
  rw [hFam, Finset.mem_powersetCard] at hSfam
  refine ⟨S, hSfam.1, hSfam.2, ?_⟩
  intro i hi hcon
  exact hSbad (Finset.mem_biUnion.mpr ⟨i, hi,
    Finset.mem_filter.mpr ⟨by rw [hFam, Finset.mem_powersetCard]; exact hSfam, hcon⟩⟩)

/-! ## The block witness inside a sumset of two progressions -/

/-- The `k × r` block `{t + d₁ i + d₂ j : i < k, j < r}`. -/
def blockWitness (t d₁ d₂ k r : ℕ) : Finset ℕ :=
  ((range k) ×ˢ (range r)).image (fun p => t + d₁ * p.1 + d₂ * p.2)

/-- The block sits inside the sumset of the two progressions. -/
lemma blockWitness_subset_add {a b d₁ d₂ K k r : ℕ} (hk : k ≤ K) (hr : r ≤ K) :
    blockWitness (a + b) d₁ d₂ k r ⊆ apF a d₁ K + apF b d₂ K := by
  intro x hx
  rw [blockWitness, Finset.mem_image] at hx
  obtain ⟨p, hp, rfl⟩ := hx
  rw [Finset.mem_product, Finset.mem_range, Finset.mem_range] at hp
  have he : a + b + d₁ * p.1 + d₂ * p.2 = (a + d₁ * p.1) + (b + d₂ * p.2) := by ring
  rw [he]
  exact Finset.add_mem_add (mem_apF.2 ⟨p.1, by omega, rfl⟩) (mem_apF.2 ⟨p.2, by omega, rfl⟩)

/-- The transposed block also sits inside the sumset. -/
lemma blockWitness_swap_subset_add {a b d₁ d₂ K k r : ℕ} (hk : k ≤ K) (hr : r ≤ K) :
    blockWitness (a + b) d₂ d₁ k r ⊆ apF a d₁ K + apF b d₂ K := by
  intro x hx
  rw [blockWitness, Finset.mem_image] at hx
  obtain ⟨p, hp, rfl⟩ := hx
  rw [Finset.mem_product, Finset.mem_range, Finset.mem_range] at hp
  have he : a + b + d₂ * p.1 + d₁ * p.2 = (a + d₁ * p.2) + (b + d₂ * p.1) := by ring
  rw [he]
  exact Finset.add_mem_add (mem_apF.2 ⟨p.2, by omega, rfl⟩) (mem_apF.2 ⟨p.1, by omega, rfl⟩)

/-- A `(2K-1)`-term progression is contained in the sumset of two `K`-term progressions
with the same common difference. -/
lemma apF_two_sub_one_subset_add {a b d K : ℕ} (hK : 1 ≤ K) :
    apF (a + b) d (2 * K - 1) ⊆ apF a d K + apF b d K := by
  intro x hx
  obtain ⟨i, hi, rfl⟩ := mem_apF.1 hx
  set i₁ := min i (K - 1) with hi₁
  set i₂ := i - i₁ with hi₂
  have hsplit : i = i₁ + i₂ := by omega
  have he : a + b + d * i = (a + d * i₁) + (b + d * i₂) := by
    rw [hsplit]; ring
  rw [he]
  exact Finset.add_mem_add (mem_apF.2 ⟨i₁, by omega, rfl⟩) (mem_apF.2 ⟨i₂, by omega, rfl⟩)

/-- **The block is nondegenerate.**  If `d₁ = g e₁` and `d₂ = g e₂` with `e₁, e₂` coprime
and `g > 0`, then the `k × r` block has exactly `k r` elements as soon as `r ≤ e₁`: a
collision would force `e₁ ∣ (j - j')` with `|j - j'| < e₁`. -/
lemma card_blockWitness {t g e₁ e₂ k r : ℕ} (hg : 0 < g) (he₁ : 0 < e₁)
    (hcop : Nat.Coprime e₁ e₂) (hr : r ≤ e₁) :
    (blockWitness t (g * e₁) (g * e₂) k r).card = k * r := by
  classical
  rw [blockWitness]
  rw [Finset.card_image_of_injOn, Finset.card_product, Finset.card_range, Finset.card_range]
  intro p hp p' hp' hpp
  rw [Finset.coe_product] at hp hp'
  simp only [Set.mem_prod, Finset.coe_range, Set.mem_Iio] at hp hp'
  simp only at hpp
  -- pass to `ℤ`
  have hgz : (g : ℤ) ≠ 0 := Int.natCast_ne_zero.mpr (by omega)
  have hZ : (e₁ : ℤ) * ((p.1 : ℤ) - p'.1) = (e₂ : ℤ) * ((p'.2 : ℤ) - p.2) := by
    have hcast : (g : ℤ) * ((e₁ : ℤ) * ((p.1 : ℤ) - p'.1) - (e₂ : ℤ) * ((p'.2 : ℤ) - p.2)) = 0 := by
      have := congrArg (fun x : ℕ => (x : ℤ)) hpp
      push_cast at this
      linarith
    have := mul_eq_zero.mp hcast
    rcases this with h | h
    · exact absurd h hgz
    · linarith
  have hcopZ : IsCoprime (e₁ : ℤ) (e₂ : ℤ) := Nat.isCoprime_iff_coprime.mpr hcop
  have hdvd : (e₁ : ℤ) ∣ (e₂ : ℤ) * ((p'.2 : ℤ) - p.2) := ⟨(p.1 : ℤ) - p'.1, hZ.symm⟩
  have hdvd2 : (e₁ : ℤ) ∣ ((p'.2 : ℤ) - p.2) := hcopZ.dvd_of_dvd_mul_left hdvd
  have hlt : |((p'.2 : ℤ) - p.2)| < (e₁ : ℤ) := by
    have h1 : (p.2 : ℤ) < (r : ℤ) := by exact_mod_cast hp.2
    have h2 : (p'.2 : ℤ) < (r : ℤ) := by exact_mod_cast hp'.2
    have h3 : (r : ℤ) ≤ (e₁ : ℤ) := by exact_mod_cast hr
    rw [abs_lt]
    constructor <;> [linarith [Int.natCast_nonneg p.2, Int.natCast_nonneg p'.2];
      linarith [Int.natCast_nonneg p.2, Int.natCast_nonneg p'.2]]
  have hj : (p'.2 : ℤ) - p.2 = 0 := Int.eq_zero_of_abs_lt_dvd hdvd2 hlt
  have hj' : p.2 = p'.2 := by
    have : (p.2 : ℤ) = (p'.2 : ℤ) := by linarith
    exact_mod_cast this
  have hi : (p.1 : ℤ) = (p'.1 : ℤ) := by
    have he1z : (0 : ℤ) < (e₁ : ℤ) := by exact_mod_cast he₁
    have : (e₁ : ℤ) * ((p.1 : ℤ) - p'.1) = 0 := by
      rw [hZ, hj']
      ring
    rcases mul_eq_zero.mp this with h | h
    · exact absurd h (ne_of_gt he1z)
    · linarith
  have hi' : p.1 = p'.1 := by exact_mod_cast hi
  exact Prod.ext hi' hj'

/-! ## The indexed family of witnesses -/

/-- The witness attached to the index `i = (t, g, e₁, e₂)` and the length parameter `k`:
when `e₁ = e₂ = 1` (parallel progressions) it is the `(2k-1)`-term progression with
difference `g`; otherwise it is the `k × min(Q,k)` block with `Q = max e₁ e₂`, the larger
cofactor being used for the *rows* so that the block is nondegenerate. -/
def optWitness (k : ℕ) (i : ℕ × ℕ × ℕ × ℕ) : Finset ℕ :=
  if max i.2.2.1 i.2.2.2 = 1 then apF i.1 i.2.1 (2 * k - 1)
  else blockWitness i.1 (i.2.1 * max i.2.2.1 i.2.2.2) (i.2.1 * min i.2.2.1 i.2.2.2) k
        (min (max i.2.2.1 i.2.2.2) k)

/-- The guaranteed size of `optWitness`. -/
def optLen (k : ℕ) (i : ℕ × ℕ × ℕ × ℕ) : ℕ :=
  if max i.2.2.1 i.2.2.2 = 1 then 2 * k - 1 else k * min (max i.2.2.1 i.2.2.2) k

lemma coprime_max_min {e₁ e₂ : ℕ} (hcop : Nat.Coprime e₁ e₂) :
    Nat.Coprime (max e₁ e₂) (min e₁ e₂) := by
  rcases le_total e₁ e₂ with h | h
  · rw [max_eq_right h, min_eq_left h]; exact hcop.symm
  · rw [max_eq_left h, min_eq_right h]; exact hcop

/-- **The witness really is large.**  Coprimality of the cofactors makes the block
nondegenerate, so `optWitness k i` has at least `optLen k i` elements. -/
lemma optLen_le_card_optWitness {k t g e₁ e₂ : ℕ} (hg : 0 < g) (he₁ : 0 < e₁)
    (hcop : Nat.Coprime e₁ e₂) :
    optLen k (t, g, e₁, e₂) ≤ (optWitness k (t, g, e₁, e₂)).card := by
  rw [optLen, optWitness]
  dsimp only
  split_ifs with h
  · rw [card_apF _ hg]
  · have hQ : 0 < max e₁ e₂ := lt_of_lt_of_le he₁ (le_max_left _ _)
    rw [card_blockWitness hg hQ (coprime_max_min hcop) (min_le_left _ _)]

/-- **The witness sits inside every sumset it is meant to certify.** -/
lemma optWitness_subset_add {k K a b g e₁ e₂ : ℕ} (hk : 2 ≤ k) (hkK : k ≤ K)
    (he₁ : 0 < e₁) (he₂ : 0 < e₂) :
    optWitness k (a + b, g, e₁, e₂) ⊆ apF a (g * e₁) K + apF b (g * e₂) K := by
  rw [optWitness]
  dsimp only
  split_ifs with h
  · have h1 : e₁ = 1 := by omega
    have h2 : e₂ = 1 := by omega
    subst h1; subst h2
    simp only [mul_one]
    exact (apF_mono _ _ (by omega)).trans (apF_two_sub_one_subset_add (by omega))
  · rcases le_total e₁ e₂ with hle | hle
    · rw [max_eq_right hle, min_eq_left hle]
      exact blockWitness_swap_subset_add hkK (le_trans (min_le_right _ _) hkK)
    · rw [max_eq_left hle, min_eq_right hle]
      exact blockWitness_subset_add hkK (le_trans (min_le_right _ _) hkK)

/-! ## The index set, sliced by the size of the larger cofactor -/

/-- Indices `(t, g, e₁, e₂)` with `t < n`, `g Q ≤ n`, `max e₁ e₂ = Q` and `e₁, e₂` coprime. -/
def idxQ (n Q : ℕ) : Finset (ℕ × ℕ × ℕ × ℕ) :=
  (range n) ×ˢ ((Icc 1 (n / Q)) ×ˢ
    (((Icc 1 Q) ×ˢ (Icc 1 Q)).filter (fun p => max p.1 p.2 = Q ∧ Nat.Coprime p.1 p.2)))

lemma mem_idxQ {n Q t g e₁ e₂ : ℕ} :
    (t, g, e₁, e₂) ∈ idxQ n Q ↔
      (t < n ∧ 1 ≤ g ∧ g ≤ n / Q) ∧ (1 ≤ e₁ ∧ e₁ ≤ Q) ∧ (1 ≤ e₂ ∧ e₂ ≤ Q) ∧
        max e₁ e₂ = Q ∧ Nat.Coprime e₁ e₂ := by
  simp only [idxQ, Finset.mem_product, Finset.mem_filter, Finset.mem_Icc, Finset.mem_range]
  tauto

/-- Each slice has at most `2n²` indices: `n` choices of `t`, at most `n/Q` of `g`, and at
most `2Q` coprime pairs with maximum `Q`. -/
lemma card_idxQ_le (n Q : ℕ) : (idxQ n Q).card ≤ 2 * (n * n) := by
  classical
  set F : Finset (ℕ × ℕ) :=
    ((Icc 1 Q) ×ˢ (Icc 1 Q)).filter (fun p => max p.1 p.2 = Q ∧ Nat.Coprime p.1 p.2) with hF
  have hFcard : F.card ≤ 2 * Q := by
    have hsub : F ⊆ ({Q} ×ˢ (Icc 1 Q)) ∪ ((Icc 1 Q) ×ˢ {Q}) := by
      intro p hp
      rw [hF, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc, Finset.mem_Icc] at hp
      rw [Finset.mem_union, Finset.mem_product, Finset.mem_product, Finset.mem_singleton,
        Finset.mem_singleton, Finset.mem_Icc, Finset.mem_Icc]
      obtain ⟨⟨h1, h2⟩, h3, -⟩ := hp
      rcases max_cases p.1 p.2 with ⟨he, -⟩ | ⟨he, -⟩
      · exact Or.inl ⟨by omega, h2⟩
      · exact Or.inr ⟨h1, by omega⟩
    calc F.card ≤ (({Q} ×ˢ (Icc 1 Q)) ∪ ((Icc 1 Q) ×ˢ {Q})).card := Finset.card_le_card hsub
      _ ≤ ({Q} ×ˢ (Icc 1 Q)).card + ((Icc 1 Q) ×ˢ {Q}).card := Finset.card_union_le _ _
      _ = 2 * Q := by
          simp [Nat.card_Icc]
          omega
  have hdiv : n / Q * Q ≤ n := Nat.div_mul_le_self n Q
  calc (idxQ n Q).card = n * ((n / Q) * F.card) := by
        rw [idxQ, Finset.card_product, Finset.card_product, Finset.card_range, Nat.card_Icc, hF]
        simp
    _ ≤ n * ((n / Q) * (2 * Q)) := by
        exact Nat.mul_le_mul_left _ (Nat.mul_le_mul_left _ hFcard)
    _ = 2 * (n * ((n / Q) * Q)) := by ring
    _ ≤ 2 * (n * n) := by
        exact Nat.mul_le_mul_left _ (Nat.mul_le_mul_left _ hdiv)

/-- The whole index set: all slices `Q = 1, …, n`. -/
def idxAll (n : ℕ) : Finset ((_ : ℕ) × (ℕ × ℕ × ℕ × ℕ)) := (Icc 1 n).sigma (idxQ n)

/-- **Every relevant triple is indexed.**  If `0 < d₁, d₂`, `t < n` and both differences are
at most `n`, then `(t, d₁, d₂)` occurs in the index set, via `g = gcd d₁ d₂`. -/
lemma exists_mem_idxAll {n t d₁ d₂ : ℕ} (h1 : 0 < d₁) (h2 : 0 < d₂) (ht : t < n)
    (hd₁ : d₁ ≤ n) (hd₂ : d₂ ≤ n) :
    ∃ Q g e₁ e₂, (⟨Q, (t, g, e₁, e₂)⟩ : (_ : ℕ) × (ℕ × ℕ × ℕ × ℕ)) ∈ idxAll n ∧
      0 < g ∧ 0 < e₁ ∧ 0 < e₂ ∧ Nat.Coprime e₁ e₂ ∧ d₁ = g * e₁ ∧ d₂ = g * e₂ := by
  set g := Nat.gcd d₁ d₂ with hg
  have hgpos : 0 < g := Nat.gcd_pos_of_pos_left _ h1
  set e₁ := d₁ / g with he₁
  set e₂ := d₂ / g with he₂
  have hd1 : d₁ = g * e₁ := (Nat.mul_div_cancel' (Nat.gcd_dvd_left d₁ d₂)).symm
  have hd2 : d₂ = g * e₂ := (Nat.mul_div_cancel' (Nat.gcd_dvd_right d₁ d₂)).symm
  have he1pos : 0 < e₁ := by
    rcases Nat.eq_zero_or_pos e₁ with h | h
    · rw [h, mul_zero] at hd1; omega
    · exact h
  have he2pos : 0 < e₂ := by
    rcases Nat.eq_zero_or_pos e₂ with h | h
    · rw [h, mul_zero] at hd2; omega
    · exact h
  have hcop : Nat.Coprime e₁ e₂ := Nat.coprime_div_gcd_div_gcd hgpos
  set Q := max e₁ e₂ with hQ
  have hQpos : 0 < Q := lt_of_lt_of_le he1pos (le_max_left _ _)
  have hgQ : g * Q ≤ n := by
    rcases le_total e₁ e₂ with h | h
    · rw [hQ, max_eq_right h, ← hd2]; exact hd₂
    · rw [hQ, max_eq_left h, ← hd1]; exact hd₁
  refine ⟨Q, g, e₁, e₂, ?_, hgpos, he1pos, he2pos, hcop, hd1, hd2⟩
  rw [idxAll, Finset.mem_sigma]
  refine ⟨?_, ?_⟩
  · rw [Finset.mem_Icc]
    exact ⟨hQpos, le_trans (Nat.le_mul_of_pos_left _ hgpos) hgQ⟩
  · rw [mem_idxQ]
    refine ⟨⟨ht, hgpos, ?_⟩, ⟨he1pos, le_max_left _ _⟩, ⟨he2pos, le_max_right _ _⟩, rfl, hcop⟩
    exact (Nat.le_div_iff_mul_le hQpos).2 hgQ

/-! ## The union bound over all slices -/

/-- Geometric tail: for `0 ≤ y ≤ 1/2` the sum `∑_{Q=2}^{N} y^Q` never exceeds `2y²`. -/
lemma geom_tail_le (y : ℝ) (hy0 : 0 ≤ y) (hy : 2 * y ≤ 1) (N : ℕ) :
    ∑ Q ∈ Icc 2 N, y ^ Q ≤ 2 * y ^ 2 := by
  rcases Nat.lt_or_ge N 1 with h | h
  · interval_cases N
    · simp; positivity
  · have key : ∀ M, 1 ≤ M → ∑ Q ∈ Icc 2 M, y ^ Q + 2 * y ^ (M + 1) ≤ 2 * y ^ 2 := by
      intro M hM
      induction M, hM using Nat.le_induction with
      | base => simp
      | succ M hM ih =>
        rw [Finset.sum_Icc_succ_top (by omega)]
        have h1 : 2 * y ^ (M + 1 + 1) ≤ y ^ (M + 1) := by
          have hrw : y ^ (M + 1 + 1) = y ^ (M + 1) * y := by ring
          nlinarith [pow_nonneg hy0 (M + 1)]
        linarith
    have := key N h
    nlinarith [pow_nonneg hy0 (N + 1)]

/-- **The weighted union bound.**  With `x = m/n ∈ [0,1]` and `2x^k ≤ 1`, the total first
moment of the family `optWitness k` over all indices is at most
`2n²x^{2k-1} + 4n²x^{2k} + 2n³x^{k²}`.

The three terms are: the parallel case `d₁ = d₂` (an `n²` family of `(2k-1)`-point
progressions), the slices `2 ≤ Q ≤ k` (geometrically decaying blocks of size `kQ`), and the
slices `Q > k` (at most `n` of them, each with a full `k × k` block). -/
lemma sum_idxAll_le {n k : ℕ} {x : ℝ} (hx0 : 0 ≤ x) (hy : 2 * x ^ k ≤ 1) :
    ∑ i ∈ idxAll n, x ^ (optLen k i.2)
      ≤ 2 * (n : ℝ) ^ 2 * x ^ (2 * k - 1) + 4 * (n : ℝ) ^ 2 * x ^ (2 * k)
        + 2 * (n : ℝ) ^ 3 * x ^ (k * k) := by
  classical
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · have hemp : idxAll 0 = ∅ := by
      rw [idxAll]
      simp
    rw [hemp]
    simp
  rw [idxAll, Finset.sum_sigma]
  set f : ℕ → ℝ := fun Q => if Q = 1 then x ^ (2 * k - 1) else x ^ (k * min Q k) with hf
  have hfnonneg : ∀ Q, 0 ≤ f Q := by
    intro Q; rw [hf]; dsimp only; split_ifs <;> positivity
  have hinner : ∀ Q ∈ Icc 1 n,
      ∑ i ∈ idxQ n Q, x ^ (optLen k i) ≤ 2 * (n : ℝ) ^ 2 * f Q := by
    intro Q _
    have hterm : ∀ i ∈ idxQ n Q, x ^ (optLen k i) = f Q := by
      rintro ⟨t, g, e₁, e₂⟩ hi
      rw [mem_idxQ] at hi
      have hmax : max e₁ e₂ = Q := hi.2.2.2.1
      simp only [optLen, hf, hmax]
      split_ifs <;> rfl
    rw [Finset.sum_congr rfl hterm, Finset.sum_const, nsmul_eq_mul]
    refine mul_le_mul_of_nonneg_right ?_ (hfnonneg Q)
    have hc : ((idxQ n Q).card : ℝ) ≤ 2 * ((n : ℝ) * n) := by
      exact_mod_cast card_idxQ_le n Q
    nlinarith [hc]
  refine le_trans (Finset.sum_le_sum hinner) ?_
  have hIcc : Icc 1 n = insert 1 (Icc 2 n) := by
    ext q; simp only [Finset.mem_Icc, Finset.mem_insert]; omega
  have h1not : (1 : ℕ) ∉ Icc 2 n := by simp
  rw [hIcc, Finset.sum_insert h1not]
  have hf1 : f 1 = x ^ (2 * k - 1) := by rw [hf]; simp
  have hsplit : ∀ Q ∈ Icc 2 n, 2 * (n : ℝ) ^ 2 * f Q
      ≤ 2 * (n : ℝ) ^ 2 * (x ^ (k * k) + (x ^ k) ^ Q) := by
    intro Q hQ
    rw [Finset.mem_Icc] at hQ
    have hQ1 : Q ≠ 1 := by omega
    have hstep : f Q ≤ x ^ (k * k) + (x ^ k) ^ Q := by
      rw [hf]; dsimp only; rw [if_neg hQ1]
      rcases min_cases Q k with ⟨he, -⟩ | ⟨he, -⟩
      · rw [he, pow_mul]
        have : (0 : ℝ) ≤ x ^ (k * k) := by positivity
        linarith
      · rw [he]
        have : (0 : ℝ) ≤ (x ^ k) ^ Q := by positivity
        linarith
    have hpos : (0 : ℝ) ≤ 2 * (n : ℝ) ^ 2 := by positivity
    exact mul_le_mul_of_nonneg_left hstep hpos
  have hstep2 : 2 * (n : ℝ) ^ 2 * f 1 + ∑ Q ∈ Icc 2 n, 2 * (n : ℝ) ^ 2 * f Q
      ≤ 2 * (n : ℝ) ^ 2 * f 1
        + ∑ Q ∈ Icc 2 n, 2 * (n : ℝ) ^ 2 * (x ^ (k * k) + (x ^ k) ^ Q) := by
    have := Finset.sum_le_sum hsplit
    linarith
  refine le_trans hstep2 ?_
  rw [← Finset.mul_sum, Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul]
  have hcard : ((Icc 2 n).card : ℝ) ≤ (n : ℝ) := by
    have : (Icc 2 n).card ≤ n := by rw [Nat.card_Icc]; omega
    exact_mod_cast this
  have hgeom : ∑ Q ∈ Icc 2 n, (x ^ k) ^ Q ≤ 2 * (x ^ k) ^ 2 :=
    geom_tail_le (x ^ k) (by positivity) hy n
  have hkk : (x ^ k) ^ 2 = x ^ (2 * k) := by
    rw [← pow_mul, mul_comm]
  have hxkk : (0 : ℝ) ≤ x ^ (k * k) := by positivity
  have hn0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  rw [hf1]
  have hstep1 : ((Icc 2 n).card : ℝ) * x ^ (k * k) ≤ (n : ℝ) * x ^ (k * k) :=
    mul_le_mul_of_nonneg_right hcard hxkk
  nlinarith [hgeom, hstep1, sq_nonneg ((n : ℝ))]

/-! ## The counting theorem with the optimal exponent -/

/-- **Progression-sumset avoidance at the optimal exponent, counting form.**
If `m ≤ n`, `2 ≤ k`, `2(m/n)^k ≤ 1` and

`2n²(m/n)^{2k-1} + 4n²(m/n)^{2k} + 2n³(m/n)^{k²} < 1`,

then some `m`-element `S ⊆ [n]` contains no sumset `apF a d₁ K + apF b d₂ K` of two
progressions of common length `K ≥ k` with positive common differences.

The decisive term is the first one: for `m = δn` it forces only `2k - 1 > 2 log n/log(1/δ)`,
i.e. `k > log n / log(1/δ)`, which is exactly the greedy lower bound.  The other two terms
come from the non-parallel slices and are negligible. -/
theorem exists_card_eq_avoiding_block {n m k : ℕ} (hmn : m ≤ n) (hm : 1 ≤ m) (hk : 2 ≤ k)
    (hy : 2 * ((m : ℝ) / n) ^ k ≤ 1)
    (hcond : 2 * (n : ℝ) ^ 2 * ((m : ℝ) / n) ^ (2 * k - 1)
      + 4 * (n : ℝ) ^ 2 * ((m : ℝ) / n) ^ (2 * k)
      + 2 * (n : ℝ) ^ 3 * ((m : ℝ) / n) ^ (k * k) < 1) :
    ∃ S ⊆ range n, S.card = m ∧ ∀ a b d₁ d₂ K : ℕ, 0 < d₁ → 0 < d₂ → k ≤ K →
      ¬ (apF a d₁ K + apF b d₂ K ⊆ S) := by
  classical
  have hn : 1 ≤ n := le_trans hm hmn
  have hx0 : (0 : ℝ) ≤ (m : ℝ) / n := by positivity
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_avoiding_weighted (n := n) (m := m) (idxAll n)
      (fun i => optWitness k i.2) (fun i => optLen k i.2)
      (fun i hi => by
        obtain ⟨Q, t, g, e₁, e₂⟩ := i
        rw [idxAll, Finset.mem_sigma, mem_idxQ] at hi
        exact optLen_le_card_optWitness (by omega) (by omega) hi.2.2.2.2.2)
      hmn hm
      (lt_of_le_of_lt (sum_idxAll_le hx0 hy) hcond)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro a b d₁ d₂ K hd₁ hd₂ hkK hsub
  have hK : 2 ≤ K := le_trans hk hkK
  have hmem1 : a + b ∈ apF a d₁ K + apF b d₂ K :=
    Finset.add_mem_add (self_mem_apF (by omega)) (self_mem_apF (by omega))
  have hmem2 : (a + d₁) + b ∈ apF a d₁ K + apF b d₂ K :=
    Finset.add_mem_add (second_mem_apF (by omega)) (self_mem_apF (by omega))
  have hmem3 : a + (b + d₂) ∈ apF a d₁ K + apF b d₂ K :=
    Finset.add_mem_add (self_mem_apF (by omega)) (second_mem_apF (by omega))
  have ht : a + b < n := by simpa using hSsub (hsub hmem1)
  have ht2 : (a + d₁) + b < n := by simpa using hSsub (hsub hmem2)
  have ht3 : a + (b + d₂) < n := by simpa using hSsub (hsub hmem3)
  obtain ⟨Q, g, e₁, e₂, hmemI, hg, he₁, he₂, -, hgd₁, hgd₂⟩ :=
    exists_mem_idxAll (n := n) (t := a + b) hd₁ hd₂ ht (by omega) (by omega)
  refine hSno ⟨Q, (a + b, g, e₁, e₂)⟩ hmemI ?_
  have hsubw : optWitness k (a + b, g, e₁, e₂) ⊆ apF a d₁ K + apF b d₂ K := by
    rw [hgd₁, hgd₂]
    exact optWitness_subset_add hk hkK he₁ he₂
  exact hsubw.trans hsub

/-! ## The analytic form: the constant `1` -/

/-- If `log A + log B ≤ L log(1/x)` then `A x^L ≤ 1/B`. -/
lemma real_pow_bound {x A B : ℝ} (hx0 : 0 < x) (hA : 0 < A) (hB : 0 < B) (L : ℕ)
    (h : Real.log A + Real.log B ≤ (L : ℝ) * Real.log (1 / x)) : A * x ^ L ≤ 1 / B := by
  have hpos : (0 : ℝ) < A * x ^ L := by positivity
  have hb : (0 : ℝ) < 1 / B := by positivity
  have hlx : Real.log (1 / x) = -Real.log x := by rw [one_div, Real.log_inv]
  have h1 : Real.log (A * x ^ L) ≤ Real.log (1 / B) := by
    rw [Real.log_mul (ne_of_gt hA) (by positivity), Real.log_pow, one_div, Real.log_inv]
    rw [hlx] at h
    linarith
  calc A * x ^ L = Real.exp (Real.log (A * x ^ L)) := (Real.exp_log hpos).symm
    _ ≤ Real.exp (Real.log (1 / B)) := Real.exp_le_exp.2 h1
    _ = 1 / B := Real.exp_log hb

/-- **Progression-sumset avoidance with constant `1`.**  For `0 < δ < 1`, `ε > 0` and `n`
large enough (quantified by the three explicit inequalities), there is a `δ`-dense set
`S ⊆ [n]` containing no sumset of two arithmetic progressions of common length at least
`(1 + ε) log n / log (1/δ)`. -/
theorem exists_dense_avoiding_ap_sumsets_one (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {n : ℕ}
    (hn8 : 8 ≤ n) {ε : ℝ} (hε : 0 < ε)
    (hbig : 1 / (δ * n) ≤ (ε / (2 * (1 + ε))) * Real.log (1 / δ))
    (hlog1 : Real.log (1 / δ) + Real.log 16 ≤ ε * Real.log n)
    (hlog2 : 4 * Real.log (1 / δ) ≤ Real.log n) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧ ∀ a b d₁ d₂ K : ℕ, 0 < d₁ → 0 < d₂ →
      (1 + ε) * (Real.log n / Real.log (1 / δ)) ≤ K → ¬ (apF a d₁ K + apF b d₂ K ⊆ S) := by
  set lam : ℝ := Real.log (1 / δ) with hlamdef
  have hlam : 0 < lam := by
    rw [hlamdef]; simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  have hlamneg : lam = -Real.log δ := by rw [hlamdef, one_div, Real.log_inv]
  have hn8R : (8 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn8
  have hn0 : (0 : ℝ) < n := by linarith
  have hlog8 : Real.log 8 ≤ Real.log n := Real.log_le_log (by norm_num) hn8R
  have hlog8pos : (0 : ℝ) < Real.log 8 := Real.log_pos (by norm_num)
  have hlogn0 : 0 < Real.log n := lt_of_lt_of_le hlog8pos hlog8
  -- the density and the sample size
  set m : ℕ := ⌈δ * (n : ℝ)⌉₊ with hmdef
  have hm1 : 1 ≤ m := Nat.one_le_ceil_iff.2 (by positivity)
  have hmn : m ≤ n := Nat.ceil_le.2 (by nlinarith [hn0, h1])
  have hmR1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm1
  have hmge : δ * (n : ℝ) ≤ (m : ℝ) := Nat.le_ceil _
  have hmlt : (m : ℝ) < δ * n + 1 := Nat.ceil_lt_add_one (by positivity)
  set x : ℝ := (m : ℝ) / n with hxdef
  have hx0 : 0 < x := by rw [hxdef]; positivity
  set u : ℝ := Real.log (1 / x) with hudef
  have hu_eq : u = Real.log n - Real.log m := by
    rw [hudef, hxdef, one_div, Real.log_inv, Real.log_div (by positivity) (by positivity)]
    ring
  -- the rounding buffer
  set θ : ℝ := ε / (2 * (1 + ε)) with hθdef
  have hθ0 : 0 < θ := by rw [hθdef]; positivity
  have hθhalf : θ < 1 / 2 := by
    rw [hθdef, div_lt_div_iff₀ (by positivity) (by norm_num)]
    linarith
  have hu_low : (1 - θ) * lam ≤ u := by
    have hstep1 : Real.log m ≤ Real.log (δ * n + 1) :=
      Real.log_le_log (by positivity) (le_of_lt hmlt)
    have hfac : δ * (n : ℝ) + 1 = (δ * n) * (1 + 1 / (δ * n)) := by field_simp
    have hstep2 : Real.log (δ * n + 1) = Real.log (δ * n) + Real.log (1 + 1 / (δ * n)) := by
      rw [hfac, Real.log_mul (by positivity) (by positivity)]
    have hstep3 : Real.log (1 + 1 / (δ * n)) ≤ 1 / (δ * n) := by
      have := Real.log_le_sub_one_of_pos (x := 1 + 1 / (δ * n)) (by positivity)
      linarith
    have hstep4 : Real.log (δ * n) = Real.log n - lam := by
      rw [Real.log_mul (ne_of_gt h0) (ne_of_gt hn0), hlamneg]; ring
    rw [hu_eq]
    linarith [hbig, hstep1, hstep2, hstep3, hstep4]
  have hu_up : u ≤ lam := by
    have hδx : δ ≤ x := by
      rw [hxdef, le_div_iff₀ hn0]
      exact hmge
    have hlogx : Real.log δ ≤ Real.log x := Real.log_le_log h0 hδx
    rw [hudef, one_div, Real.log_inv, hlamneg]
    linarith
  have hu0 : 0 < u := by
    have hp : 0 < (1 - θ) * lam := mul_pos (by linarith) hlam
    linarith
  -- the length parameter
  set R : ℝ := Real.log n / lam with hRdef
  have hRlam : R * lam = Real.log n := div_mul_cancel₀ _ (ne_of_gt hlam)
  have hR4 : (4 : ℝ) ≤ R := by rw [hRdef, le_div_iff₀ hlam]; linarith
  set k : ℕ := ⌈(1 + ε) * R⌉₊ with hkdef
  have hkR : (1 + ε) * R ≤ (k : ℝ) := Nat.le_ceil _
  have hk4R : (4 : ℝ) ≤ (k : ℝ) := by
    have hp : 0 ≤ ε * R := mul_nonneg (le_of_lt hε) (by linarith)
    nlinarith [hkR]
  have hk4 : 4 ≤ k := by exact_mod_cast hk4R
  have hku : (1 + ε / 2) * Real.log n ≤ (k : ℝ) * u := by
    have h_a : (1 + ε) * R * u ≤ (k : ℝ) * u := mul_le_mul_of_nonneg_right hkR (le_of_lt hu0)
    have h_b : (1 + ε) * R * ((1 - θ) * lam) ≤ (1 + ε) * R * u :=
      mul_le_mul_of_nonneg_left hu_low (by positivity)
    have hεθ : (1 + ε) * (1 - θ) = 1 + ε / 2 := by
      rw [hθdef]; field_simp; ring
    have h_c : (1 + ε) * R * ((1 - θ) * lam) = (1 + ε / 2) * Real.log n := by
      calc (1 + ε) * R * ((1 - θ) * lam) = ((1 + ε) * (1 - θ)) * (R * lam) := by ring
        _ = (1 + ε / 2) * Real.log n := by rw [hεθ, hRlam]
    linarith
  have hkulogn : Real.log n ≤ (k : ℝ) * u := by
    have hexp : (1 + ε / 2) * Real.log n = Real.log n + ε / 2 * Real.log n := by ring
    have hp : 0 ≤ ε / 2 * Real.log n := by positivity
    linarith [hku]
  -- the three first-moment estimates
  have hlog2_4 : Real.log 2 + Real.log 4 = Real.log 8 := by
    rw [← Real.log_mul (by norm_num) (by norm_num)]; norm_num
  have hlog4_4 : Real.log 4 + Real.log 4 = Real.log 16 := by
    rw [← Real.log_mul (by norm_num) (by norm_num)]; norm_num
  have hlog8_16 : Real.log 8 ≤ Real.log 16 := Real.log_le_log (by norm_num) (by norm_num)
  have hy : 2 * x ^ k ≤ 1 := by
    have := real_pow_bound hx0 (A := 2) (B := 1) (by norm_num) (by norm_num) k ?_
    · simpa using this
    · rw [Real.log_one, ← hudef]
      have hl2 : Real.log 2 ≤ Real.log 8 := Real.log_le_log (by norm_num) (by norm_num)
      linarith
  have hcast : ((2 * k - 1 : ℕ) : ℝ) = 2 * (k : ℝ) - 1 := by
    have hle : 1 ≤ 2 * k := by omega
    push_cast [Nat.cast_sub hle]; ring
  have hi : 2 * (n : ℝ) ^ 2 * x ^ (2 * k - 1) ≤ 1 / 4 := by
    refine real_pow_bound hx0 (by positivity) (by norm_num) _ ?_
    rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow, ← hudef, hcast]
    push_cast
    linarith [hku, hu_up, hlog1, hlog2_4, hlog8_16]
  have hii : 4 * (n : ℝ) ^ 2 * x ^ (2 * k) ≤ 1 / 4 := by
    refine real_pow_bound hx0 (by positivity) (by norm_num) _ ?_
    rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow, ← hudef]
    push_cast
    linarith [hku, hlog1, hlog4_4, hlam]
  have hiii : 2 * (n : ℝ) ^ 3 * x ^ (k * k) ≤ 1 / 4 := by
    refine real_pow_bound hx0 (by positivity) (by norm_num) _ ?_
    rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow, ← hudef]
    push_cast
    have hA : (k : ℝ) * Real.log n ≤ (k : ℝ) * ((k : ℝ) * u) :=
      mul_le_mul_of_nonneg_left hkulogn (by linarith)
    have hB : 4 * Real.log n ≤ (k : ℝ) * Real.log n :=
      mul_le_mul_of_nonneg_right hk4R (le_of_lt hlogn0)
    linarith [hA, hB, hlog8, hlog2_4]
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_avoiding_block hmn hm1 (by omega) hy (by linarith)
  refine ⟨S, hSsub, ?_, ?_⟩
  · rw [hScard]; exact hmge
  · intro a b d₁ d₂ K hd₁ hd₂ hK
    exact hSno a b d₁ d₂ K hd₁ hd₂ (Nat.ceil_le.2 hK)

/-- **Asymptotic form: the constant `1`.**  For every `0 < δ < 1` and every `ε > 0`, for all
large `n` there is a `δ`-dense `S ⊆ [n]` containing no sumset of two arithmetic progressions
of common length at least `(1 + ε) log n / log (1/δ)`.

Together with `DenseSumsetLower.eventually_exists_sumset_sharp` (every `δ`-dense set does
contain a sumset `A + B` with `|A| = |B| = ⌊c log n⌋` whenever `c log(1/δ) < 1`), this pins
the extremal constant for progression sumsets at exactly `1`. -/
theorem eventually_avoiding_ap_sumsets_one (δ : ℝ) (h0 : 0 < δ) (h1 : δ < 1) {ε : ℝ}
    (hε : 0 < ε) :
    ∀ᶠ n : ℕ in atTop, ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ a b d₁ d₂ K : ℕ, 0 < d₁ → 0 < d₂ →
        (1 + ε) * (Real.log n / Real.log (1 / δ)) ≤ K → ¬ (apF a d₁ K + apF b d₂ K ⊆ S) := by
  set lam : ℝ := Real.log (1 / δ) with hlamdef
  have hlam : 0 < lam := by
    rw [hlamdef]; simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  set θ : ℝ := ε / (2 * (1 + ε)) with hθdef
  have hθ0 : 0 < θ := by rw [hθdef]; positivity
  rw [eventually_atTop]
  refine ⟨max 8 (max ⌈1 / (δ * (θ * lam))⌉₊
      (max ⌈Real.exp ((lam + Real.log 16) / ε)⌉₊ ⌈Real.exp (4 * lam)⌉₊)), fun n hn => ?_⟩
  have hn8 : 8 ≤ n := le_trans (le_max_left _ _) hn
  have hA : ⌈1 / (δ * (θ * lam))⌉₊ ≤ n := le_trans (le_trans (le_max_left _ _) (le_max_right 8 _)) hn
  have hB : ⌈Real.exp ((lam + Real.log 16) / ε)⌉₊ ≤ n :=
    le_trans (le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) (le_max_right 8 _)) hn
  have hC : ⌈Real.exp (4 * lam)⌉₊ ≤ n :=
    le_trans (le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) (le_max_right 8 _)) hn
  have hn8R : (8 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn8
  have hn0 : (0 : ℝ) < n := by linarith
  have hbig : 1 / (δ * n) ≤ θ * lam := by
    have h2n : 1 / (δ * (θ * lam)) ≤ (n : ℝ) := le_trans (Nat.le_ceil _) (by exact_mod_cast hA)
    rw [div_le_iff₀ (by positivity)] at h2n
    rw [div_le_iff₀ (by positivity)]
    nlinarith
  have hlog1 : lam + Real.log 16 ≤ ε * Real.log n := by
    have hexp : Real.exp ((lam + Real.log 16) / ε) ≤ (n : ℝ) :=
      le_trans (Nat.le_ceil _) (by exact_mod_cast hB)
    have hlog : (lam + Real.log 16) / ε ≤ Real.log n := (Real.le_log_iff_exp_le hn0).2 hexp
    rw [div_le_iff₀ hε] at hlog
    linarith
  have hlog2 : 4 * lam ≤ Real.log n := by
    have hexp : Real.exp (4 * lam) ≤ (n : ℝ) := le_trans (Nat.le_ceil _) (by exact_mod_cast hC)
    exact (Real.le_log_iff_exp_le hn0).2 hexp
  exact exists_dense_avoiding_ap_sumsets_one δ h0 h1 hn8 hε hbig hlog1 hlog2

/-- **The extremal constant for progression sumsets is exactly `1`.**  Fix `0 < δ < 1`,
`ε > 0` and `c > 0` with `c log (1/δ) < 1`.  Then for all large `n`:

* *(lower bound)* every `S ⊆ [n]` with `|S| ≥ δ n` contains a sumset `A + B` with
  `|A| = |B| = ⌊c log n⌋`, and `c` may be taken arbitrarily close to `1/log(1/δ)`;
* *(upper bound)* some `S ⊆ [n]` with `|S| ≥ δ n` contains no sumset of two arithmetic
  progressions of common length at least `(1 + ε) log n / log (1/δ)`.

So for progression sumsets the threshold is `(1 + o(1)) log n / log (1/δ)`, improving the
constant `3` of `Bridges.DeltaDenseSumsetAvoidance` and the constant `3/2` of
`Bridges.DenseSumsetLower.Window`. -/
theorem threshold_window_optimal (δ c : ℝ) (h0 : 0 < δ) (h1 : δ < 1) (hc0 : 0 < c)
    (hc : c * Real.log (1 / δ) < 1) {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ n : ℕ in atTop,
      (∀ S : Finset ℕ, S ⊆ range n → δ * (n : ℝ) ≤ S.card →
        ∃ A B : Finset ℕ, A.card = ⌊c * Real.log n⌋₊ ∧ B.card = ⌊c * Real.log n⌋₊ ∧
          A + B ⊆ S) ∧
      (∃ S ⊆ range n, δ * n ≤ S.card ∧
        ∀ a b d₁ d₂ K : ℕ, 0 < d₁ → 0 < d₂ →
          (1 + ε) * (Real.log n / Real.log (1 / δ)) ≤ K →
          ¬ (apF a d₁ K + apF b d₂ K ⊆ S)) := by
  filter_upwards [eventually_exists_sumset_sharp h0 h1 hc0 hc,
    eventually_avoiding_ap_sumsets_one δ h0 h1 hε] with n hlow hup
  exact ⟨hlow, hup⟩

end DenseSumsetLower