/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XVII: Tagged Codewords and Products of Universal Families

## Bridge: universal hashing (algebra) ↔ product counting (combinatorics)
##         ↔ error detection (coding / cryptography)

A practical way to suppress silent corruption is to append a short **tag** to
each codeword: a second, independently keyed hash into `Fin T`.  A silent error
then needs the codeword *and* the tag to collide.  Formally this is the
statement that the **product** of two 2-universal families is again 2-universal,
over the product key space and the product codeword space:

* `Universal2_prod` — if `H` is 2-universal into `Fin M` over `K` keys and `G`
  is 2-universal into `Fin T` over `K'` keys, then the tagged family
  `taggedHash H G` on `Fin (K*K')` keys is 2-universal into `Fin (M*T)`.  The
  counting is exact: the bad-key set of the product is the product of the bad
  key sets, so the two `1/M` and `1/T` densities multiply;
* `exists_tagged_balanced_scheme` — **the deliverable**: with a `T`-valued tag,
  a single (key, tag-key) pair achieves silent-corruption probability
  `≤ (√δ+δ)·|l|/(M·T)` and failure probability `≤ δ + (1+√δ)·|l|/(M·T)`,
  with decoding cost still exactly `|l|`.  For `T = 2^t` the silent-error rate
  drops by the factor `2^{-t}`: silent corruption is *exponentially* rare in
  the tag length, at no extra scan cost;
* `tagged_silent_le_untagged` — the quantitative comparison with the untagged
  scheme of the same codeword size `M`.

Note that the strengthening is genuine and not a relabelling of "use `M·T`
codewords": the tag is produced by an *independent* key, so the number of keys
grows multiplicatively while the universality constant of the composite family
is the product `1/(M·T)` — this is exactly what
`Universal2_prod` establishes.

## Impact: tagged_silent_suppression, universal_family_products
-/

import Mathlib
import MachineLearning.AlmostLosslessBalancedSilent

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section TaggedProduct

variable {α : Type*} [Fintype α] [DecidableEq α] {K K' M T : ℕ}

/-- The tagged hash family: key `kk` splits into a codeword key and a tag key,
and the output is the pair `(H k x, G k' x)` packed into `Fin (M*T)`. -/
def taggedHash (H : Fin K → α → Fin M) (G : Fin K' → α → Fin T) :
    Fin (K * K') → α → Fin (M * T) :=
  fun kk x =>
    finProdFinEquiv (H (finProdFinEquiv.symm kk).1 x, G (finProdFinEquiv.symm kk).2 x)

omit [Fintype α] [DecidableEq α] in
/-- Two symbols collide under the tagged family exactly when they collide under
both components. -/
theorem taggedHash_eq_iff (H : Fin K → α → Fin M) (G : Fin K' → α → Fin T)
    (kk : Fin (K * K')) (x y : α) :
    taggedHash H G kk x = taggedHash H G kk y ↔
      (H (finProdFinEquiv.symm kk).1 x = H (finProdFinEquiv.symm kk).1 y
        ∧ G (finProdFinEquiv.symm kk).2 x = G (finProdFinEquiv.symm kk).2 y) := by
  unfold taggedHash
  rw [Equiv.apply_eq_iff_eq, Prod.mk.injEq]

omit [Fintype α] [DecidableEq α] in
/-- **Products of universal families are universal.**  If `H` is 2-universal
into `Fin M` and `G` is 2-universal into `Fin T`, the tagged family is
2-universal into `Fin (M*T)`.  The bad-key set of the product is the Cartesian
product of the two bad-key sets, so the two collision densities `1/M` and `1/T`
multiply exactly. -/
theorem Universal2_prod {H : Fin K → α → Fin M} {G : Fin K' → α → Fin T}
    (hH : Universal2 H) (hG : Universal2 G) : Universal2 (taggedHash H G) := by
  classical
  intro x y hxy
  -- transport the bad-key count along the key-space equivalence
  have hcard : (Finset.univ.filter
        (fun kk : Fin (K * K') => taggedHash H G kk x = taggedHash H G kk y)).card
      = (Finset.univ.filter (fun k : Fin K => H k x = H k y)).card
        * (Finset.univ.filter (fun k' : Fin K' => G k' x = G k' y)).card := by
    have hstep : (Finset.univ.filter
          (fun kk : Fin (K * K') => taggedHash H G kk x = taggedHash H G kk y)).card
        = (Finset.univ.filter
          (fun p : Fin K × Fin K' => H p.1 x = H p.1 y ∧ G p.2 x = G p.2 y)).card := by
      refine (Finset.card_equiv finProdFinEquiv.symm ?_)
      intro kk
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      rw [taggedHash_eq_iff]
    rw [hstep, ← Finset.card_product]
    congr 1
    ext p
    simp [Finset.mem_product]
  rw [hcard]
  have h1 := hH x y hxy
  have h2 := hG x y hxy
  have hK1 : (0 : ℝ) ≤ ((Finset.univ.filter (fun k : Fin K => H k x = H k y)).card : ℝ) :=
    Nat.cast_nonneg _
  have hK2 : (0 : ℝ) ≤ ((Finset.univ.filter (fun k' : Fin K' => G k' x = G k' y)).card : ℝ) :=
    Nat.cast_nonneg _
  have hMT : ((K * K' : ℕ) : ℝ) = (K : ℝ) * (K' : ℝ) := by push_cast; ring
  have hprod : (((Finset.univ.filter (fun k : Fin K => H k x = H k y)).card
      * (Finset.univ.filter (fun k' : Fin K' => G k' x = G k' y)).card : ℕ) : ℝ)
      * ((M * T : ℕ) : ℝ)
      = (((Finset.univ.filter (fun k : Fin K => H k x = H k y)).card : ℝ) * M)
        * (((Finset.univ.filter (fun k' : Fin K' => G k' x = G k' y)).card : ℝ) * T) := by
    push_cast; ring
  rw [hprod, hMT]
  have hMnn : (0 : ℝ) ≤ (M : ℝ) := Nat.cast_nonneg _
  have hTnn : (0 : ℝ) ≤ (T : ℝ) := Nat.cast_nonneg _
  have hle1 : ((Finset.univ.filter (fun k : Fin K => H k x = H k y)).card : ℝ) * M ≤ K := h1
  have hle2 : ((Finset.univ.filter (fun k' : Fin K' => G k' x = G k' y)).card : ℝ) * T ≤ K' := h2
  have hnn1 : (0 : ℝ) ≤ ((Finset.univ.filter (fun k : Fin K => H k x = H k y)).card : ℝ) * M :=
    mul_nonneg hK1 hMnn
  have hnn2 : (0 : ℝ) ≤ ((Finset.univ.filter (fun k' : Fin K' => G k' x = G k' y)).card : ℝ) * T :=
    mul_nonneg hK2 hTnn
  exact mul_le_mul hle1 hle2 hnn2 (le_trans hnn1 hle1)

/-- **Tagged balanced scheme: silent corruption is exponentially rare in the tag
length.**  Appending an independently keyed `T`-valued tag to each codeword, a
single (key, tag-key) pair achieves

1. silent-corruption probability `≤ (√δ + δ)·|l|/(M·T)`;
2. failure probability `≤ δ + (1 + √δ)·|l|/(M·T)`;
3. decoding cost exactly `|l|` evaluations of the tagged hash.

With `T = 2^t` the silent-error bound of
`exists_balanced_almost_lossless_scheme` improves by the factor `2^{-t}` — the
tag turns would-be silent corruptions into detected failures. -/
theorem exists_tagged_balanced_scheme (μ : FinProbDist α)
    {H : Fin K → α → Fin M} {G : Fin K' → α → Fin T}
    (hH : Universal2 H) (hG : Universal2 G) (hK : 0 < K) (hK' : 0 < K')
    (hM : 0 < M) (hT : 0 < T) (l : List α) (hnd : l.Nodup) (δ : ℝ)
    (hδpos : 0 < δ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ kk : Fin (K * K'),
      setMass μ (Finset.univ.filter
          (fun x => ¬ (hashScheme l (taggedHash H G kk)).Succeeds x))
          ≤ δ + (1 + Real.sqrt δ) * (l.length : ℝ) / ((M : ℝ) * T)
      ∧ setMass μ (Finset.univ.filter
          (fun x => (hashScheme l (taggedHash H G kk)).SilentError x))
          ≤ (Real.sqrt δ + δ) * (l.length : ℝ) / ((M : ℝ) * T)
      ∧ ∀ i : Fin (M * T), (scanCost (taggedHash H G kk) i l).2 = l.length := by
  classical
  have hKK' : 0 < K * K' := Nat.mul_pos hK hK'
  have hMT : 0 < M * T := Nat.mul_pos hM hT
  obtain ⟨kk, hfail, hsilent, _, hcost⟩ :=
    exists_balanced_almost_lossless_scheme μ (Universal2_prod hH hG) hKK' hMT l hnd δ
      hδpos hδ
  have hcast : ((M * T : ℕ) : ℝ) = (M : ℝ) * T := by push_cast; ring
  rw [hcast] at hfail hsilent
  exact ⟨kk, hfail, hsilent, hcost⟩

/-- The tag improves the silent-error bound by exactly the factor `1/T`
relative to the untagged balanced scheme with `M` codewords. -/
theorem tagged_silent_le_untagged (δ : ℝ) (hδ : 0 ≤ δ) (len : ℝ) (hlen : 0 ≤ len)
    (M T : ℝ) (hM : 0 < M) (hT : 1 ≤ T) :
    (Real.sqrt δ + δ) * len / (M * T) ≤ (Real.sqrt δ + δ) * len / M := by
  have hnum : 0 ≤ (Real.sqrt δ + δ) * len :=
    mul_nonneg (by positivity) hlen
  have hT0 : (0 : ℝ) < T := lt_of_lt_of_le zero_lt_one hT
  have hMT : 0 < M * T := mul_pos hM hT0
  rw [div_le_div_iff₀ hMT hM]
  nlinarith [mul_nonneg (mul_nonneg hnum (le_of_lt hM)) (sub_nonneg.mpr hT)]

end TaggedProduct

end AlmostLossless