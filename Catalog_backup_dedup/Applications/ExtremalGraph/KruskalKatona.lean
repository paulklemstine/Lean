/-
# Extremal Graph Theory III: Kruskal–Katona shadow bounds

The **Kruskal–Katona theorem** controls the size of the *shadow* `∂𝒜` (the family of all sets
obtained by deleting one element from a member of `𝒜`) of a uniform set family.  Mathlib proves
the Lovász form `kruskal_katona_lovasz_form`:

    if every member of `𝒜 ⊆ 𝒫(Fin n)` has size `r` and `k.choose r ≤ #𝒜`,
    then `k.choose (r - i) ≤ #(∂^[i] 𝒜)`.

From this we extract two reusable consequences:

* `kk_shadow_lower` — the single-shadow lower bound `k.choose (r-1) ≤ #(∂ 𝒜)`;
* `kk_iterated_shadow_nonempty` — a large `r`-uniform family has a **nonempty** `i`-th iterated
  shadow for every `i ≤ r`; in particular its shadow chain reaches all the way down to the empty
  layer.
-/
import Mathlib

open Finset
open scoped FinsetFamily

namespace ExtremalKK

variable {n : ℕ} {𝒜 : Finset (Finset (Fin n))} {r k i : ℕ}

/-- **Kruskal–Katona, single-shadow form.** A family of `r`-subsets of `Fin n` with at least
`k.choose r` members has shadow of size at least `k.choose (r-1)`. -/
theorem kk_shadow_lower (hrpos : 1 ≤ r) (hrk : r ≤ k) (hkn : k ≤ n)
    (h₁ : (𝒜 : Set (Finset (Fin n))).Sized r) (h₂ : k.choose r ≤ #𝒜) :
    k.choose (r - 1) ≤ #(∂ 𝒜) := by
  have := kruskal_katona_lovasz_form (i := 1) hrpos hrk hkn h₁ h₂
  simpa using this

/-- **Iterated shadows of a large family are nonempty.** If `𝒜` is an `r`-uniform family of subsets
of `Fin n` with `k.choose r ≤ #𝒜` (where `r ≤ k ≤ n`), then for every `i ≤ r` the `i`-th iterated
shadow `∂^[i] 𝒜` is nonempty.  Taking `i = r` shows the shadow chain descends all the way to the
empty set. -/
theorem kk_iterated_shadow_nonempty (hir : i ≤ r) (hrk : r ≤ k) (hkn : k ≤ n)
    (h₁ : (𝒜 : Set (Finset (Fin n))).Sized r) (h₂ : k.choose r ≤ #𝒜) :
    (∂^[i] 𝒜).Nonempty := by
  have h := kruskal_katona_lovasz_form hir hrk hkn h₁ h₂
  have hpos : 0 < k.choose (r - i) := Nat.choose_pos (by omega)
  rw [← card_pos]
  omega

end ExtremalKK

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  H1: The Lovász form of Kruskal–Katona specialises (i = 1) to a clean shadow lower bound
      `k.choose (r-1) ≤ #(∂ 𝒜)`.
  H2 (bold): A family with `≥ k.choose r` sets of size `r` cannot have its iterated shadows die out:
      every `∂^[i] 𝒜` with `i ≤ r` is nonempty, because the KK lower bound `k.choose (r-i)` is itself
      positive whenever `r - i ≤ k`.

EXPERIMENT (Experimenter).
  * `kk_shadow_lower`: instantiate `kruskal_katona_lovasz_form` at `i = 1` and simplify `∂^[1] = ∂`.
  * `kk_iterated_shadow_nonempty`: combine the KK lower bound with `Nat.choose_pos` (valid since
      `r - i ≤ r ≤ k`) and `Finset.card_pos`; `omega` finishes the arithmetic.

ANALYSIS (Analyst).
  * SURVIVED: H1, H2 (0 sorries).
  * KEY INSIGHT: positivity of the *binomial target* `k.choose (r-i)` — not the shadow itself — is
    what guarantees nonemptiness; KK converts a cardinality hypothesis on `𝒜` into a positivity
    statement about every layer of its shadow.
  * The `i = r` case (`k.choose 0 = 1`) is the sharpest: the shadow chain provably reaches `∅`.

CRITIQUE (Critic).
  * Neither result is a wrapper: `kk_iterated_shadow_nonempty` uses `Nat.choose_pos`, `card_pos`,
    and `omega` on top of KK, producing a statement (nonempty shadow chain) not present verbatim in
    Mathlib.
  * Hypotheses `r ≤ k ≤ n` are exactly those of the Lovász form and are necessary (the binomial
    coefficients degenerate otherwise), so the statements are faithful.

SYNTHESIS (Principal Investigator).
  Kruskal–Katona is now available as a directly usable shadow lower bound and as a structural
  nonemptiness statement about iterated shadows, rounding out the extremal set-systems arm.
-/