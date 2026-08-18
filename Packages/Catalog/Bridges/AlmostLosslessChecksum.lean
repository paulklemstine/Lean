/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression V: Checksums and Guaranteed Error Detection

## Bridge: Product constructions (combinatorics) ↔ Error detection (coding theory)

`AlmostLosslessRandomCoding` shows that a codebook symbol is *never* corrupted
silently, and that an off-codebook symbol is corrupted with probability at most
`|S|/M`.  A **checksum** is the standard way to push the latter down without
redesigning the code: append `log C` extra bits computed by a second,
independent universal family.

The structural fact that makes this work is that 2-universality is closed under
pairing, with the collision parameter *multiplying*:

  `pairHash_universal2 : Universal2 H → Universal2 G → Universal2 (H ⊗ G)`

where `H ⊗ G` has `K·K'` keys and `M·C` codewords.  Feeding this into the main
achievability theorem gives `exists_checksummed_scheme`: silent corruption below
any target `η`, at an additive cost of `log C` bits.

## Impact: guaranteed_error_detection, no_silent_corruption
-/

import Mathlib
import Bridges.AlmostLosslessRandomCoding

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section Pair

variable {α : Type*} [Fintype α] [DecidableEq α] {K K' M C : ℕ}

/-- Pair a hash family with a checksum family: `K·K'` keys, `M·C` codewords. -/
def pairHash (H : Fin K → α → Fin M) (G : Fin K' → α → Fin C) :
    Fin (K * K') → α → Fin (M * C) :=
  fun k x => finProdFinEquiv (H (finProdFinEquiv.symm k).1 x, G (finProdFinEquiv.symm k).2 x)

omit [Fintype α] [DecidableEq α] in
theorem pairHash_eq_iff {H : Fin K → α → Fin M} {G : Fin K' → α → Fin C}
    {k : Fin (K * K')} {x y : α} :
    pairHash H G k x = pairHash H G k y ↔
      (H (finProdFinEquiv.symm k).1 x = H (finProdFinEquiv.symm k).1 y
        ∧ G (finProdFinEquiv.symm k).2 x = G (finProdFinEquiv.symm k).2 y) := by
  unfold pairHash
  rw [Equiv.apply_eq_iff_eq, Prod.mk.injEq]

omit [Fintype α] [DecidableEq α] in
/-- **2-universality is multiplicative under pairing.**  A `1/M`-universal hash
composed with a `1/C`-universal checksum is a `1/(M·C)`-universal family. -/
theorem pairHash_universal2 {H : Fin K → α → Fin M} {G : Fin K' → α → Fin C}
    (hH : Universal2 H) (hG : Universal2 G) : Universal2 (pairHash H G) := by
  classical
  intro x y hxy
  -- transport the key set along the product equivalence
  have hcard : (Finset.univ.filter (fun k : Fin (K * K') =>
        pairHash H G k x = pairHash H G k y)).card
      = (Finset.univ.filter (fun k : Fin K => H k x = H k y)).card
        * (Finset.univ.filter (fun k : Fin K' => G k x = G k y)).card := by
    have h1 : (Finset.univ.filter (fun k : Fin (K * K') =>
          pairHash H G k x = pairHash H G k y)).card
        = (Finset.univ.filter (fun kk : Fin K × Fin K' =>
            H kk.1 x = H kk.1 y ∧ G kk.2 x = G kk.2 y)).card := by
      refine Finset.card_equiv finProdFinEquiv.symm ?_
      intro k
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, pairHash_eq_iff]
    have h2 : (Finset.univ.filter (fun kk : Fin K × Fin K' =>
          H kk.1 x = H kk.1 y ∧ G kk.2 x = G kk.2 y))
        = (Finset.univ.filter (fun k : Fin K => H k x = H k y))
            ×ˢ (Finset.univ.filter (fun k : Fin K' => G k x = G k y)) := by
      ext kk
      simp [Finset.mem_product]
    rw [h1, h2, Finset.card_product]
  have hMC : (0 : ℝ) ≤ (M : ℝ) * C := by positivity
  have h1 := hH x y hxy
  have h2 := hG x y hxy
  have hn1 : (0 : ℝ) ≤ ((Finset.univ.filter (fun k : Fin K => H k x = H k y)).card : ℝ) :=
    Nat.cast_nonneg _
  have hn2 : (0 : ℝ) ≤ ((Finset.univ.filter (fun k : Fin K' => G k x = G k y)).card : ℝ) :=
    Nat.cast_nonneg _
  have hK1 : (0 : ℝ) ≤ (K : ℝ) := Nat.cast_nonneg _
  calc ((Finset.univ.filter (fun k : Fin (K * K') =>
          pairHash H G k x = pairHash H G k y)).card : ℝ) * (M * C : ℕ)
      = (((Finset.univ.filter (fun k : Fin K => H k x = H k y)).card : ℝ) * M)
          * (((Finset.univ.filter (fun k : Fin K' => G k x = G k y)).card : ℝ) * C) := by
        rw [hcard]; push_cast; ring
    _ ≤ (K : ℝ) * (K' : ℝ) := mul_le_mul h1 h2 (by positivity) hK1
    _ = ((K * K' : ℕ) : ℝ) := by push_cast; ring

/-- **Checksummed almost-lossless compression.**  Composing a universal hash
into `M` codewords with a universal checksum into `C` values yields a scheme
whose silent-corruption probability is at most `|l|/(M·C)` — driven below any
target by `log C` extra bits — while failures remain detectable and decoding
still costs exactly `|l|` steps. -/
theorem exists_checksummed_scheme (μ : FinProbDist α) {H : Fin K → α → Fin M}
    {G : Fin K' → α → Fin C} (hH : Universal2 H) (hG : Universal2 G)
    (hK : 0 < K) (hK' : 0 < K') (hM : 0 < M) (hC : 0 < C)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin (K * K'),
      setMass μ (Finset.univ.filter
          (fun x => ¬ (hashScheme l (pairHash H G k)).Succeeds x))
          ≤ δ + (l.length : ℝ) / (M * C)
      ∧ setMass μ (Finset.univ.filter
          (fun x => (hashScheme l (pairHash H G k)).SilentError x))
          ≤ (l.length : ℝ) / (M * C)
      ∧ ∀ i : Fin (M * C), (scanCost (pairHash H G k) i l).2 = l.length := by
  have hKK : 0 < K * K' := Nat.mul_pos hK hK'
  have hMC : 0 < M * C := Nat.mul_pos hM hC
  have hmain := exists_almost_lossless_scheme μ (pairHash_universal2 hH hG) hKK hMC l hnd δ hδ
  obtain ⟨k, h1, h2, h3⟩ := hmain
  refine ⟨k, ?_, ?_, h3⟩
  · have hcast : (((M * C : ℕ)) : ℝ) = (M : ℝ) * C := by push_cast; ring
    rwa [hcast] at h1
  · have hcast : (((M * C : ℕ)) : ℝ) = (M : ℝ) * C := by push_cast; ring
    rwa [hcast] at h2

/-- **Detection at logarithmic cost.**  Given any target `η > 0` for the silent
corruption probability, a checksum with `C ≥ |l|/(η·M)` values achieves it:
`|l|/(M·C) ≤ η`.  The extra rate is `log C` bits, i.e. logarithmic in `1/η`. -/
theorem checksum_length_suffices (n M C : ℕ) (η : ℝ)
    (hM : 0 < M) (hC : 0 < C) (hbig : (n : ℝ) ≤ η * M * C) :
    (n : ℝ) / (M * C) ≤ η := by
  have hMC : (0 : ℝ) < (M : ℝ) * C := by
    have : (0 : ℝ) < M := by exact_mod_cast hM
    have : (0 : ℝ) < C := by exact_mod_cast hC
    positivity
  rw [div_le_iff₀ hMC]
  nlinarith

end Pair

end AlmostLossless