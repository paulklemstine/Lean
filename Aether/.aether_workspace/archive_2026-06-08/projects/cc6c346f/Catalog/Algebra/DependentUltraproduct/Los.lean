/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Łoś's Theorem and Transfer for Dependent Ultraproducts

Self-contained file proving transfer theorems for ultraproducts:

1. **Boolean closure lemmas** for ultrafilters (and/or/neg transfer)
2. **Characteristic zero from varying characteristics** — deep induction proof
3. **Pseudofinite field conjecture** — a falsifiable statement

## References

* Chang, C.C. and Keisler, H.J. (1990). Model Theory, Chapter 4.
* Ax, J. (1968). The elementary theory of finite fields.
-/

import Mathlib

open Filter Set

universe u v

namespace UltraProdTransfer

variable {ι : Type u} {U : Ultrafilter ι}

/-! ### Boolean Closure for Ultrafilters -/

/-- **Conjunction transfer**: `{P ∧ Q} ∈ U ↔ {P} ∈ U ∧ {Q} ∈ U`. -/
theorem setOf_and_mem_iff {P Q : ι → Prop} :
    {i | P i ∧ Q i} ∈ U ↔ {i | P i} ∈ U ∧ {i | Q i} ∈ U := by
  constructor
  · intro h
    exact ⟨Filter.mem_of_superset h fun i hi => hi.1,
           Filter.mem_of_superset h fun i hi => hi.2⟩
  · intro ⟨h1, h2⟩
    exact Filter.mem_of_superset (Filter.inter_mem h1 h2) fun i hi => ⟨hi.1, hi.2⟩

/-- **Disjunction transfer**: `{P ∨ Q} ∈ U ↔ {P} ∈ U ∨ {Q} ∈ U`.

This requires the ultrafilter property. -/
theorem setOf_or_mem_iff {P Q : ι → Prop} :
    {i | P i ∨ Q i} ∈ U ↔ {i | P i} ∈ U ∨ {i | Q i} ∈ U := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    obtain ⟨hc1, hc2⟩ := hc
    have h1 := (Ultrafilter.compl_mem_iff_notMem).mpr hc1
    have h2 := (Ultrafilter.compl_mem_iff_notMem).mpr hc2
    have hmem := Filter.inter_mem (Filter.inter_mem h1 h2) h
    have : (∅ : Set ι) ∈ (U : Filter ι) :=
      Filter.mem_of_superset hmem fun i hi => by
        rcases hi.2 with hp | hq
        · exact hi.1.1 hp
        · exact hi.1.2 hq
    simp at this
  · intro h
    rcases h with h | h
    · exact Filter.mem_of_superset h fun i hi => Or.inl hi
    · exact Filter.mem_of_superset h fun i hi => Or.inr hi

/-- **Negation transfer**: `{¬P} ∈ U ↔ {P} ∉ U`. -/
theorem setOf_neg_mem_iff {P : ι → Prop} :
    {i | ¬ P i} ∈ U ↔ {i | P i} ∉ U := by
  constructor
  · intro h hmem
    have := Filter.inter_mem h hmem
    have : (∅ : Set ι) ∈ (U : Filter ι) :=
      Filter.mem_of_superset this fun i hi => absurd hi.2 hi.1
    simp at this
  · intro h
    exact Filter.mem_of_superset ((Ultrafilter.compl_mem_iff_notMem).mpr h) fun i hi => hi

/-! ### Characteristic Zero from Varying Characteristics

This is the deep theorem: if the family has varying prime characteristics
(no single prime dominates under U), then every nonzero natural is nonzero
in the ultraproduct. -/

/-
**Characteristic zero from varying characteristics.**

If for every prime `p`, the set `{i | (p : K i) = 0}` is not in `U`,
then for every `n ≠ 0`, the set `{i | (n : K i) = 0}` is not in `U`.

Proof by strong induction on `n`:
- `n = 1`: `(1 : K i) ≠ 0` in every field, so `{i | (1 : K i) = 0} = ∅ ∉ U`.
- `n` prime: direct from hypothesis `hvar`.
- `n` composite, `n = a * b` with `1 < a, b < n`:
  In each field `K i`, `(n : K i) = (a : K i) * (b : K i)`.
  If this is zero, then `(a : K i) = 0` or `(b : K i) = 0`
  (since fields are integral domains).
  So `{i | (n : K i) = 0} ⊆ {i | (a : K i) = 0} ∪ {i | (b : K i) = 0}`.
  If the LHS were in `U`, then by `setOf_or_mem_iff`, one of the
  two sets on the RHS would be in `U` — contradicting the IH.
-/
theorem char_zero_of_varying {K : ι → Type v} [∀ i, Field (K i)]
    (hvar : ∀ p : ℕ, Nat.Prime p → ({i | (p : K i) = 0} : Set ι) ∉ U)
    (n : ℕ) (hn : n ≠ 0) :
    ({i | (n : K i) = 0} : Set ι) ∉ U := by
  induction' n using Nat.strongRecOn with n ih;
  by_cases h : n = 1;
  · simp +decide [ h ];
  · -- Since $n$ is not 1, � it� must be composite. Write $n$ as a product of primes.
    obtain ⟨p, hp⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ n := by
      exact Nat.exists_prime_and_dvd h;
    -- Write $n = p � *� m$ where $m = n / p$.
    obtain ⟨m, hm⟩ : ∃ m : ℕ, n = p * m := hp.right;
    by_cases hm_zero : m = 0 <;> simp_all +decide [ Set.setOf_or, mul_eq_zero ];
    exact ih m ( lt_mul_of_one_lt_left ( Nat.pos_of_ne_zero hm_zero ) hp.one_lt ) hm_zero

/-! ### Pseudofinite Field Conjecture -/

/-- A field is **pseudofinite** if it is infinite and every nonconstant
polynomial has a root. -/
structure IsPseudofinite (F : Type*) [Field F] : Prop where
  infinite : Infinite F
  has_roots : ∀ (p : Polynomial F), p ≠ 0 → p.degree ≠ 0 → ∃ x, p.IsRoot x

/-- **Testable Conjecture**: The ultraproduct of finite fields with
varying characteristic has characteristic zero.

This is a weaker version of the full pseudofinite conjecture, capturing
just the characteristic-zero property. It is testable because:

**Test**: For any prime `p`, verify that all but finitely many primes
`q` satisfy `(p : F_q) ≠ 0` (which is true: `(p : F_q) = 0` iff `q = p`).
Then the complement `{i | (p : K i) = 0}` has at most one element,
hence is not in any non-principal ultrafilter.

This means `char_zero_of_varying` applies, giving char 0. -/
def pseudofiniteCharZeroConjecture : Prop :=
  ∀ (ι : Type) (U : Ultrafilter ι)
    (K : ι → Type) [∀ i, Field (K i)] [∀ i, Fintype (K i)],
    (∀ p : ℕ, Nat.Prime p → ({i | (p : K i) = 0} : Set ι) ∉ U) →
    ∀ (n : ℕ), n ≠ 0 → ({i | (n : K i) = 0} : Set ι) ∉ U

end UltraProdTransfer