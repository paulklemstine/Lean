import Mathlib

/-!
# Sparse Neural Codes: Packing Bounds for Cell Assemblies

Cortical codes are **sparse**: a concept is represented by a small *assembly* of
`w` simultaneously active neurons out of `N`.  This file bounds how many
assemblies a population can host once we require them to overlap only a little,
which is what makes them separately readable.

## Model

A **neural code** on `N` neurons is a binary pattern `NeuralCode N = Fin N → Bool`
with **support** `supp c` (the active neurons) and **weight** `wt c = |supp c|`.
A **`w`-sparse codebook** is a finite set of patterns all of weight `w`.

## Main results

* `dist_add_two_mul_inter` — the exact relation between Hamming distance and
  overlap: `hammingDist x y + 2 |supp x ∩ supp y| = wt x + wt y`.
* `sparse_packing_bound` — **assembly packing bound**: if the assemblies of a
  `w`-sparse codebook pairwise overlap in fewer than `s` neurons then
  `|C| * C(w,s) ≤ C(N,s)`.  Each codeword privately owns all `C(w,s)` of its
  `s`-element subsets.
* `sparse_distance_bound` — the same bound expressed through the minimum Hamming
  distance (a Johnson-type bound): distance `≥ 2(w - s + 1)` suffices.
* `disjoint_assemblies_bound` — the case `s = 1`: pairwise disjoint assemblies of
  size `w` number at most `N / w` (stated as `|C| * w ≤ N`).
* `oneHot_attains_disjoint_bound` — that bound is attained at `w = 1` by the `N`
  grandmother cells, so it cannot be improved in general.
* `sparse_capacity_le_choose` — a `w`-sparse codebook never exceeds `C(N,w)`
  patterns, with equality for the full weight-`w` layer
  (`card_sparse_layer`).
-/

namespace NeuralSparseCode

open Finset

/-- A **neural code** on `N` neurons. -/
abbrev NeuralCode (N : ℕ) : Type := Fin N → Bool

/-- The **assembly** (support) of a pattern: the set of active neurons. -/
def supp {N : ℕ} (c : NeuralCode N) : Finset (Fin N) :=
  Finset.univ.filter (fun i => c i = true)

/-- The **weight** (sparseness level) of a pattern: the size of its assembly. -/
def wt {N : ℕ} (c : NeuralCode N) : ℕ := (supp c).card

/-- **Distance versus overlap.**  Two patterns disagree on every neuron that is
active in exactly one of them, so
`hammingDist x y + 2 |supp x ∩ supp y| = wt x + wt y`. -/
theorem dist_add_two_mul_inter {N : ℕ} (x y : NeuralCode N) :
    hammingDist x y + 2 * (supp x ∩ supp y).card = wt x + wt y := by
  have hfil : (Finset.univ.filter (fun i => x i ≠ y i))
      = (supp x \ supp y) ∪ (supp y \ supp x) := by
    ext i
    simp only [supp, mem_filter, mem_univ, true_and, mem_union, mem_sdiff]
    cases hx : x i <;> cases hy : y i <;> simp
  have hdisj : Disjoint (supp x \ supp y) (supp y \ supp x) := by
    simp only [Finset.disjoint_left, mem_sdiff]
    rintro a ⟨-, h2⟩ ⟨h3, -⟩
    exact h2 h3
  have hd : hammingDist x y = (supp x \ supp y).card + (supp y \ supp x).card := by
    rw [hammingDist, hfil, Finset.card_union_of_disjoint hdisj]
  have h1 : (supp x \ supp y).card + (supp x ∩ supp y).card = wt x :=
    Finset.card_sdiff_add_card_inter _ _
  have h2 : (supp y \ supp x).card + (supp y ∩ supp x).card = wt y :=
    Finset.card_sdiff_add_card_inter _ _
  rw [Finset.inter_comm (supp y) (supp x)] at h2
  omega

/-- **Assembly packing bound.**  If every two distinct assemblies of a `w`-sparse
codebook share fewer than `s` neurons, then each codeword owns all `C(w,s)` of
its `s`-neuron subsets exclusively, so `|C| * C(w,s) ≤ C(N,s)`. -/
theorem sparse_packing_bound {N w s : ℕ} (C : Finset (NeuralCode N))
    (hw : ∀ c ∈ C, wt c = w)
    (hint : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → (supp x ∩ supp y).card < s) :
    C.card * w.choose s ≤ N.choose s := by
  classical
  have hdisj : ∀ x ∈ C, ∀ y ∈ C, x ≠ y →
      Disjoint ((supp x).powersetCard s) ((supp y).powersetCard s) := by
    intro x hx y hy hxy
    simp only [Finset.disjoint_left, mem_powersetCard]
    rintro T ⟨hTx, hTs⟩ ⟨hTy, -⟩
    have hTsub : T ⊆ supp x ∩ supp y := Finset.subset_inter hTx hTy
    have h1 := Finset.card_le_card hTsub
    have h2 := hint x hx y hy hxy
    omega
  have hcard : (C.biUnion (fun c => (supp c).powersetCard s)).card
      = ∑ c ∈ C, ((supp c).powersetCard s).card :=
    Finset.card_biUnion (fun x hx y hy hxy => hdisj x hx y hy hxy)
  have hsub : C.biUnion (fun c => (supp c).powersetCard s)
      ⊆ (Finset.univ : Finset (Fin N)).powersetCard s := by
    intro T hT
    simp only [mem_biUnion, mem_powersetCard] at hT ⊢
    obtain ⟨c, -, -, hTs⟩ := hT
    exact ⟨Finset.subset_univ _, hTs⟩
  have hle := Finset.card_le_card hsub
  rw [hcard, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin] at hle
  have hterm : ∀ c ∈ C, ((supp c).powersetCard s).card = w.choose s := by
    intro c hc
    rw [Finset.card_powersetCard, ← wt, hw c hc]
  rw [Finset.sum_congr rfl hterm, Finset.sum_const, smul_eq_mul] at hle
  exact hle

/-- Large Hamming distance forces small overlap of equal-weight assemblies. -/
theorem inter_lt_of_dist {N w s : ℕ} {x y : NeuralCode N}
    (hx : wt x = w) (hy : wt y = w) (hd : 2 * (w - s + 1) ≤ hammingDist x y) :
    (supp x ∩ supp y).card < s := by
  have h := dist_add_two_mul_inter x y
  rw [hx, hy] at h
  omega

/-- **Johnson-type bound for sparse neural codes.**  A `w`-sparse codebook whose
distinct assemblies are at Hamming distance at least `2(w - s + 1)` satisfies
`|C| * C(w,s) ≤ C(N,s)`.  (The intended regime is `1 ≤ s ≤ w`; outside it the
inequality is still true but vacuous, since `C(w,s) = 0`.) -/
theorem sparse_distance_bound {N w s : ℕ}
    (C : Finset (NeuralCode N)) (hw : ∀ c ∈ C, wt c = w)
    (hd : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * (w - s + 1) ≤ hammingDist x y) :
    C.card * w.choose s ≤ N.choose s := by
  refine sparse_packing_bound C hw (fun x hx y hy hxy => ?_)
  exact inter_lt_of_dist (hw x hx) (hw y hy) (hd x hx y hy hxy)

/-- **Disjoint assemblies.**  Cell assemblies of size `w` that share no neuron
number at most `N / w`: the case `s = 1` of the packing bound. -/
theorem disjoint_assemblies_bound {N w : ℕ} (C : Finset (NeuralCode N))
    (hw : ∀ c ∈ C, wt c = w)
    (hint : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → Disjoint (supp x) (supp y)) :
    C.card * w ≤ N := by
  have h := sparse_packing_bound (s := 1) C hw (fun x hx y hy hxy => by
    have : supp x ∩ supp y = ∅ := Finset.disjoint_iff_inter_eq_empty.mp (hint x hx y hy hxy)
    simp [this])
  simpa using h

/-! ## Tightness -/

/-- The **grandmother cell** for neuron `i`: only neuron `i` fires. -/
def oneHot {N : ℕ} (i : Fin N) : NeuralCode N := fun j => decide (j = i)

lemma supp_oneHot {N : ℕ} (i : Fin N) : supp (oneHot i) = {i} := by
  ext j; simp [supp, oneHot]

lemma wt_oneHot {N : ℕ} (i : Fin N) : wt (oneHot i) = 1 := by
  rw [wt, supp_oneHot, Finset.card_singleton]

/-- **The disjoint-assembly bound is attained at `w = 1`.**  The `N` grandmother
cells form a codebook of `N` pairwise disjoint assemblies of size `1`, meeting
`disjoint_assemblies_bound` with equality. -/
theorem oneHot_attains_disjoint_bound (N : ℕ) :
    ((Finset.univ : Finset (Fin N)).image oneHot).card * 1 = N ∧
      (∀ x ∈ (Finset.univ : Finset (Fin N)).image oneHot, wt x = 1) ∧
      (∀ x ∈ (Finset.univ : Finset (Fin N)).image oneHot,
        ∀ y ∈ (Finset.univ : Finset (Fin N)).image oneHot, x ≠ y → Disjoint (supp x) (supp y)) := by
  have hinj : Function.Injective (oneHot (N := N)) := by
    intro i j hij
    have h := congrFun hij j
    simp only [oneHot, decide_eq_decide, iff_true] at h
    exact h.symm
  refine ⟨?_, ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_fin, mul_one]
  · rintro x hx
    simp only [Finset.mem_image] at hx
    obtain ⟨i, -, rfl⟩ := hx
    exact wt_oneHot i
  · rintro x hx y hy hxy
    simp only [Finset.mem_image] at hx hy
    obtain ⟨i, -, rfl⟩ := hx
    obtain ⟨j, -, rfl⟩ := hy
    rw [supp_oneHot, supp_oneHot, Finset.disjoint_singleton]
    intro h; exact hxy (by rw [h])

/-! ## The full sparse layer -/

/-- **Sparse counts.**  Exactly `C(N,w)` patterns have weight `w`. -/
theorem card_sparse_layer (N w : ℕ) :
    (Finset.univ.filter (fun c : NeuralCode N => wt c = w)).card = N.choose w := by
  classical
  have hpc : ((Finset.univ : Finset (Fin N)).powersetCard w).card = N.choose w := by
    rw [Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin]
  rw [← hpc]
  apply Finset.card_bij (fun c _ => supp c)
  · intro c hc
    simp only [mem_filter, mem_univ, true_and] at hc
    exact mem_powersetCard.mpr ⟨Finset.subset_univ _, hc⟩
  · intro a _ b _ hab
    funext i
    have hiff : (i ∈ supp a) ↔ (i ∈ supp b) := by rw [hab]
    simp only [supp, mem_filter, mem_univ, true_and] at hiff
    cases hai : a i <;> cases hbi : b i <;> simp_all
  · intro T hT
    simp only [mem_powersetCard] at hT
    refine ⟨fun i => decide (i ∈ T), ?_, ?_⟩
    · simp only [mem_filter, mem_univ, true_and, wt]
      have : supp (fun i => decide (i ∈ T)) = T := by ext i; simp [supp]
      rw [this]; exact hT.2
    · ext i; simp [supp]

/-- **Sparse capacity.**  A `w`-sparse codebook has at most `C(N,w)` codewords —
the number of possible assemblies — and the full weight-`w` layer attains it. -/
theorem sparse_capacity_le_choose {N w : ℕ} (C : Finset (NeuralCode N))
    (hw : ∀ c ∈ C, wt c = w) : C.card ≤ N.choose w := by
  classical
  rw [← card_sparse_layer N w]
  exact Finset.card_le_card (fun c hc => Finset.mem_filter.mpr ⟨Finset.mem_univ _, hw c hc⟩)

end NeuralSparseCode