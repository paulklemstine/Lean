/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression IV: An Explicit 2-Universal Family

## Bridge: Finite fields (algebra) ↔ Shannon random coding (probability)

The achievability theorem of `AlmostLosslessRandomCoding` is stated for an
abstract 2-universal family.  This file removes any suspicion of vacuity by
exhibiting one: the **inner-product family** over a prime field,

  `h_k(x₁, x₂) = x₁ + k·x₂`  on  `(ZMod p)²`,  keyed by `k ∈ Fin p`.

It compresses a source of `p²` symbols into `p` codewords (half the raw rate),
and `linHash_universal2` proves the 2-universal property: two distinct source
symbols collide for **at most one** of the `p` keys.  Instantiating the general
theorem gives `exists_linear_almost_lossless`: a completely explicit
almost-lossless compressor with a proved failure bound and a proved decoding
cost.

## Impact: explicit_almost_lossless_code, certified_decoder_cost
-/

import Mathlib
import Bridges.AlmostLosslessRandomCoding

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section LinearHash

variable (p : ℕ) [Fact p.Prime]

/-- The field element attached to a key index. -/
def keyVal (k : Fin p) : ZMod p := (k.val : ZMod p)

theorem keyVal_injective : Function.Injective (keyVal p) := by
  intro k k' h
  unfold keyVal at h
  have h1 : ((k.val : ℕ) : ZMod p).val = k.val := ZMod.val_cast_of_lt k.isLt
  have h2 : ((k'.val : ℕ) : ZMod p).val = k'.val := ZMod.val_cast_of_lt k'.isLt
  exact Fin.ext (by rw [← h1, ← h2, h])

/-- The inner-product hash family `h_k(x₁,x₂) = x₁ + k·x₂` over `ZMod p`. -/
def linHash (k : Fin p) (x : ZMod p × ZMod p) : Fin p :=
  ⟨(x.1 + keyVal p k * x.2).val, ZMod.val_lt _⟩

theorem linHash_eq_iff {k : Fin p} {x y : ZMod p × ZMod p} :
    linHash p k x = linHash p k y ↔
      x.1 + keyVal p k * x.2 = y.1 + keyVal p k * y.2 := by
  unfold linHash
  rw [Fin.mk.injEq]
  exact ⟨fun h => ZMod.val_injective p h, fun h => by rw [h]⟩

/-- **The inner-product family is 2-universal.**  Distinct source symbols
collide for at most one key out of `p`; over a field this is the statement that
a nonzero linear equation in the key has a unique solution. -/
theorem linHash_universal2 : Universal2 (linHash p) := by
  intro x y hxy
  have hcard : (Finset.univ.filter (fun k => linHash p k x = linHash p k y)).card ≤ 1 := by
    rw [Finset.card_le_one]
    intro k1 h1 k2 h2
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, linHash_eq_iff] at h1 h2
    have e3 : (keyVal p k1 - keyVal p k2) * (x.2 - y.2) = 0 := by
      linear_combination h1 - h2
    rcases mul_eq_zero.mp e3 with h | h
    · exact keyVal_injective p (sub_eq_zero.mp h)
    · exfalso
      have hx2 : x.2 = y.2 := sub_eq_zero.mp h
      have hx1 : x.1 = y.1 := by
        rw [hx2] at h1; linear_combination h1
      exact hxy (Prod.ext hx1 hx2)
  have hp : (0 : ℝ) ≤ (p : ℝ) := Nat.cast_nonneg p
  have hc : ((Finset.univ.filter (fun k => linHash p k x = linHash p k y)).card : ℝ) ≤ 1 := by
    exact_mod_cast hcard
  calc ((Finset.univ.filter (fun k => linHash p k x = linHash p k y)).card : ℝ) * p
      ≤ 1 * p := by nlinarith
    _ = (p : ℝ) := one_mul _

/-- The source compressed by the inner-product family has `p²` symbols, while
the code space has only `p`: the rate is exactly halved. -/
theorem linHash_source_card :
    Fintype.card (ZMod p × ZMod p) = p * p := by
  simp [Fintype.card_prod, ZMod.card]

/-- **A fully explicit almost-lossless compressor.**  For the inner-product
family over `ZMod p`, any duplicate-free codebook `l` capturing all but `δ` of
the mass yields a key `k ∈ Fin p` whose scheme

* fails with probability at most `δ + |l|/p`,
* corrupts silently with probability at most `|l|/p`,
* decodes in exactly `|l|` field operations per query,

while compressing `p²` source symbols into `p` codewords. -/
theorem exists_linear_almost_lossless (μ : FinProbDist (ZMod p × ZMod p))
    (l : List (ZMod p × ZMod p)) (hnd : l.Nodup) (δ : ℝ)
    (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin p,
      setMass μ (Finset.univ.filter
          (fun x => ¬ (hashScheme l (linHash p k)).Succeeds x)) ≤ δ + (l.length : ℝ) / p
      ∧ setMass μ (Finset.univ.filter
          (fun x => (hashScheme l (linHash p k)).SilentError x)) ≤ (l.length : ℝ) / p
      ∧ ∀ i : Fin p, (scanCost (linHash p k) i l).2 = l.length := by
  have hp : 0 < p := (Fact.out : p.Prime).pos
  exact exists_almost_lossless_scheme μ (linHash_universal2 p) hp hp l hnd δ hδ

end LinearHash

/-! ## A concrete instance with explicit figures -/

section Concrete

instance : Fact (Nat.Prime 101) := ⟨by norm_num⟩

/-- The concrete source: `101² = 10201` symbols. -/
theorem concrete_source_card : Fintype.card (ZMod 101 × ZMod 101) = 10201 := by
  rw [linHash_source_card]

/-- **A concrete certified compressor.**  Source: `10201` symbols.  Codebook: a
10-element typical set carrying all but `1/100` of the mass.  Code space: `101`
codewords (a `7`-bit codeword instead of `14` bits).  Then some key `k < 101`
gives

* failure probability `≤ 1/100 + 10/101 < 0.11`,
* silent-corruption probability `≤ 10/101 < 0.1`,
* decoding cost **exactly 10** hash evaluations per query.
-/
theorem concrete_almost_lossless (μ : FinProbDist (ZMod 101 × ZMod 101))
    (l : List (ZMod 101 × ZMod 101)) (hnd : l.Nodup) (hlen : l.length = 10)
    (hδ : setMass μ (l.toFinset)ᶜ ≤ 1 / 100) :
    ∃ k : Fin 101,
      setMass μ (Finset.univ.filter
          (fun x => ¬ (hashScheme l (linHash 101 k)).Succeeds x)) ≤ 1 / 100 + 10 / 101
      ∧ setMass μ (Finset.univ.filter
          (fun x => (hashScheme l (linHash 101 k)).SilentError x)) ≤ 10 / 101
      ∧ ∀ i : Fin 101, (scanCost (linHash 101 k) i l).2 = 10 := by
  obtain ⟨k, h1, h2, h3⟩ := exists_linear_almost_lossless 101 μ l hnd (1 / 100) hδ
  refine ⟨k, ?_, ?_, fun i => by rw [h3 i, hlen]⟩
  · rw [hlen] at h1; push_cast at h1; linarith
  · rw [hlen] at h2; push_cast at h2; linarith

end Concrete

end AlmostLossless