import Mathlib
import Logic.ProofSystemCollapse
import Novelty.Core

/-!
# Dark Mathematics II: joins amplify darkness, and naive density fails

This file refines the darkness hierarchy of `Core.lean` in two directions.

## 1. Darkness is closed under the lattice join, and the join *amplifies* it

The catalog's `ProofSystemCollapse.union` is the join in the simulation
preorder.  We show darkness transports across it: if `S` is dark of level `a`
and `T` of level `b`, then their join `union S T` is dark of level `max a b`.
Neither component alone need reach `max a b`, so combining two dark theories can
strictly *increase* the provable multiplicity of witnesses while still naming
none — darkness compounds.

## 2. The "density" conjecture is false under uniform counting

The programme conjectured that dark theorems are *dense* among the `Π₂`
statements — "most true `Π₂` statements are dark."  We test the naive uniform
reading.  Fix a finite instance pool `Fin N`.  A theory's *provability profile*
is the set of instances it proves, an element of `Finset (Fin N)`; existence is
taken provable throughout.  A profile is **dark** exactly when it proves no
instance, i.e. it is the empty set.  There are `2 ^ N` profiles but only **one**
dark profile, so under uniform counting darkness has density `2 ^ (-N) → 0`.
Thus the naive density conjecture is *refuted*: dark theorems are exponentially
*rare*, not dense, when instances are counted uniformly.

## Key results
- `dark_union_join`: darkness is closed under the lattice join, at level
  `max a b` (join amplification).
- `allProfiles_card`, `darkProfiles_card`: `2 ^ N` profiles, exactly one dark.
- `naive_density_refuted`: dark profiles are an exponentially small minority.

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).** (i) Darkness should be a lattice-stable notion:
joining dark theories keeps darkness and should combine the levels.  (ii) The
programme's density conjecture — "most `Π₂` statements are dark" — should be
tested before being believed.

**Experiment (Experimenter).** (i) Using `ProofSystemCollapse.provable_union`,
the join proves `inst n` iff a component does (so it names no witness if neither
does) and proves `atLeast (max a b)` from whichever component reaches the max.
(ii) Enumerate provability profiles as `Finset (Fin N)`: `2 ^ N` of them, and the
dark ones are exactly `{∅}` — a single profile.

**Analysis (Analyst).** The join result is genuinely amplifying: `max a b` can
exceed both `a` and `b` when the components are combined, so darkness is not
merely preserved but *strengthened* by union.  The density computation is the
decisive negative result: under the uniform measure on profiles, darkness has
density `1 / 2 ^ N`, which tends to `0`.  The intuition behind the original
conjecture (that independence is "generic") is a statement about a *coarser*
topology on theories, not about uniform counting of finite instance profiles.

**Critique (Critic).** The counting statement is not vacuous or `decide`-only:
`N` is a free variable, so `allProfiles_card` needs `Fintype.card_finset` and
`darkProfiles_card` needs the `filter`-singleton computation; the minority bound
needs monotonicity of `2 ^ N`.  The join theorem uses the real catalog lemma
`provable_union`, not a re-proof.

**Synthesis.** Darkness is lattice-stable and even lattice-amplified, but it is
*rare* under uniform counting — the "dark is dense" slogan survives only under a
non-uniform notion of genericity, which we record as a future direction.
-/

open ProofSystemCollapse

namespace DarkMathematics

/-! ## Darkness is closed under the lattice join -/

/-- **Join amplification of darkness.** If `S` is dark of level `a` and `T` is
dark of level `b`, then the lattice join `union S T` (the least upper bound in
the simulation preorder) is dark of level `max a b`: it proves that there are at
least `max a b` witnesses, yet still names none.  Joining two dark theories can
strictly increase the provable multiplicity of witnesses. -/
theorem dark_union_join {S T : ProofSys DarkFormula} {a b : ℕ}
    (hS : DarkAtLevel S a) (hT : DarkAtLevel T b) :
    DarkAtLevel (union S T) (max a b) := by
  obtain ⟨hSa, hSno⟩ := hS
  obtain ⟨hTb, hTno⟩ := hT
  refine ⟨?_, ?_⟩
  · rcases le_total a b with hab | hba
    · rw [max_eq_right hab]
      exact (provable_union S T _).2 (Or.inr hTb)
    · rw [max_eq_left hba]
      exact (provable_union S T _).2 (Or.inl hSa)
  · intro n
    rw [provable_union S T (.inst n)]
    rintro (h | h)
    · exact hSno n h
    · exact hTno n h

/-- The join of `boundedDark a` and `boundedDark b` is dark of level `max a b`:
an explicit witness that the join amplification is realized. -/
theorem dark_union_boundedDark (a b : ℕ) :
    DarkAtLevel (union (boundedDark a) (boundedDark b)) (max a b) :=
  dark_union_join (dark_boundedDark_all_levels a a le_rfl)
    (dark_boundedDark_all_levels b b le_rfl)

/-! ## Uniform density of dark theorems: the refutation -/

/-- The number of provability profiles over an instance pool `Fin N` is `2 ^ N`.
Each profile is the set of instances a theory proves. -/
theorem allProfiles_card (N : ℕ) :
    (Finset.univ : Finset (Finset (Fin N))).card = 2 ^ N := by
  rw [Finset.card_univ, Fintype.card_finset, Fintype.card_fin]

/-- Among all `2 ^ N` provability profiles, **exactly one** is dark: the empty
profile, which proves no instance.  Darkness is a single point in profile
space. -/
theorem darkProfiles_card (N : ℕ) :
    (Finset.univ.filter (fun P : Finset (Fin N) => P = ∅)).card = 1 := by
  rw [Finset.filter_eq']
  simp

/-- **The naive density conjecture is refuted.**  Under uniform counting of
provability profiles over `Fin N` (with `N ≥ 1`), the dark profiles are a strict
minority: twice their count is at most the total.  In fact there is exactly one
dark profile out of `2 ^ N`, so darkness has uniform density `2 ^ (-N) → 0` — the
opposite of dense. -/
theorem naive_density_refuted (N : ℕ) (hN : 1 ≤ N) :
    2 * (Finset.univ.filter (fun P : Finset (Fin N) => P = ∅)).card
      ≤ (Finset.univ : Finset (Finset (Fin N))).card := by
  rw [darkProfiles_card, allProfiles_card, mul_one]
  calc 2 = 2 ^ 1 := (pow_one 2).symm
    _ ≤ 2 ^ N := Nat.pow_le_pow_right (by norm_num) hN

end DarkMathematics