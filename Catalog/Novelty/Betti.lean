import Mathlib
import Novelty.QuantumTopoMitigation.ErrorMitigation

/-!
# Betti-count recovery from noisy barcodes

Given a finite barcode `B : Fin n → Bar`, the *Betti count at threshold `τ`* is the
number of bars whose persistence strictly exceeds `τ`.  We prove:

* `betti_antitone`: the Betti count is antitone in the threshold.
* `betti_recovered`: if every noisy persistence is within `ε` of the true persistence,
  every true persistence is separated from `τ` by a margin `m`, and `2 * ε < m`, then
  the noisy Betti count equals the true Betti count.

The recovery proof is non-circular: it flows from the pointwise lemma
`threshold_iff_of_noise_margin` (proved in `ErrorMitigation.lean`) to a pointwise
threshold equivalence, then to equality of the filtered `Finset`s, then to equality of
their cardinalities.  `ErrorMitigation.lean` does not import this file.
-/

namespace Catalog.Novelty.QuantumTopoMitigation

open Finset

/-- The Betti count of a finite barcode `B` at threshold `τ`: the number of bars whose
persistence is strictly greater than `τ`. -/
noncomputable def bettiCount (τ : ℝ) {n : ℕ} (B : Fin n → Bar) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter fun i => τ < persistence (B i)).card

/-- The Betti count is antitone in the threshold: raising the threshold can only
remove bars from the count. -/
theorem betti_antitone {n : ℕ} (B : Fin n → Bar) {τ₁ τ₂ : ℝ} (h : τ₁ ≤ τ₂) :
    bettiCount τ₂ B ≤ bettiCount τ₁ B := by
      exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, lt_of_le_of_lt h ( Finset.mem_filter.mp hx |>.2 ) ⟩

/-- **Betti-count recovery.**  If every noisy persistence `persistence (N i)` is within
`ε` of the true persistence `persistence (T i)`, every true persistence is separated
from the threshold `τ` by a margin `m`, and `2 * ε < m`, then the noisy Betti count
equals the true Betti count. -/
theorem betti_recovered {n : ℕ} (T N : Fin n → Bar) {τ ε m : ℝ}
    (hnoise : ∀ i, |persistence (N i) - persistence (T i)| ≤ ε)
    (hmargin : ∀ i, m ≤ |persistence (T i) - τ|)
    (hsep : 2 * ε < m) :
    bettiCount τ N = bettiCount τ T := by
      unfold bettiCount;
      exact congr_arg _ ( Finset.filter_congr fun i _ => threshold_iff_of_noise_margin ( hnoise i ) ( hmargin i ) hsep )

end Catalog.Novelty.QuantumTopoMitigation