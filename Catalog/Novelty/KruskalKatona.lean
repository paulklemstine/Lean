/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A combined Kruskal–Katona shadow bound

Mathlib proves the Kruskal–Katona theorem (`Finset.kruskal_katona`) and its
Lovász formulation (`Finset.kruskal_katona_lovasz_form`): an `r`-uniform family
`𝒜 ⊆ 𝒫(Fin n)` with `C(k, r) ≤ |𝒜|` has `i`-th shadow of size at least
`C(k, r - i)`.

Here we package the single-shadow case (`shadow_card_ge`) and then derive a
genuinely *combined* lower bound (`family_union_shadow_ge`):

  `C(k+1, r) ≤ |𝒜| + |∂𝒜|`,

i.e. a Kruskal–Katona-dense family together with its shadow already accounts for
a full `(k+1)`-vertex complete `r`-uniform family's worth of sets.  The proof
glues the Lovász shadow bound to **Pascal's recurrence**
`C(k+1, r) = C(k, r-1) + C(k, r)`.
-/
import Mathlib

namespace Catalog.Combinatorics.ExtremalGraphTheory

open Finset

/-- **Single-shadow Kruskal–Katona bound.**
An `r`-uniform family on `Fin n` with at least `C(k, r)` sets has a shadow of
size at least `C(k, r-1)`.  This is the `i = 1` case of the Lovász form. -/
theorem shadow_card_ge {n r k : ℕ} {𝒜 : Finset (Finset (Fin n))}
    (hr : 1 ≤ r) (hrk : r ≤ k) (hkn : k ≤ n)
    (h₁ : (𝒜 : Set (Finset (Fin n))).Sized r) (h₂ : k.choose r ≤ #𝒜) :
    k.choose (r - 1) ≤ #(Finset.shadow 𝒜) := by
  have := kruskal_katona_lovasz_form (i := 1) hr hrk hkn h₁ h₂
  simpa using this

/-- **Combined family + shadow lower bound (Kruskal–Katona + Pascal).**
If `𝒜` is an `r`-uniform family on `Fin n` with `C(k, r) ≤ |𝒜|`
(and `1 ≤ r ≤ k ≤ n`), then

  `C(k+1, r) ≤ |𝒜| + |∂𝒜|`.

The shadow contributes at least `C(k, r-1)` sets and the family at least
`C(k, r)`; Pascal's identity `C(k+1, r) = C(k, r-1) + C(k, r)` assembles the two
into a single `(k+1)`-level bound. -/
theorem family_union_shadow_ge {n r k : ℕ} {𝒜 : Finset (Finset (Fin n))}
    (hr : 1 ≤ r) (hrk : r ≤ k) (hkn : k ≤ n)
    (h₁ : (𝒜 : Set (Finset (Fin n))).Sized r) (h₂ : k.choose r ≤ #𝒜) :
    (k + 1).choose r ≤ #𝒜 + #(Finset.shadow 𝒜) := by
  have hs := shadow_card_ge hr hrk hkn h₁ h₂
  obtain ⟨r', rfl⟩ : ∃ r', r = r' + 1 := ⟨r - 1, by omega⟩
  have hpascal : (k + 1).choose (r' + 1) = k.choose r' + k.choose (r' + 1) :=
    Nat.choose_succ_succ k r'
  simp only [Nat.add_sub_cancel] at hs
  omega

/-
-- !-- Lab Notes -- !--

HYPOTHESIS.
  Kruskal–Katona lower bounds the shadow of a dense uniform family.  We
  hypothesised that the family and its shadow *jointly* clear the next Pascal
  level: `C(k+1, r) ≤ |𝒜| + |∂𝒜|`.

EXPERIMENT.
  `kruskal_katona_lovasz_form` at `i = 1` gives `|∂𝒜| ≥ C(k, r-1)` after
  `Function.iterate_one` (handled by `simpa`).  Writing `r = r' + 1` exposes the
  binomial recurrence `C(k+1, r'+1) = C(k, r') + C(k, r'+1)`; `omega` then closes
  the additive bound from `|𝒜| ≥ C(k,r)` and `|∂𝒜| ≥ C(k, r-1)`.

ANALYSIS.
  The combined bound is sharp exactly on initial segments (where both Lovász
  bounds are tight simultaneously), so the inequality cannot be improved without
  extra hypotheses.  The proof is genuinely two-ingredient: a deep extremal
  theorem (KK) plus an elementary identity (Pascal).

CRITIQUE.
  `shadow_card_ge` alone is close to a notation change of the Lovász form, so it
  is demoted to a helper; the *main* result `family_union_shadow_ge` adds the
  Pascal step and is not a wrapper.  The `r = 0` degenerate case is excluded by
  `1 ≤ r` (the shadow of `0`-sets is empty and the statement would be vacuous).

SYNTHESIS.
  Shadows of dense uniform families are not merely large in isolation: they
  combine additively with the family to reach the next complete level, a clean
  ladder-style consequence of Kruskal–Katona.
-/

end Catalog.Combinatorics.ExtremalGraphTheory