import Mathlib

/-!
# Factorial codes classify finite permutations

A length-`k` factorial code has digit `i` in `Fin (i+1)`.  This file proves
that these codes classify permutations of `Fin k`.  The construction factors
through numerical factoradic rank: the value of a code is the weighted sum
`∑ i, cᵢ i!`, and the recursive permutation rank uses the standard
`decomposeFin` equivalence.
-/

namespace FactorialLehmerClassification

open Equiv Finset

/-- The factorial-code space of length `k`. -/
abbrev FactorialCode (k : Nat) := ∀ i : Fin k, Fin (i.val + 1)

/-- Evaluation of a factorial code. -/
def codeValue {k : Nat} (c : FactorialCode k) : Nat :=
  ∑ i : Fin k, (c i).val * i.val.factorial

/-
Factorial evaluation always lies in `[0,k!)`.
-/
theorem codeValue_lt {k : Nat} (c : FactorialCode k) :
    codeValue c < k.factorial := by
  induction' k with k ih <;> simp_all +decide [ Fin.sum_univ_castSucc, codeValue ];
  rw [ Nat.factorial_succ, mul_comm ];
  nlinarith! [ ih ( fun i => c i.castSucc ), Fin.is_lt ( c ( Fin.last k ) ) ]

/-
Factorial evaluation is injective on bounded codes.
-/
theorem codeValue_injective {k : Nat} {c d : FactorialCode k}
    (h : codeValue c = codeValue d) : c = d := by
  induction' k with k ih;
  · exact Subsingleton.elim _ _;
  · -- By definition of `codeValue`, we can write
    have h_split : codeValue c = c (Fin.last k) * Nat.factorial k + codeValue (fun i => c i.castSucc) ∧ codeValue d = d (Fin.last k) * Nat.factorial k + codeValue (fun i => d i.castSucc) := by
      unfold codeValue; simp +decide [ Fin.sum_univ_castSucc ] ;
      exact ⟨ add_comm _ _, add_comm _ _ ⟩;
    -- By the properties of factorial codes, we know that $c (Fin.last k) = d (Fin.last k)$.
    have h_last : c (Fin.last k) = d (Fin.last k) := by
      have h_last : codeValue (fun i => c i.castSucc) < Nat.factorial k ∧ codeValue (fun i => d i.castSucc) < Nat.factorial k := by
        exact ⟨ codeValue_lt _, codeValue_lt _ ⟩;
      exact Fin.ext ( by nlinarith );
    ext i; induction i using Fin.lastCases <;> simp_all +decide ;
    exact congr_arg Fin.val ( congr_fun ( ih h ) _ )

/-
There are exactly `k!` factorial codes of length `k`.
-/
theorem card_factorialCode (k : Nat) :
    Fintype.card (FactorialCode k) = k.factorial := by
  induction' k with k ih <;> simp_all +decide [ Nat.factorial_succ ];
  rw [ ← ih, Fin.prod_univ_castSucc ] ; norm_num;
  ring

/-- Factorial evaluation, regarded as a map into `Fin (k!)`. -/
def codeRank (k : Nat) (c : FactorialCode k) : Fin k.factorial :=
  ⟨codeValue c, codeValue_lt c⟩

/-- Evaluation gives the complete numerical classification of factorial codes. -/
noncomputable def codeRankEquiv (k : Nat) : FactorialCode k ≃ Fin k.factorial :=
  Equiv.ofBijective (codeRank k) <|
    (Fintype.bijective_iff_injective_and_card (codeRank k)).2 ⟨by
      intro c d h
      apply codeValue_injective
      exact Fin.ext_iff.mp h, by
      rw [card_factorialCode, Fintype.card_fin]⟩

/-- Recursive factoradic rank/unrank equivalence for permutations.  At the
successor step, `decomposeFin` selects one of `k+1` positions and a permutation
of the remaining `k` positions. -/
def rankPermEquiv : (k : Nat) → Fin k.factorial ≃ Equiv.Perm (Fin k)
  | 0 => (finCongr (by simp : Nat.factorial 0 = 1)).trans (Equiv.ofUnique _ _)
  | k + 1 =>
      (finCongr (Nat.factorial_succ k)).trans <|
        finProdFinEquiv.symm.trans <|
          (Equiv.prodCongr (Equiv.refl (Fin (k + 1))) (rankPermEquiv k)).trans <|
            Equiv.Perm.decomposeFin.symm

/-- The canonical Lehmer classification induced by factoradic evaluation and
recursive decomposition of finite permutations. -/
noncomputable def lehmerEquiv (k : Nat) :
    FactorialCode k ≃ Equiv.Perm (Fin k) :=
  (codeRankEquiv k).trans (rankPermEquiv k)

/-
The permutation rank of a factorial code is exactly its factoradic
numerical evaluation.
-/
theorem lehmer_rank_eq_codeValue (k : Nat) (c : FactorialCode k) :
    ((rankPermEquiv k).symm (lehmerEquiv k c)).val = codeValue c := by
  unfold lehmerEquiv; aesop;

/-
Every permutation has a unique factorial code.
-/
theorem existsUnique_code (k : Nat) (σ : Equiv.Perm (Fin k)) :
    ∃! c : FactorialCode k, lehmerEquiv k c = σ := by
  exact ⟨ _, ( lehmerEquiv k ).apply_symm_apply σ, fun x hx => ( lehmerEquiv k ).injective <| hx.trans <| ( lehmerEquiv k ).apply_symm_apply σ |> Eq.symm ⟩

/-
Two factorial codes classify the same permutation exactly when all their
digits agree.
-/
theorem lehmerEquiv_eq_iff (k : Nat) (c d : FactorialCode k) :
    lehmerEquiv k c = lehmerEquiv k d ↔ c = d := by
  exact ⟨ fun h => Equiv.injective ( lehmerEquiv k ) h, fun h => h ▸ rfl ⟩

/-
Two classified permutations agree exactly when the factoradic evaluations
of their codes agree.
-/
theorem lehmerEquiv_eq_iff_codeValue_eq (k : Nat) (c d : FactorialCode k) :
    lehmerEquiv k c = lehmerEquiv k d ↔ codeValue c = codeValue d := by
  constructor
  · intro h
    exact congrArg codeValue ((lehmerEquiv k).injective h)
  · intro h
    exact congrArg (lehmerEquiv k) (codeValue_injective h)

/-
The classification recovers the factorial count of permutations.
-/
theorem card_permutations_via_codes (k : Nat) :
    Fintype.card (Equiv.Perm (Fin k)) = k.factorial := by
  exact (Fintype.card_congr (lehmerEquiv k).symm).trans (card_factorialCode k)

/-- Kernel-checked small cases underlying the computational evidence table. -/
theorem small_card_counts :
    Fintype.card (FactorialCode 0) = 1 ∧
    Fintype.card (FactorialCode 1) = 1 ∧
    Fintype.card (FactorialCode 2) = 2 ∧
    Fintype.card (FactorialCode 3) = 6 ∧
    Fintype.card (FactorialCode 4) = 24 ∧
    Fintype.card (FactorialCode 5) = 120 := by
  constructor
  · exact card_factorialCode 0
  constructor
  · exact card_factorialCode 1
  constructor
  · norm_num [card_factorialCode 2]
  constructor
  · norm_num [card_factorialCode 3]
  constructor
  · norm_num [card_factorialCode 4]
  · norm_num [card_factorialCode 5]

end FactorialLehmerClassification