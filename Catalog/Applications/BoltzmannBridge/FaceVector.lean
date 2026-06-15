/-
# The Boltzmann Bridge V — The f-vector and the Euler–Poincaré Bridge

This file extends the catalog's higher-dimensional persistence machinery
(`Applications.BoltzmannBridge.HigherPersistence`, in particular
`euler_char_full_simplex`, the alternating binomial identity computing the Euler
characteristic of the full simplex) into the language of **f-vectors**.

The *f-vector* `(f₀, f₁, …)` of a finite simplicial complex records the number of
faces of each dimension; its alternating sum is the **Euler characteristic**.  The
catalog already pins the Euler characteristic of the full simplex to `1` as a bare
binomial identity.  Here we:

* define the dimension-graded face count `fVector` of an arbitrary finite complex
  (a `Finset` of faces) and the combinatorial Euler characteristic `eulerCharFin`;
* prove the **Euler–Poincaré bridge** `eulerChar_eq_alt_fVector`: the Euler
  characteristic equals the alternating sum of the f-vector — i.e. the bare
  alternating-sum formula is genuinely the invariant of a *complex*, obtained by
  grouping faces by dimension (`Finset.sum_fiberwise_of_maps_to`);
* compute the f-vector of the full simplex (`fVector_full_simplex`: the number of
  `k`-faces is `C(n,k)`) and combine the two to recover, now as a statement about
  an actual simplicial complex, that the full simplex has Euler characteristic `1`
  (`eulerChar_full_simplex`).

This turns `euler_char_full_simplex` from a numerical identity into the f-vector /
Euler–Poincaré statement it is the shadow of.

## Main results

* `fVector`                    — dimension-graded face count of a finite complex
* `eulerCharFin`               — combinatorial Euler characteristic of a complex
* `fVector_full_simplex`       — `f_k` of the full `n`-simplex is `C(n,k)`
* `eulerChar_eq_alt_fVector`   — Euler char = alternating sum of the f-vector
* `eulerChar_full_simplex`     — the full (nonempty) simplex has Euler char `1`
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence

open Finset BigOperators

namespace BoltzmannBridge

variable {α : Type*}

/-- The **f-vector entry** `f_k` of a finite simplicial complex `K` (presented as a
`Finset` of faces): the number of faces with exactly `k` vertices, i.e. of
dimension `k − 1`. -/
def fVector (K : Finset (Finset α)) (k : ℕ) : ℕ :=
  (K.filter (fun σ => σ.card = k)).card

/-- The **combinatorial Euler characteristic** of a finite complex `K`: the
alternating sum `∑_{σ nonempty} (−1)^(dim σ)` where `dim σ = card σ − 1`. -/
noncomputable def eulerCharFin (K : Finset (Finset α)) : ℤ :=
  ∑ σ ∈ K.filter (fun σ => σ.Nonempty), (-1 : ℤ) ^ (σ.card - 1)

-- !-- Lab Notebook: fVector_full_simplex -- !--
-- !-- Hypothesis: The full simplex on `s` has exactly `C(|s|, k)` faces with k
-- !-- vertices. -- !--
-- !-- Result: Proved — `filter (card = k)` of a powerset IS `powersetCard k`,
-- !-- whose cardinality is `Finset.card_powersetCard`. -- !--
-- !-- Insight: The f-vector of the full simplex is literally the binomial row,
-- !-- making the Euler–Poincaré bridge collapse onto the binomial identity. -- !--
-- !-- End Lab Notebook -- !--
/-- **The f-vector of the full simplex.**  The number of `k`-vertex faces of the
full simplex on the vertex set `s` is the binomial coefficient `C(|s|, k)`. -/
theorem fVector_full_simplex (s : Finset α) (k : ℕ) :
    fVector s.powerset k = s.card.choose k := by
  unfold fVector
  rw [← Finset.powersetCard_eq_filter, Finset.card_powersetCard]

/-
!-- Lab Notebook: eulerChar_eq_alt_fVector -- !--
!-- Hypothesis: Grouping the alternating face sum by dimension turns it into
!-- the alternating sum of the f-vector. -- !--
!-- Result: target proof via `Finset.sum_fiberwise_of_maps_to` with `g = card`
!-- over `Icc 1 N`; the fibre sum collapses to a constant times the count. -- !--
!-- Insight: This is the Euler–Poincaré principle in combinatorial form;
!-- ∂²=0 is hidden inside the eventual cancellation, but the *bookkeeping*
!-- identity holds for ANY finite complex with a dimension bound. -- !--
!-- Failure analysis (deferred): need `card = k` to convert the per-fibre
!-- exponent `card-1` into the constant `k-1`, and that nonempty ↔ card ≥ 1. -- !--
!-- End Lab Notebook -- !--

**The Euler–Poincaré bridge.**  For any finite complex `K` whose faces have at
most `N` vertices, the combinatorial Euler characteristic equals the alternating
sum of the f-vector.  This realizes the bare alternating-sum formula as the
invariant of an actual complex, obtained by grouping faces by dimension.
-/
theorem eulerChar_eq_alt_fVector (K : Finset (Finset α)) (N : ℕ)
    (hN : ∀ σ ∈ K, σ.card ≤ N) :
    eulerCharFin K = ∑ k ∈ Finset.Icc 1 N, (-1 : ℤ) ^ (k - 1) * (fVector K k : ℤ) := by
  rw [ eulerCharFin ];
  have h_fiberwise : ∀ k ∈ Finset.Icc 1 N, ∑ σ ∈ K.filter (fun σ => σ.Nonempty), (-1 : ℤ) ^ (σ.card - 1) * (if σ.card = k then 1 else 0) = (-1 : ℤ) ^ (k - 1) * (fVector K k) := by
    simp +decide [ Finset.sum_ite ];
    intro k hk₁ hk₂; rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.mem_filter.mp hx |>.2 ] ] ; simp +decide [ mul_comm, fVector ] ;
    congr 1 with x ; aesop;
  rw [ ← Finset.sum_congr rfl h_fiberwise, Finset.sum_comm ];
  simp +decide [ Finset.sum_ite ];
  congr! 1;
  grind

-- !-- Lab Notebook: eulerChar_full_simplex -- !--
-- !-- Hypothesis: As an actual complex, the full nonempty simplex has Euler
-- !-- characteristic 1. -- !--
-- !-- Result: Proved via `eulerChar_eq_alt_fVector` (with N = |s|), then
-- !-- `fVector_full_simplex`, then the catalog's `euler_char_full_simplex`. -- !--
-- !-- Insight: This is the upgrade of the catalog numerical identity to a
-- !-- statement about the simplicial complex it describes. -- !--
-- !-- End Lab Notebook -- !--
/-- **Euler characteristic of the full simplex, as a complex.**  The full simplex
on a nonempty vertex set has combinatorial Euler characteristic `1`.  This is the
f-vector upgrade of the catalog's `euler_char_full_simplex`. -/
theorem eulerChar_full_simplex (s : Finset α) (hs : s.Nonempty) :
    eulerCharFin s.powerset = 1 := by
  convert eulerChar_eq_alt_fVector s.powerset s.card _ using 1;
  · convert euler_char_full_simplex s.card hs.card_pos |> Eq.symm using 1;
    exact Finset.sum_congr rfl fun x hx => by rw [ fVector_full_simplex ] ;
  · exact fun σ hσ => Finset.card_le_card <| Finset.mem_powerset.mp hσ

end BoltzmannBridge