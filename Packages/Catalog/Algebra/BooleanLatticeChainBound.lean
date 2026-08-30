/-
# Forbidden Boolean-lattice subposets: the chain bound and its sharpening

This file develops, from scratch, a formal framework for the extremal problem

  `La(n, B_d) = max { |F| : F ⊆ 2^[n], F contains no (weak) copy of the Boolean lattice B_d }`

and proves the classical *chain bound* `La(n, B_d) ≤ (2^d - 1) * C(n, ⌊n/2⌋)`
together with a number of complementary results relevant to the conjecture
`La(n, B_d) ≤ (d + c) * C(n, ⌊n/2⌋)` for an absolute constant `c`.

## Main definitions

* `HasBdCopy d F` : the family `F` of subsets of `Fin n` contains a *weak* copy of the
  `d`-dimensional Boolean lattice, i.e. an injective, containment-preserving map
  `Finset (Fin d) → F`.
* `BdFree d F`    : `F` contains no such copy.
* `HasChain k F`  : `F` contains a strictly increasing chain of `k` sets.
* `La n d`        : the extremal function, the supremum of `|F|` over `B_d`-free `F`.

## Main results

* `hasBdCopy_of_hasChain`    : a chain of `2^d` sets already yields a weak copy of `B_d`.
* `lubell_le_of_no_chain`    : the Lubell mass of a `(k+1)`-chain-free family is at most `k`
  (a Mirsky-type induction feeding into the LYM inequality). This is strictly stronger
  than the corresponding cardinality bound.
* `card_le_of_bdFree`        : the chain bound `|F| ≤ (2^d - 1) * C(n, ⌊n/2⌋)`.
* `La_le_chain_bound`        : `La n d ≤ (2^d - 1) * C(n, ⌊n/2⌋)`.
* `La_one`                   : `La n 1 = C(n, ⌊n/2⌋)` (Sperner's theorem, both directions).
* `La_le_height_bound`       : `La n d ≤ (n+1) * C(n, ⌊n/2⌋)`, hence the conjectured bound
  `(d + 1) * C(n, ⌊n/2⌋)` holds unconditionally whenever `n ≤ d`.
* `La_three_le_four_of_le_eight` : the conjectured `d = 3` bound `La n 3 ≤ 4 * C(n, ⌊n/2⌋)`
  holds for every `n ≤ 8`.
* `La_ge_consecutive_levels` : the lower bound coming from `d` consecutive levels,
  `La n d ≥ ∑_{i=a}^{a+d-1} C(n, i)`.
* `hasBdCopy_succ_of_stacked` and `hasBdCopy_succ_of_parallel_chains` : a *doubling*
  criterion showing that a `B_{d+1}` copy already arises from two "parallel" `B_d` copies,
  a configuration strictly weaker than a single long chain.
-/

import Mathlib

namespace Catalog.Algebra.BooleanLatticeChainBound

open Finset

/-! ## The central binomial coefficient -/

/-- The size of the largest layer of the Boolean lattice `2^[n]`. -/
def central (n : ℕ) : ℕ := n.choose (n / 2)

lemma central_pos (n : ℕ) : 0 < central n := Nat.choose_pos (Nat.div_le_self _ _)

lemma choose_le_central (n r : ℕ) : n.choose r ≤ central n := Nat.choose_le_middle r n

/-! ## Weak copies of the Boolean lattice -/

variable {n : ℕ}

/-- `F` contains a *weak* copy of the `d`-dimensional Boolean lattice `B d`: an injective map
from the subsets of `Fin d` into `F` which preserves containment (not necessarily an induced
subposet). -/
def HasBdCopy (d : ℕ) (F : Finset (Finset (Fin n))) : Prop :=
  ∃ f : Finset (Fin d) → Finset (Fin n),
    Function.Injective f ∧ (∀ S, f S ∈ F) ∧ ∀ S T : Finset (Fin d), S ⊆ T → f S ⊆ f T

/-- `F` is `B d`-free. -/
def BdFree (d : ℕ) (F : Finset (Finset (Fin n))) : Prop := ¬ HasBdCopy d F

/-- `F` contains a strictly increasing chain of `k` sets. -/
def HasChain (k : ℕ) (F : Finset (Finset (Fin n))) : Prop :=
  ∃ g : ℕ → Finset (Fin n), (∀ i < k, g i ∈ F) ∧ ∀ i j, i < j → j < k → g i ⊂ g j

lemma bdFree_empty (d : ℕ) : BdFree (n := n) d ∅ := by
  rintro ⟨f, -, hf, -⟩
  simpa using hf ∅

/-! ## A linear extension of `B d` -/

instance instFintypeLinearExtension (d : ℕ) : Fintype (LinearExtension (Finset (Fin d))) :=
  inferInstanceAs (Fintype (Finset (Fin d)))

/-- A rank function realising a linear extension of the Boolean lattice `B d`: it is injective,
containment-monotone, and takes values in `{0, …, 2^d - 1}`. -/
noncomputable def rank (d : ℕ) (S : Finset (Fin d)) : ℕ :=
  ((monoEquivOfFin (LinearExtension (Finset (Fin d)))
      (by show Fintype.card (Finset (Fin d)) = 2 ^ d; simp)).symm (toLinearExtension S) : Fin (2 ^ d))

lemma rank_lt (d : ℕ) (S : Finset (Fin d)) : rank d S < 2 ^ d :=
  Fin.is_lt _

lemma rank_injective (d : ℕ) : Function.Injective (rank d) := by
  intro a b hab
  have h : (monoEquivOfFin (LinearExtension (Finset (Fin d)))
      (by show Fintype.card (Finset (Fin d)) = 2 ^ d; simp)).symm (toLinearExtension a)
      = (monoEquivOfFin (LinearExtension (Finset (Fin d)))
      (by show Fintype.card (Finset (Fin d)) = 2 ^ d; simp)).symm (toLinearExtension b) :=
    Fin.ext hab
  exact (OrderIso.injective _ h : (toLinearExtension a) = toLinearExtension b)

lemma rank_mono (d : ℕ) {S T : Finset (Fin d)} (h : S ⊆ T) : rank d S ≤ rank d T := by
  have : (monoEquivOfFin (LinearExtension (Finset (Fin d)))
      (by show Fintype.card (Finset (Fin d)) = 2 ^ d; simp)).symm (toLinearExtension S)
      ≤ (monoEquivOfFin (LinearExtension (Finset (Fin d)))
      (by show Fintype.card (Finset (Fin d)) = 2 ^ d; simp)).symm (toLinearExtension T) :=
    OrderIso.monotone _ (toLinearExtension.monotone h)
  exact this

/-! ## Chains produce Boolean-lattice copies -/

/-- Composing a strictly increasing chain of length `2^d` with the rank function of `B d`
produces an injective, containment-preserving map from `B d`. -/
lemma chain_comp_rank {d : ℕ} {g : ℕ → Finset (Fin n)}
    (hg : ∀ i j, i < j → j < 2 ^ d → g i ⊂ g j) :
    Function.Injective (fun S : Finset (Fin d) => g (rank d S)) ∧
      ∀ S T : Finset (Fin d), S ⊆ T → g (rank d S) ⊆ g (rank d T) := by
  constructor
  · intro S T hST
    by_contra hne
    rcases lt_trichotomy (rank d S) (rank d T) with h | h | h
    · exact (Finset.ssubset_iff_subset_ne.1 (hg _ _ h (rank_lt d T))).2 hST
    · exact hne (rank_injective d h)
    · exact (Finset.ssubset_iff_subset_ne.1 (hg _ _ h (rank_lt d S))).2 hST.symm
  · intro S T hST
    rcases eq_or_lt_of_le (rank_mono d hST) with h | h
    · rw [h]
    · exact (Finset.ssubset_iff_subset_ne.1 (hg _ _ h (rank_lt d T))).1

/-- A chain of `2^d` sets inside `F` already contains a weak copy of `B d`. -/
theorem hasBdCopy_of_hasChain {d : ℕ} {F : Finset (Finset (Fin n))}
    (h : HasChain (2 ^ d) F) : HasBdCopy d F := by
  obtain ⟨g, hmem, hg⟩ := h
  obtain ⟨hinj, hmono⟩ := chain_comp_rank (n := n) (d := d) (g := g) hg
  exact ⟨fun S => g (rank d S), hinj, fun S => hmem _ (rank_lt d S), hmono⟩

/-- A `B d`-free family contains no chain of `2^d` sets. -/
theorem no_chain_of_bdFree {d : ℕ} {F : Finset (Finset (Fin n))} (h : BdFree d F) :
    ¬ HasChain (2 ^ d) F := fun hc => h (hasBdCopy_of_hasChain hc)

/-! ## Mirsky + LYM : the Lubell mass of a chain-free family -/

/-- The Lubell mass `∑_{A ∈ F} 1 / C(n, |A|)` of a family. -/
noncomputable def lubell (F : Finset (Finset (Fin n))) : ℝ :=
  ∑ A ∈ F, ((n.choose A.card : ℝ))⁻¹

/-- The set of maximal members of a family. -/
def maximals (F : Finset (Finset (Fin n))) : Finset (Finset (Fin n)) :=
  F.filter (fun A => ∀ B ∈ F, ¬ A ⊂ B)

lemma maximals_subset (F : Finset (Finset (Fin n))) : maximals F ⊆ F :=
  Finset.filter_subset _ _

lemma isAntichain_maximals (F : Finset (Finset (Fin n))) :
    IsAntichain (· ⊆ ·) ((maximals F : Finset (Finset (Fin n))) : Set (Finset (Fin n))) := by
  intro A hA B hB hne hsub
  simp only [maximals, Finset.coe_filter, Set.mem_setOf_eq] at hA hB
  exact hA.2 B hB.1 (Finset.ssubset_iff_subset_ne.2 ⟨hsub, hne⟩)

lemma lubell_maximals_le_one (F : Finset (Finset (Fin n))) : lubell (maximals F) ≤ 1 := by
  have h := Finset.lubell_yamamoto_meshalkin_inequality_sum_inv_choose (𝕜 := ℝ)
    (isAntichain_maximals F)
  simpa [lubell, Fintype.card_fin] using h

/-- Every non-maximal member of a family sits strictly below some member. -/
lemma exists_gt_of_not_maximal {F : Finset (Finset (Fin n))} {A : Finset (Fin n)}
    (hA : A ∈ F) (hnot : A ∉ maximals F) : ∃ B ∈ F, A ⊂ B := by
  simp only [maximals, Finset.mem_filter, not_and, not_forall] at hnot
  obtain ⟨B, hB⟩ := hnot hA
  simp only [not_not] at hB
  exact ⟨B, hB.1, hB.2⟩

/-- Removing the maximal elements kills one level of chains. -/
lemma no_chain_sdiff_maximals {k : ℕ} {F : Finset (Finset (Fin n))}
    (h : ¬ HasChain (k + 2) F) : ¬ HasChain (k + 1) (F \ maximals F) := by
  rintro ⟨g, hmem, hg⟩
  have hgk : g k ∈ F \ maximals F := hmem k (Nat.lt_succ_self k)
  have hgkF : g k ∈ F := (Finset.mem_sdiff.1 hgk).1
  obtain ⟨B, hBF, hgB⟩ := exists_gt_of_not_maximal hgkF (Finset.mem_sdiff.1 hgk).2
  refine h ⟨fun i => if i < k + 1 then g i else B, ?_, ?_⟩
  · intro i hi
    by_cases hik : i < k + 1
    · simpa [hik] using (Finset.mem_sdiff.1 (hmem i hik)).1
    · simpa [hik] using hBF
  · intro i j hij hj
    by_cases hjk : j < k + 1
    · have hik : i < k + 1 := lt_trans hij hjk
      simpa [hik, hjk] using hg i j hij hjk
    · have hik : i < k + 1 := by omega
      have hjB : ¬ j < k + 1 := hjk
      rcases eq_or_lt_of_le (Nat.lt_succ_iff.1 hik) with hik' | hik'
      · simpa [hik, hjB, hik'] using hgB
      · have : g i ⊂ g k := hg i k hik' (Nat.lt_succ_self k)
        simpa [hik, hjB] using this.trans hgB
  
/-- **Mirsky + LYM.** A family with no chain of `k+1` sets has Lubell mass at most `k`. -/
theorem lubell_le_of_no_chain :
    ∀ (k : ℕ) (F : Finset (Finset (Fin n))), ¬ HasChain (k + 1) F → lubell F ≤ k := by
  intro k
  induction k with
  | zero =>
    intro F hF
    have hempty : F = ∅ := by
      by_contra hne
      obtain ⟨A, hA⟩ := Finset.nonempty_iff_ne_empty.2 hne
      exact hF ⟨fun _ => A, fun i _ => hA, by omega⟩
    simp [lubell, hempty]
  | succ k ih =>
    intro F hF
    have hsub : maximals F ⊆ F := maximals_subset F
    have hsplit : lubell (F \ maximals F) + lubell (maximals F) = lubell F := by
      simpa [lubell] using
        (Finset.sum_sdiff (f := fun A : Finset (Fin n) => ((n.choose A.card : ℝ))⁻¹) hsub)
    have h1 : lubell (F \ maximals F) ≤ k := ih _ (no_chain_sdiff_maximals hF)
    have h2 : lubell (maximals F) ≤ 1 := lubell_maximals_le_one F
    have := add_le_add h1 h2
    rw [hsplit] at this
    push_cast
    linarith

/-- The Lubell mass dominates `|F| / C(n, ⌊n/2⌋)`. -/
lemma card_le_of_lubell_le {F : Finset (Finset (Fin n))} {k : ℕ} (h : lubell F ≤ k) :
    F.card ≤ k * central n := by
  have hc : (0 : ℝ) < central n := by exact_mod_cast central_pos n
  have hterm : ∀ A ∈ F, ((central n : ℝ))⁻¹ ≤ ((n.choose A.card : ℝ))⁻¹ := by
    intro A _
    have h1 : (0 : ℝ) < n.choose A.card := by
      have : 0 < n.choose A.card := Nat.choose_pos (by simpa using A.card_le_univ)
      exact_mod_cast this
    have h2 : (n.choose A.card : ℝ) ≤ central n := by exact_mod_cast choose_le_central n A.card
    have := one_div_le_one_div_of_le h1 h2
    simpa [one_div] using this
  have hsum : (F.card : ℝ) * ((central n : ℝ))⁻¹ ≤ lubell F := by
    have := Finset.sum_le_sum hterm
    simpa [lubell, Finset.sum_const, nsmul_eq_mul, mul_comm] using this
  have : (F.card : ℝ) ≤ k * central n := by
    have h' : (F.card : ℝ) * ((central n : ℝ))⁻¹ ≤ k := le_trans hsum h
    calc (F.card : ℝ) = ((F.card : ℝ) * ((central n : ℝ))⁻¹) * central n := by
            field_simp
      _ ≤ (k : ℝ) * central n := by nlinarith
  exact_mod_cast this

/-- A family with no chain of `k+1` sets has at most `k * C(n, ⌊n/2⌋)` members. -/
theorem card_le_of_no_chain {k : ℕ} {F : Finset (Finset (Fin n))} (h : ¬ HasChain (k + 1) F) :
    F.card ≤ k * central n :=
  card_le_of_lubell_le (lubell_le_of_no_chain k F h)

lemma hasChain_mono {k m : ℕ} {F : Finset (Finset (Fin n))} (hkm : k ≤ m)
    (h : HasChain m F) : HasChain k F := by
  obtain ⟨g, hmem, hg⟩ := h
  exact ⟨g, fun i hi => hmem i (lt_of_lt_of_le hi hkm),
    fun i j hij hj => hg i j hij (lt_of_lt_of_le hj hkm)⟩

/-! ## The chain bound -/

/-- **The chain bound.** A `B d`-free family has at most `(2^d - 1) * C(n, ⌊n/2⌋)` members. -/
theorem card_le_of_bdFree {d : ℕ} {F : Finset (Finset (Fin n))} (h : BdFree d F) :
    F.card ≤ (2 ^ d - 1) * central n := by
  have hpos : 1 ≤ 2 ^ d := Nat.one_le_two_pow
  have hEq : 2 ^ d - 1 + 1 = 2 ^ d := by omega
  refine card_le_of_no_chain (k := 2 ^ d - 1) ?_
  rw [hEq]
  exact no_chain_of_bdFree h

/-- The Lubell-mass form of the chain bound. -/
theorem lubell_le_of_bdFree {d : ℕ} {F : Finset (Finset (Fin n))} (h : BdFree d F) :
    lubell F ≤ (2 ^ d - 1 : ℕ) := by
  have hEq : 2 ^ d - 1 + 1 = 2 ^ d := by
    have : 1 ≤ 2 ^ d := Nat.one_le_two_pow
    omega
  refine lubell_le_of_no_chain (2 ^ d - 1) F ?_
  rw [hEq]
  exact no_chain_of_bdFree h

/-! ## Chains in `2^[n]` have length at most `n+1` -/

lemma card_le_of_chain {k : ℕ} {g : ℕ → Finset (Fin n)}
    (hg : ∀ i j, i < j → j < k → g i ⊂ g j) : ∀ i, i < k → i ≤ (g i).card := by
  intro i
  induction i with
  | zero => intro _; exact Nat.zero_le _
  | succ i ih =>
    intro hik
    have hi : i < k := by omega
    have h1 : i ≤ (g i).card := ih hi
    have h2 : (g i).card < (g (i + 1)).card :=
      Finset.card_lt_card (hg i (i + 1) (Nat.lt_succ_self i) hik)
    omega

/-- There is no chain of `n+2` sets in `2^[n]`: the Boolean lattice has height `n+1`. -/
theorem no_chain_height (F : Finset (Finset (Fin n))) : ¬ HasChain (n + 2) F := by
  rintro ⟨g, -, hg⟩
  have h1 : n + 1 ≤ (g (n + 1)).card := card_le_of_chain hg (n + 1) (by omega)
  have h2 : (g (n + 1)).card ≤ n := by simpa using (g (n + 1)).card_le_univ
  omega

/-- Unconditional bound: any family has at most `(n+1) * C(n, ⌊n/2⌋)` members. -/
theorem card_le_height_bound (F : Finset (Finset (Fin n))) : F.card ≤ (n + 1) * central n :=
  card_le_of_no_chain (k := n + 1) (no_chain_height F)

/-! ## The extremal function `La` -/

/-- The set of sizes of `B d`-free families in `2^[n]`. -/
def LaSet (n d : ℕ) : Set ℕ := {m | ∃ F : Finset (Finset (Fin n)), BdFree d F ∧ F.card = m}

/-- `La n d` : the maximal size of a `B d`-free family of subsets of `[n]`. -/
noncomputable def La (n d : ℕ) : ℕ := sSup (LaSet n d)

lemma LaSet_nonempty (n d : ℕ) : (LaSet n d).Nonempty :=
  ⟨0, ∅, bdFree_empty d, Finset.card_empty⟩

lemma LaSet_bddAbove (n d : ℕ) : BddAbove (LaSet n d) := by
  refine ⟨2 ^ n, ?_⟩
  rintro m ⟨F, -, rfl⟩
  have : F.card ≤ Fintype.card (Finset (Fin n)) := Finset.card_le_univ F
  simpa using this

/-- Every `B d`-free family is bounded by `La n d`. -/
theorem le_La {d : ℕ} {F : Finset (Finset (Fin n))} (hF : BdFree d F) : F.card ≤ La n d :=
  le_csSup (LaSet_bddAbove n d) ⟨F, hF, rfl⟩

/-- Any uniform upper bound for `B d`-free families bounds `La n d`. -/
theorem La_le {n d b : ℕ} (h : ∀ F : Finset (Finset (Fin n)), BdFree d F → F.card ≤ b) :
    La n d ≤ b :=
  csSup_le (LaSet_nonempty n d) (by rintro m ⟨F, hF, rfl⟩; exact h F hF)

/-- **The chain bound for `La`.** -/
theorem La_le_chain_bound (n d : ℕ) : La n d ≤ (2 ^ d - 1) * central n :=
  La_le fun _ hF => card_le_of_bdFree hF

/-- The height bound: `La n d ≤ (n+1) * C(n, ⌊n/2⌋)` for every `d`. -/
theorem La_le_height_bound (n d : ℕ) : La n d ≤ (n + 1) * central n :=
  La_le fun F _ => card_le_height_bound F

/-- The trivial bound `La n d ≤ 2^n`. -/
theorem La_le_two_pow (n d : ℕ) : La n d ≤ 2 ^ n :=
  La_le fun F _ => by simpa using Finset.card_le_univ F

/-- Monotonicity in `d`: a `B d`-free family is `B (d+1)`-free, so `La n d ≤ La n (d+1)`. -/
theorem bdFree_of_bdFree_succ {d : ℕ} {F : Finset (Finset (Fin n))} (h : BdFree d F) :
    BdFree (d + 1) F := by
  rintro ⟨f, hinj, hmem, hmono⟩
  refine h ⟨fun S => f (S.map (Fin.castSuccEmb)), ?_, fun S => hmem _, ?_⟩
  · intro S T hST
    exact Finset.map_injective _ (hinj hST)
  · intro S T hST
    exact hmono _ _ (Finset.map_subset_map.2 hST)

theorem La_mono_dim (n d : ℕ) : La n d ≤ La n (d + 1) :=
  La_le fun _ hF => le_La (bdFree_of_bdFree_succ hF)

/-! ## `d = 1` : Sperner's theorem -/

/-- `B 1`-freeness is exactly the antichain condition. -/
theorem bdFree_one_iff {F : Finset (Finset (Fin n))} :
    BdFree 1 F ↔ IsAntichain (· ⊆ ·) (F : Set (Finset (Fin n))) := by
  constructor
  · intro hfree A hA B hB hne hsub
    have hext : ∀ S T : Finset (Fin 1), ((0 : Fin 1) ∈ S ↔ (0 : Fin 1) ∈ T) → S = T := by
      intro S T hiff
      ext i
      have hi : i = 0 := Subsingleton.elim _ _
      subst hi
      exact hiff
    simp only [Finset.mem_coe] at hA hB
    refine hfree ⟨fun S => if (0 : Fin 1) ∈ S then B else A, ?_, ?_, ?_⟩
    · intro S T hST
      by_cases hS : (0 : Fin 1) ∈ S <;> by_cases hT : (0 : Fin 1) ∈ T <;>
        simp only [hS, hT, if_true, if_false] at hST
      · exact hext S T (by simp [hS, hT])
      · exact absurd hST.symm hne
      · exact absurd hST hne
      · exact hext S T (by simp [hS, hT])
    · intro S
      by_cases hS : (0 : Fin 1) ∈ S <;> simp [hS, hA, hB]
    · intro S T hST
      by_cases hS : (0 : Fin 1) ∈ S <;> by_cases hT : (0 : Fin 1) ∈ T <;>
        simp only [hS, hT, if_true, if_false]
      · exact subset_rfl
      · exact absurd (hST hS) hT
      · exact hsub
      · exact subset_rfl
  · rintro h ⟨f, hinj, hmem, hmono⟩
    have hne : f ∅ ≠ f {0} := fun hEq => by simpa using hinj hEq
    exact h (hmem ∅) (hmem {0}) hne (hmono _ _ (Finset.empty_subset _))

/-- Upper bound for `d = 1`. -/
theorem La_one_le (n : ℕ) : La n 1 ≤ central n :=
  La_le fun F hF => by
    have := (bdFree_one_iff.1 hF).sperner
    simpa [central, Fintype.card_fin] using this

/-! ## Lower bounds from consecutive levels -/

/-- The family of all subsets of `[n]` whose size lies in `[a, a+d)`. -/
def levels (n a d : ℕ) : Finset (Finset (Fin n)) :=
  (Finset.Ico a (a + d)).biUnion (fun i => Finset.powersetCard i Finset.univ)

lemma mem_levels {n a d : ℕ} {A : Finset (Fin n)} :
    A ∈ levels n a d ↔ a ≤ A.card ∧ A.card < a + d := by
  simp [levels, Finset.mem_biUnion, Finset.mem_powersetCard, Finset.subset_univ,
    Finset.mem_Ico, eq_comm]

lemma card_levels (n a d : ℕ) : (levels n a d).card = ∑ i ∈ Finset.Ico a (a + d), n.choose i := by
  rw [levels, Finset.card_biUnion]
  · exact Finset.sum_congr rfl (fun i _ => by simp [Finset.card_powersetCard])
  · intro i _ j _ hij
    simp only [Finset.disjoint_left, Finset.mem_powersetCard]
    rintro A ⟨-, rfl⟩ ⟨-, h⟩
    exact hij h

/-- Inside a `B d` copy the "prefix" sets give a strictly increasing chain of `d+1` sets. -/
lemma card_prefix_ge {d : ℕ}
    (f : Finset (Fin d) → Finset (Fin n)) (hinj : Function.Injective f)
    (hmono : ∀ S T : Finset (Fin d), S ⊆ T → f S ⊆ f T) (a : ℕ)
    (hcard : ∀ S, a ≤ (f S).card) :
    ∀ j ≤ d, a + j ≤ (f (Finset.univ.filter (fun x : Fin d => (x : ℕ) < j))).card := by
  intro j
  induction j with
  | zero => intro _; simpa using hcard _
  | succ j ih =>
    intro hj
    have hjd : j ≤ d := by omega
    have hstep := ih hjd
    set S := Finset.univ.filter (fun x : Fin d => (x : ℕ) < j) with hS
    set T := Finset.univ.filter (fun x : Fin d => (x : ℕ) < j + 1) with hT
    have hsub : S ⊆ T := by
      intro x hx
      simp only [hS, hT, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
      omega
    have hne : S ≠ T := by
      intro hEq
      have hjlt : j < d := by omega
      have : (⟨j, hjlt⟩ : Fin d) ∈ T := by simp [hT]
      rw [← hEq] at this
      simp only [hS, Finset.mem_filter, Finset.mem_univ, true_and] at this
      omega
    have hss : f S ⊂ f T :=
      Finset.ssubset_iff_subset_ne.2 ⟨hmono _ _ hsub, fun hEq => hne (hinj hEq)⟩
    have := Finset.card_lt_card hss
    omega

/-- `d` consecutive levels form a `B d`-free family. -/
theorem bdFree_levels (n a d : ℕ) : BdFree d (levels n a d) := by
  rintro ⟨f, hinj, hmem, hmono⟩
  have hcard : ∀ S, a ≤ (f S).card := fun S => (mem_levels.1 (hmem S)).1
  have hbig := card_prefix_ge f hinj hmono a hcard d le_rfl
  have hsmall := (mem_levels.1 (hmem (Finset.univ.filter (fun x : Fin d => (x : ℕ) < d)))).2
  omega

/-- **Lower bound.** `La(n, B_d)` is at least the sum of any `d` consecutive binomial
coefficients. -/
theorem La_ge_consecutive_levels (n a d : ℕ) :
    ∑ i ∈ Finset.Ico a (a + d), n.choose i ≤ La n d := by
  have := le_La (bdFree_levels n a d)
  rwa [card_levels] at this

/-- For `d = 1` the middle layer attains the Sperner bound. -/
theorem central_le_La_one (n : ℕ) : central n ≤ La n 1 := by
  have := La_ge_consecutive_levels n (n / 2) 1
  simpa [central, Finset.sum_Ico_succ_top] using this

/-- **Exact value for `d = 1`** : `La(n, B_1) = C(n, ⌊n/2⌋)`. -/
theorem La_one (n : ℕ) : La n 1 = central n :=
  le_antisymm (La_one_le n) (central_le_La_one n)

/-! ## The conjecture for `d = 3` in small dimension -/

lemma two_pow_le_four_central {n : ℕ} (hn : n ≤ 8) : 2 ^ n ≤ 4 * central n := by
  interval_cases n <;> simp [central] <;> norm_num [Nat.choose]

/-- **The conjectured `d = 3` bound holds for `n ≤ 8`** : `La(n, B_3) ≤ 4 * C(n, ⌊n/2⌋)`. -/
theorem La_three_le_four_of_le_eight {n : ℕ} (hn : n ≤ 8) : La n 3 ≤ 4 * central n :=
  le_trans (La_le_two_pow n 3) (two_pow_le_four_central hn)

/-- The chain bound in the case `d = 3` : `La(n, B_3) ≤ 7 * C(n, ⌊n/2⌋)`. -/
theorem La_three_le_seven (n : ℕ) : La n 3 ≤ 7 * central n := by
  simpa using La_le_chain_bound n 3

/-- The conjectured bound `La(n, B_d) ≤ (d+1) * C(n, ⌊n/2⌋)` holds unconditionally
whenever `n ≤ d`. -/
theorem La_le_succ_dim_of_n_le_dim {n d : ℕ} (h : n ≤ d) : La n d ≤ (d + 1) * central n :=
  le_trans (La_le_height_bound n d) (Nat.mul_le_mul_right _ (by omega))

/-! ## A doubling criterion : `B (d+1)` copies from two parallel `B d` copies -/

/-- Restriction of a subset of `Fin (d+1)` to its first `d` coordinates. -/
def restr {d : ℕ} (U : Finset (Fin (d + 1))) : Finset (Fin d) :=
  Finset.univ.filter (fun i : Fin d => i.castSucc ∈ U)

lemma restr_mono {d : ℕ} {U V : Finset (Fin (d + 1))} (h : U ⊆ V) : restr U ⊆ restr V := by
  intro i hi
  simp only [restr, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
  exact h hi

lemma restr_ext {d : ℕ} {U V : Finset (Fin (d + 1))} (hr : restr U = restr V)
    (hl : (Fin.last d ∈ U) ↔ (Fin.last d ∈ V)) : U = V := by
  ext i
  induction i using Fin.lastCases with
  | last => exact hl
  | cast j =>
    have h1 : j ∈ restr U ↔ j ∈ restr V := by rw [hr]
    simpa [restr] using h1

/-- **Doubling criterion.** Two containment-compatible, disjointly-valued copies of `B d`
inside `F` combine into a copy of `B (d+1)`. -/
theorem hasBdCopy_succ_of_stacked {d : ℕ} {F : Finset (Finset (Fin n))}
    (f h : Finset (Fin d) → Finset (Fin n))
    (hfinj : Function.Injective f) (hhinj : Function.Injective h)
    (hfF : ∀ S, f S ∈ F) (hhF : ∀ S, h S ∈ F)
    (hfmono : ∀ S T, S ⊆ T → f S ⊆ f T) (hhmono : ∀ S T, S ⊆ T → h S ⊆ h T)
    (hstack : ∀ S, f S ⊆ h S) (hne : ∀ S T, f S ≠ h T) :
    HasBdCopy (d + 1) F := by
  classical
  refine ⟨fun U => if Fin.last d ∈ U then h (restr U) else f (restr U), ?_, ?_, ?_⟩
  · intro U V hUV
    by_cases hU : Fin.last d ∈ U <;> by_cases hV : Fin.last d ∈ V <;>
      simp only [hU, hV, if_true, if_false] at hUV
    · exact restr_ext (hhinj hUV) (by simp [hU, hV])
    · exact absurd hUV.symm (hne _ _)
    · exact absurd hUV (hne _ _)
    · exact restr_ext (hfinj hUV) (by simp [hU, hV])
  · intro U
    by_cases hU : Fin.last d ∈ U <;> simp [hU, hfF, hhF]
  · intro U V hUV
    have hr : restr U ⊆ restr V := restr_mono hUV
    by_cases hU : Fin.last d ∈ U <;> by_cases hV : Fin.last d ∈ V <;>
      simp only [hU, hV, if_true, if_false]
    · exact hhmono _ _ hr
    · exact absurd (hUV hU) hV
    · exact (hfmono _ _ hr).trans (hstack _)
    · exact hfmono _ _ hr

/-- **Parallel-chain criterion.** Two chains of `2^d` sets, pointwise nested and disjoint as
families, already contain a copy of `B (d+1)`. This configuration is strictly weaker than a
single chain of `2^{d+1}` sets, so it forbids more than the chain bound uses. -/
theorem hasBdCopy_succ_of_parallel_chains {d : ℕ} {F : Finset (Finset (Fin n))}
    (x y : ℕ → Finset (Fin n))
    (hx : ∀ i j, i < j → j < 2 ^ d → x i ⊂ x j) (hy : ∀ i j, i < j → j < 2 ^ d → y i ⊂ y j)
    (hxF : ∀ i < 2 ^ d, x i ∈ F) (hyF : ∀ i < 2 ^ d, y i ∈ F)
    (hxy : ∀ i < 2 ^ d, x i ⊆ y i)
    (hne : ∀ i < 2 ^ d, ∀ j < 2 ^ d, x i ≠ y j) :
    HasBdCopy (d + 1) F := by
  obtain ⟨hxinj, hxmono⟩ := chain_comp_rank (n := n) (d := d) (g := x) hx
  obtain ⟨hyinj, hymono⟩ := chain_comp_rank (n := n) (d := d) (g := y) hy
  exact hasBdCopy_succ_of_stacked (fun S => x (rank d S)) (fun S => y (rank d S))
    hxinj hyinj (fun S => hxF _ (rank_lt d S)) (fun S => hyF _ (rank_lt d S))
    hxmono hymono (fun S => hxy _ (rank_lt d S))
    (fun S T => hne _ (rank_lt d S) _ (rank_lt d T))


end Catalog.Algebra.BooleanLatticeChainBound