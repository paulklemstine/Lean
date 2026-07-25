/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The slice rank method for sunflower-free families (Naslund–Sawin, 2017)

This file formalizes, *strictly bottom-up*, the slice-rank approach to bounding the size of a
3-sunflower-free family `𝓕 ⊆ 2^[n]`.  The development is split into four layers, each lemma is
tagged with the layer it belongs to and the more primitive results it uses, and **no** Layer 0/1/2
declaration references the Layer 3 main theorem (no circular dependencies).

## Mathematical outline

* **Slice rank.** A function `f : X × X × X → 𝔽` has *slice rank* `≤ r` if it is a sum of at most
  `r` rank-one "slices" `g(x)·h(y,z)`, `g(y)·h(x,z)`, or `g(z)·h(x,y)`.

* **Slice Rank Lemma (Tao, 2016).** A *diagonal* tensor `diagTensor c` (which is `c x` on the main
  diagonal `x = y = z` and `0` off it) has slice rank exactly the size of the support of `c`.  In
  particular any slice-rank witness of length `r` forces `#support ≤ r`.  (`diagTensor` direction
  used here: `diagTensor_support_card_le_sliceRank`.)

* **The Naslund–Sawin tensor.** For a family `𝓕` of subsets of `Fin n`, define over `𝔽₃ = ZMod 3`
  the per-coordinate factor `1 - (aᵢbᵢ + bᵢcᵢ + cᵢaᵢ)` (with `aᵢ, bᵢ, cᵢ ∈ {0,1}` the indicators of
  membership).  This factor is `0` exactly when a coordinate lies in *exactly two* of the three
  sets, and `1` otherwise.  Three distinct sets form a sunflower iff **no** coordinate lies in
  exactly two of them, so on a sunflower-free *antichain* the product tensor `TF 𝓕` vanishes off the
  diagonal and equals `1` on it, i.e. it is a diagonal tensor with support `𝓕`.

* **Bounding the slice rank.** By the Croot–Lev–Pach degree/pigeonhole argument the slice rank of
  `TF 𝓕` is at most `3 · Mbound n`, where `Mbound n` counts squarefree monomials of degree at most
  `2n/3`.

* **Main bound.** Combining the two: a uniform (hence antichain) sunflower-free family has size
  `≤ 3 · Mbound n`, and pigeonholing over the `n+1` possible cardinalities gives, for an arbitrary
  sunflower-free family, `#𝓕 ≤ (n+1) · 3 · Mbound n`.  Asymptotically `Mbound n = O(n^{-1/2}
  (3/2^{2/3})^n)`, giving the stated `K · n^{1/6} · (3/2^{2/3})^n` bound.

## Sorry inventory (genuinely hard sub-steps, all non-circular)

* `diagTensor_support_card_le_sliceRank` — the linear-algebra Slice Rank Lemma (Layer 1).
* `TF_offdiagonal_zero` — the sunflower-free ⇒ off-diagonal vanishing (Layer 2 combinatorics).
* `TF_sliceRank_le` — the Croot–Lev–Pach polynomial slice-rank bound (Layer 2).
* `Mbound_asymptotic` — Stirling asymptotics of the monomial count (Layer 3 analysis).
-/
import Mathlib

namespace Catalog.Combinatorics.SliceRankSunflowerFree

open scoped BigOperators
open Finset

/-! ## Layer 0 — Definitions -/

variable {F : Type*} [Field F] {X : Type*}

/-- **Layer 0.** A rank-one *slice*: a function `X×X×X → F` that factors as a function of one
coordinate times a function of the other two. -/
def IsSlice (s : X → X → X → F) : Prop :=
  (∃ (g : X → F) (h : X → X → F), s = fun x y z => g x * h y z) ∨
  (∃ (g : X → F) (h : X → X → F), s = fun x y z => g y * h x z) ∨
  (∃ (g : X → F) (h : X → X → F), s = fun x y z => g z * h x y)

/-- **Layer 0.** `SliceRankLE f r` : the function `f` is a sum of at most `r` rank-one slices. -/
def SliceRankLE (f : X → X → X → F) (r : ℕ) : Prop :=
  ∃ l : List (X → X → X → F),
    l.length ≤ r ∧ (∀ s ∈ l, IsSlice s) ∧
      f = fun x y z => (l.map (fun s => s x y z)).sum

/-- **Layer 0.** The diagonal tensor with diagonal `c`: value `c x` on `x = y = z`, else `0`. -/
def diagTensor [DecidableEq X] (c : X → F) : X → X → X → F :=
  fun x y z => if x = y ∧ y = z then c x else 0

/-- **Layer 0.** The support of the diagonal `c`. -/
def diagSupport [Fintype X] [DecidableEq X] [DecidableEq F] (c : X → F) : Finset X :=
  univ.filter (fun x => c x ≠ 0)

/-- **Layer 0.** A family `𝓕` of subsets of `Fin n` is *3-sunflower-free* if no three distinct
members have all pairwise intersections equal (equivalently, equal to the common triple
intersection). -/
def SunflowerFree {n : ℕ} (𝓕 : Finset (Finset (Fin n))) : Prop :=
  ∀ A ∈ 𝓕, ∀ B ∈ 𝓕, ∀ C ∈ 𝓕, A ≠ B → A ≠ C → B ≠ C →
    ¬ (A ∩ B = A ∩ C ∧ A ∩ C = B ∩ C)

/-! ## Layer 1 — Basic properties of slice rank -/

/-- **Layer 1** (depends on: nothing).  The zero tensor has slice rank `0`. -/
theorem sliceRankLE_zero : SliceRankLE (0 : X → X → X → F) 0 := by
  refine ⟨[], le_refl _, ?_, ?_⟩
  · intro s hs; simp at hs
  · funext x y z; simp

/-- **Layer 1** (depends on: nothing).  Monotonicity of the rank bound. -/
theorem SliceRankLE.mono {f : X → X → X → F} {r r' : ℕ} (h : SliceRankLE f r) (hr : r ≤ r') :
    SliceRankLE f r' := by
  obtain ⟨l, hlen, hslice, hf⟩ := h
  exact ⟨l, hlen.trans hr, hslice, hf⟩

/-- **Layer 1** (depends on: `SliceRankLE`).  Slice rank is *subadditive*: a sum of two tensors has
slice rank at most the sum of the individual ranks. -/
theorem sliceRankLE_add {f g : X → X → X → F} {r s : ℕ}
    (hf : SliceRankLE f r) (hg : SliceRankLE g s) : SliceRankLE (f + g) (r + s) := by
  obtain ⟨l₁, hlen₁, hslice₁, hf₁⟩ := hf
  obtain ⟨l₂, hlen₂, hslice₂, hg₂⟩ := hg
  refine ⟨l₁ ++ l₂, ?_, ?_, ?_⟩
  · simpa using Nat.add_le_add hlen₁ hlen₂
  · intro s' hs'
    rcases List.mem_append.1 hs' with h | h
    · exact hslice₁ _ h
    · exact hslice₂ _ h
  · funext x y z
    simp only [Pi.add_apply]
    rw [hf₁, hg₂]
    simp

/-- **Layer 1** (depends on: `diagTensor`, `diagSupport`).  **Slice Rank Lemma (Tao, 2016).**
A diagonal tensor whose diagonal has support `S` has slice rank at least `#S`; equivalently, any
slice-rank witness of length `r` forces `#S ≤ r`.  This is the core linear-algebra fact and is
proved *without* reference to any sunflower bound.  (Hard; left as `sorry`.) -/
theorem diagTensor_support_card_le_sliceRank [Fintype X] [DecidableEq X] [DecidableEq F]
    (c : X → F) {r : ℕ}
    (h : SliceRankLE (diagTensor c) r) : (diagSupport c).card ≤ r := by
  sorry

/-! ## Layer 2 — The Naslund–Sawin construction -/

variable {n : ℕ}

/-- **Layer 2** (depends on: nothing).  Indicator of membership `i ∈ A` as an element of `ZMod 3`. -/
def ind (A : Finset (Fin n)) (i : Fin n) : ZMod 3 := if i ∈ A then 1 else 0

/-- **Layer 2** (depends on: `ind`).  The Naslund–Sawin per-coordinate product tensor:
`∏ᵢ (1 - (aᵢbᵢ + bᵢcᵢ + cᵢaᵢ))` over `ZMod 3`. -/
def TFcore (A B C : Finset (Fin n)) : ZMod 3 :=
  ∏ i, (1 - (ind A i * ind B i + ind B i * ind C i + ind C i * ind A i))

/-- **Layer 2** (depends on: `TFcore`).  The tensor restricted to a family `𝓕`: it is `TFcore`
inside `𝓕 × 𝓕 × 𝓕` and `0` outside. -/
def TF (𝓕 : Finset (Finset (Fin n))) :
    Finset (Fin n) → Finset (Fin n) → Finset (Fin n) → ZMod 3 :=
  fun A B C => if A ∈ 𝓕 ∧ B ∈ 𝓕 ∧ C ∈ 𝓕 then TFcore A B C else 0

/-- **Layer 2** (depends on: `ind`).  Each `ind` value is idempotent (it is `0` or `1`). -/
theorem ind_sq (A : Finset (Fin n)) (i : Fin n) : ind A i * ind A i = ind A i := by
  unfold ind; split <;> simp

/-- **Layer 2** (depends on: `TFcore`, `ind_sq`).  On the diagonal the tensor is `1`:
each factor is `1 - 3·aᵢ² = 1` in `ZMod 3`. -/
theorem TFcore_diag (A : Finset (Fin n)) : TFcore A A A = 1 := by
  unfold TFcore
  apply Finset.prod_eq_one
  intro i _
  have h : ind A i * ind A i = ind A i := ind_sq A i
  rw [h]
  have : (ind A i + ind A i + ind A i) = 3 * ind A i := by ring
  rw [this]
  have : (3 : ZMod 3) = 0 := by decide
  rw [this]; ring

/-- The diagonal coefficient function attached to a family `𝓕`. -/
def famDiag (𝓕 : Finset (Finset (Fin n))) : Finset (Fin n) → ZMod 3 :=
  fun A => if A ∈ 𝓕 then 1 else 0

/-- **Layer 2** (depends on: `famDiag`).  The support of `famDiag 𝓕` is exactly `𝓕`. -/
theorem diagSupport_famDiag (𝓕 : Finset (Finset (Fin n))) :
    diagSupport (famDiag 𝓕) = 𝓕 := by
  ext A
  unfold diagSupport famDiag
  simp only [mem_filter, mem_univ, true_and, ne_eq, ite_eq_right_iff, one_ne_zero, imp_false,
    Decidable.not_not]

/-- **Layer 2** (depends on: `SunflowerFree`, `TFcore`, `ind`, `Finset.eq_of_subset_of_card_le`).
**Off-diagonal vanishing.**  On a sunflower-free *uniform* (hence antichain) family,
`TFcore A B C = 0` unless `A = B = C`.  This is the combinatorial heart: for three members that are
not all equal there is a coordinate lying in exactly two of them, which makes the corresponding
factor `1 - (aᵢbᵢ + bᵢcᵢ + cᵢaᵢ) = 1 - 1 = 0` in `ZMod 3`. -/
theorem TF_offdiagonal_zero {𝓕 : Finset (Finset (Fin n))} {k : ℕ}
    (hsf : SunflowerFree 𝓕) (huni : ∀ A ∈ 𝓕, A.card = k)
    {A B C : Finset (Fin n)} (hA : A ∈ 𝓕) (hB : B ∈ 𝓕) (hC : C ∈ 𝓕)
    (hne : ¬ (A = B ∧ B = C)) : TFcore A B C = 0 := by
  by_contra h_nonzero;
  unfold TFcore at h_nonzero; simp_all +decide [ Finset.prod_eq_zero_iff ] ;
  by_cases hAB : A = B <;> by_cases hBC : B = C <;> by_cases hAC : A = C <;> simp_all +decide [ ind ];
  · -- Since $B \neq C$, there exists an element $i \in B$ such that $i \notin C$.
    obtain ⟨i, hiB, hiC⟩ : ∃ i, i ∈ B ∧ i ∉ C := by
      exact Finset.not_subset.mp fun h => hBC <| Finset.eq_of_subset_of_card_le h <| by aesop;
    specialize h_nonzero i ; simp_all +decide;
  · -- Since $A \neq C$ and $A, C \in \mathcal{F}$, we have $A \cap C \neq A$ and $A \cap C \neq C$.
    have h_inter_ne_A : A ∩ C ≠ A := by
      grind
    have h_inter_ne_C : A ∩ C ≠ C := by
      intro h; have := huni A hA; have := huni C hC; simp_all +decide;
      exact hAC ( Finset.eq_of_subset_of_card_le h ( by linarith [ huni A hA, huni C hC ] ) ▸ rfl );
    grind +splitImp;
  · obtain ⟨x, hx⟩ : ∃ x, x ∈ C ∧ x ∉ B := by
      exact Finset.not_subset.mp fun h => hBC <| Finset.eq_of_subset_of_card_le h ( by aesop ) ▸ rfl;
    grind;
  · specialize hsf A hA B hB C hC ; simp_all +decide [ Finset.ext_iff ];
    grind +ring

/-- **Layer 2** (depends on: `TF`, `TFcore_diag`, `TF_offdiagonal_zero`, `diagTensor`).  Under the
sunflower-free + uniform hypotheses, `TF 𝓕` **is** the diagonal tensor with diagonal `famDiag 𝓕`. -/
theorem TF_eq_diagTensor {𝓕 : Finset (Finset (Fin n))} {k : ℕ}
    (hsf : SunflowerFree 𝓕) (huni : ∀ A ∈ 𝓕, A.card = k) :
    TF 𝓕 = diagTensor (famDiag 𝓕) := by
  funext A B C
  unfold TF diagTensor famDiag
  by_cases hmem : A ∈ 𝓕 ∧ B ∈ 𝓕 ∧ C ∈ 𝓕
  · rw [if_pos hmem]
    obtain ⟨hA, hB, hC⟩ := hmem
    by_cases heq : A = B ∧ B = C
    · obtain ⟨hAB, hBC⟩ := heq
      subst hAB; subst hBC
      rw [TFcore_diag]
      simp [hA]
    · rw [TF_offdiagonal_zero hsf huni hA hB hC heq]
      rw [if_neg]
      rintro ⟨h1, h2⟩
      exact heq ⟨h1, h2⟩
  · rw [if_neg hmem]
    by_cases heq : A = B ∧ B = C
    · obtain ⟨hAB, hBC⟩ := heq
      subst hAB; subst hBC
      simp only [and_self, if_true]
      rw [if_neg]
      intro hAmem
      exact hmem ⟨hAmem, hAmem, hAmem⟩
    · rw [if_neg]
      rintro ⟨h1, h2⟩
      exact heq ⟨h1, h2⟩

/-- **Layer 2** (depends on: `TF`, `SliceRankLE`).  Number of squarefree monomials of degree at
most `n/3` in `n` variables — the Croot–Lev–Pach monomial count.  By the entropy bound
`∑_{k ≤ n/3} C(n,k) ≤ (3 / 2^{2/3})^n`, so `Mbound n` grows like `(3/2^{2/3})^n`. -/
def Mbound (n : ℕ) : ℕ := ∑ k ∈ Finset.range (n + 1), if 3 * k ≤ n then Nat.choose n k else 0

/-- **Layer 2** (depends on: `TF`, `Mbound`).  **Croot–Lev–Pach slice-rank bound.**  The slice rank
of `TF 𝓕` is at most `3 · Mbound n`.  (Hard; left as `sorry`.) -/
theorem TF_sliceRank_le (𝓕 : Finset (Finset (Fin n))) :
    SliceRankLE (TF 𝓕) (3 * Mbound n) := by
  sorry

/-! ## Layer 3 — Main theorem -/

/-- **Layer 3** (depends on: Layer 1 `diagTensor_support_card_le_sliceRank`, Layer 2
`TF_eq_diagTensor`, `diagSupport_famDiag`, `TF_sliceRank_le`).  A **uniform** sunflower-free family
has size at most `3 · Mbound n`. -/
theorem sunflowerFree_uniform_bound {𝓕 : Finset (Finset (Fin n))} {k : ℕ}
    (hsf : SunflowerFree 𝓕) (huni : ∀ A ∈ 𝓕, A.card = k) :
    𝓕.card ≤ 3 * Mbound n := by
  have hslice : SliceRankLE (diagTensor (famDiag 𝓕)) (3 * Mbound n) := by
    rw [← TF_eq_diagTensor hsf huni]
    exact TF_sliceRank_le 𝓕
  have := diagTensor_support_card_le_sliceRank (famDiag 𝓕) hslice
  rwa [diagSupport_famDiag] at this

/-- **Layer 3** (depends on: `SunflowerFree`).  A subfamily of a sunflower-free family is
sunflower-free. -/
theorem SunflowerFree.subset {𝓕 𝓖 : Finset (Finset (Fin n))} (h : SunflowerFree 𝓕)
    (hsub : 𝓖 ⊆ 𝓕) : SunflowerFree 𝓖 := by
  intro A hA B hB C hC hAB hAC hBC
  exact h A (hsub hA) B (hsub hB) C (hsub hC) hAB hAC hBC

/-- **Layer 3** (depends on: `sunflowerFree_uniform_bound`, `SunflowerFree.subset`).  **Main
theorem.**  An arbitrary sunflower-free family of subsets of `Fin n` has size at most
`(n+1) · 3 · Mbound n`.  The extra `(n+1)` factor comes from pigeonholing over the possible
cardinalities: each cardinality-`k` sub-slab is uniform, hence antichain, and bounded by
`sunflowerFree_uniform_bound`. -/
theorem sunflowerFree_bound {𝓕 : Finset (Finset (Fin n))} (hsf : SunflowerFree 𝓕) :
    𝓕.card ≤ (n + 1) * (3 * Mbound n) := by
  -- partition `𝓕` into its cardinality slabs indexed by `range (n+1)`
  have hmaps : Set.MapsTo (fun A : Finset (Fin n) => A.card) (↑𝓕) (↑(Finset.range (n + 1))) := by
    intro A _
    simp only [Finset.coe_range, Set.mem_Iio]
    exact Nat.lt_succ_of_le (by simpa using Finset.card_le_univ A)
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  calc ∑ k ∈ Finset.range (n + 1), ({A ∈ 𝓕 | A.card = k}).card
      ≤ ∑ _k ∈ Finset.range (n + 1), 3 * Mbound n := by
        apply Finset.sum_le_sum
        intro k _
        apply sunflowerFree_uniform_bound (hsf.subset (Finset.filter_subset _ _))
        intro A hA
        exact (Finset.mem_filter.1 hA).2
    _ = (n + 1) * (3 * Mbound n) := by rw [Finset.sum_const, Finset.card_range]; ring

/-- **Layer 3** (depends on: `Mbound`).  **Asymptotic monomial count.**  There is a constant `K`
with `Mbound n ≤ K · (3 / 2^{2/3})^n` for all `n`.  This is the entropy bound
`∑_{k ≤ n/3} C(n,k) ≤ 2^{H(1/3) n} = (3 / 2^{2/3})^n`.  (Hard analysis; left as `sorry`.) -/
theorem Mbound_asymptotic :
    ∃ K : ℝ, 0 < K ∧ ∀ n : ℕ, (Mbound n : ℝ) ≤ K * (3 / 2 ^ (2/3 : ℝ)) ^ n := by
  sorry

/-- **Layer 3** (depends on: `sunflowerFree_bound`, `Mbound_asymptotic`).  **Naslund–Sawin bound in
asymptotic form.**  There is a constant `K` with `#𝓕 ≤ K · (n+1) · (3/2^{2/3})^n` for every
sunflower-free family `𝓕 ⊆ 2^{[n]}`.

The base `3 / 2^{2/3} ≈ 1.89` is the Naslund–Sawin exponential rate.  We record the honest
polynomial factor `n+1` coming from the cardinality-slab pigeonhole (`sunflowerFree_bound`); the
sharper `n^{1/6}` factor from Naslund–Sawin's degree optimization is a strictly stronger statement
that is not asserted here (it would require the optimized version of the slice-rank bound).

This corollary is fully proved *from* the (still `sorry`-ed) `Mbound_asymptotic` and the (proved)
`sunflowerFree_bound`; it introduces no new circularity. -/
theorem sunflowerFree_bound_asymptotic :
    ∃ K : ℝ, 0 < K ∧ ∀ (n : ℕ) (𝓕 : Finset (Finset (Fin n))), SunflowerFree 𝓕 →
      (𝓕.card : ℝ) ≤ K * ((n : ℝ) + 1) * (3 / 2 ^ (2/3 : ℝ)) ^ n := by
  obtain ⟨K, hK, hKbound⟩ := Mbound_asymptotic
  refine ⟨3 * K, by positivity, ?_⟩
  intro n 𝓕 hsf
  have hcard : (𝓕.card : ℝ) ≤ ((n : ℝ) + 1) * (3 * (Mbound n : ℝ)) := by
    have h := sunflowerFree_bound hsf
    calc (𝓕.card : ℝ) ≤ (((n + 1) * (3 * Mbound n) : ℕ) : ℝ) := by exact_mod_cast h
      _ = ((n : ℝ) + 1) * (3 * (Mbound n : ℝ)) := by push_cast; ring
  have hM := hKbound n
  calc (𝓕.card : ℝ) ≤ ((n : ℝ) + 1) * (3 * (Mbound n : ℝ)) := hcard
    _ ≤ ((n : ℝ) + 1) * (3 * (K * (3 / 2 ^ (2/3 : ℝ)) ^ n)) := by
        apply mul_le_mul_of_nonneg_left _ (by positivity)
        exact mul_le_mul_of_nonneg_left hM (by norm_num)
    _ = 3 * K * ((n : ℝ) + 1) * (3 / 2 ^ (2/3 : ℝ)) ^ n := by ring

end Catalog.Combinatorics.SliceRankSunflowerFree