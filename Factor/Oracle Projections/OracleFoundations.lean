import Mathlib

/-!
# Oracle Foundations

An **oracle** is an idempotent map O : X → X with O² = O.
The **truth set** Fix(O) = {x | O(x) = x} is the solution space.

## Main Results

- `oracle_iterate_stable`: O^n = O for all n ≥ 1 (given idempotency)
- `oracle_range_eq_fixedPoints`: Im(O) = Fix(O)
- `oracle_constant_fixedPoints`: Fix(O_c) = {c}
- `oracle_lens_collapse`: O(σ(σ⁻¹(O(x)))) = O(x) for any round-trip σ
-/

open Function Set

section OracleFoundations

variable {X : Type*}

/-
PROBLEM
An oracle stabilizes after one consultation: O^n = O for all n ≥ 1,
    given that O is idempotent (O ∘ O = O).

PROVIDED SOLUTION
Induction on n. Base n=1: O^[1] = O trivially. Step: O^[n+1] = O ∘ O^[n] = O ∘ O (by IH) = O (by hO). Use Function.iterate_succ' and congr_fun hO.
-/
theorem oracle_iterate_stable (O : X → X) (hO : O ∘ O = O) :
    ∀ n : ℕ, n ≥ 1 → O^[n] = O := by
      intro n hn; induction hn <;> simp +decide [ *, Function.iterate_succ_apply' ] ;

/-
PROBLEM
The range of an oracle equals its fixed point set.

PROVIDED SOLUTION
ext y; simp only [mem_range, mem_setOf_eq]. Forward: given ⟨x, hx⟩, have O y = O (O x) = O x = y using congr_fun hO. Reverse: given O y = y, use ⟨y, (O y = y).symm⟩... actually ⟨y, hy⟩ doesn't work directly. Use ⟨y, hy.symm⟩ to get O y = y means y = O y so y ∈ range O. Wait, range O means ∃ x, O x = y. If O y = y then ⟨y, rfl⟩... wait O y = y means (fun x => O x) applied to y gives y, so ⟨y, by exact hy⟩ works since O y = y.
-/
theorem oracle_range_eq_fixedPoints (O : X → X) (hO : O ∘ O = O) :
    range O = {x | O x = x} := by
      simp +decide [ funext_iff, Set.ext_iff ] at * ; aesop?;

/-
PROBLEM
A constant oracle has a singleton truth set.

PROVIDED SOLUTION
ext x; simp. The condition (fun _ => c) x = x simplifies to c = x, which is x ∈ {c}.
-/
theorem oracle_constant_fixedPoints (c : X) :
    {x | (fun _ => c) x = x} = {c} := by
      aesop

/-
PROBLEM
The oracle-lens collapse: composing an oracle with any round-trip gives the oracle.

PROVIDED SOLUTION
intro x; rw [hrt]; exact congr_fun hO x.
-/
theorem oracle_lens_collapse (O : X → X) (hO : O ∘ O = O)
    {Y : Type*} (σ : Y → X) (σ_inv : X → Y)
    (hrt : ∀ x, σ (σ_inv x) = x) :
    ∀ x, O (σ (σ_inv (O x))) = O x := by
      simp_all +decide [ funext_iff ]

end OracleFoundations