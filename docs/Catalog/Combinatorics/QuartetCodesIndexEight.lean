import Mathlib
import Combinatorics.QuartetCodes
import Combinatorics.QuartetCodesRate

/-!
# The caterpillar quartet code has at most `n!/8` codewords

`Combinatorics.QuartetCodesRate` proves the packing bound `2 · #code ≤ n!` from the reversal
symmetry of a caterpillar.  Here the bound is improved to the conjecturally exact index,
`8 · #code ≤ n!`, by adding the two *cherry* symmetries: exchanging the two leaves at either end of
the caterpillar does not change any quartet.

Because a degenerate quadruple (one with a repeated leaf) is *not* invariant under the cherry
symmetry, the signature used here is the honest one: it is the quartet letter on quadruples of
pairwise distinct leaves and a fixed dummy value elsewhere (`sigD`).

The three generators are reversal `r`, the exchange `a` of the two lowest positions, and
`b = r * a * r`, the exchange of the two highest positions.  Their eight products are pairwise
distinct as soon as `n ≥ 4`, which is verified by evaluating each of them at the first and the last
leaf position.

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
The quartet-signature fibres of `Sym(n)` have size exactly `8`; the computation in
`ComputationalEvidence.md` confirms this for `n = 4, 5, 6, 7`, and `card_image_sig5 = 15 = 5!/8`
confirms it formally at `n = 5`.  The `≤ n!/8` half should be provable for all `n` by exhibiting
the eight symmetries.

## Experiment (Experimenter)
The delicate point is the cherry symmetry: swapping the two *values* `0` and `1` flips the
comparison between the leaves carrying them, so the order-congruence lemma `code3_congr` does not
apply.  Instead the invariance is proved by direct case analysis (`code3_sw01`, ~1000 branches
discharged by `omega`), which is valid precisely because the two swapped values are the two global
minima and therefore stay the "low pair" of every quadruple containing both.

## Analysis (Analyst)
The three symmetries are the automorphisms of an unrooted caterpillar, and the argument shows they
act freely on `Sym(n)`, giving the packing bound `8 · #code ≤ n!`.  The converse inequality —
identifiability of the caterpillar from its quartets up to these eight relabellings — is the open
half recorded in `FUTURE_DIRECTIONS.md`.

## Critique (Critic)
Invariance is stated for the signature on *all* quadruples with a dummy value on degenerate ones, so
the theorem is about a genuine finite code, and no quadruple is quietly excluded.  The eight
symmetries are proved pairwise distinct for every `n ≥ 4`, not just for small `n`.
-/

open Finset

namespace QuartetCodes

section IndexEight

variable {n : ℕ}

/-- Exchange of the two smallest values. -/
def sw01 (x : ℕ) : ℕ := if x = 0 then 1 else if x = 1 then 0 else x

set_option maxHeartbeats 2000000 in
/-- Exchanging the two smallest positions does not change the quartet type of four distinct
leaves. -/
lemma code3_sw01 {p q r s : ℕ} (hpq : p ≠ q) (hpr : p ≠ r) (hps : p ≠ s)
    (hqr : q ≠ r) (hqs : q ≠ s) (hrs : r ≠ s) :
    code3 (sw01 p) (sw01 q) (sw01 r) (sw01 s) = code3 p q r s := by
  unfold code3 sw01
  split_ifs <;> first | rfl | (exfalso; omega)

/-- Whether the four entries of a quadruple are pairwise distinct. -/
def QuadDistinct (q : Fin n × Fin n × Fin n × Fin n) : Prop :=
  q.1 ≠ q.2.1 ∧ q.1 ≠ q.2.2.1 ∧ q.1 ≠ q.2.2.2 ∧ q.2.1 ≠ q.2.2.1 ∧ q.2.1 ≠ q.2.2.2 ∧
    q.2.2.1 ≠ q.2.2.2

instance : DecidablePred (QuadDistinct (n := n)) := fun _ => by unfold QuadDistinct; infer_instance

/-- The quartet signature on nondegenerate quadruples (dummy value `0` on degenerate ones). -/
def sigD (π : Equiv.Perm (Fin n)) : Fin n × Fin n × Fin n × Fin n → Fin 3 :=
  fun q => if QuadDistinct q then qcode π q.1 q.2.1 q.2.2.1 q.2.2.2 else 0

/-- The exchange of the two lowest positions. -/
def lowSwap (hn : 4 ≤ n) : Equiv.Perm (Fin n) :=
  Equiv.swap ⟨0, by omega⟩ ⟨1, by omega⟩

lemma lowSwap_val (hn : 4 ≤ n) (v : Fin n) : ((lowSwap hn) v).val = sw01 v.val := by
  unfold lowSwap sw01
  by_cases h0 : v = (⟨0, by omega⟩ : Fin n)
  · subst h0; rw [Equiv.swap_apply_left]; simp
  · by_cases h1 : v = (⟨1, by omega⟩ : Fin n)
    · subst h1; rw [Equiv.swap_apply_right]; simp
    · rw [Equiv.swap_apply_of_ne_of_ne h0 h1]
      have hv0 : v.val ≠ 0 := fun h => h0 (Fin.ext h)
      have hv1 : v.val ≠ 1 := fun h => h1 (Fin.ext h)
      simp [hv0, hv1]

/-- **Cherry symmetry.**  Exchanging the two lowest positions preserves the whole signature. -/
theorem sigD_lowSwap (hn : 4 ≤ n) (π : Equiv.Perm (Fin n)) :
    sigD ((lowSwap hn) * π) = sigD π := by
  funext q
  obtain ⟨a, b, c, d⟩ := q
  unfold sigD
  by_cases hq : QuadDistinct ((a, b, c, d) : Fin n × Fin n × Fin n × Fin n)
  · simp only [hq, if_true]
    obtain ⟨hab, hac, had, hbc, hbd, hcd⟩ := hq
    have hval : ∀ x : Fin n, (((lowSwap hn) * π : Equiv.Perm (Fin n)) x).val = sw01 (π x).val := by
      intro x
      rw [Equiv.Perm.mul_apply, lowSwap_val]
    show code3 _ _ _ _ = code3 _ _ _ _
    rw [hval a, hval b, hval c, hval d]
    exact code3_sw01 (perm_val_ne hab) (perm_val_ne hac) (perm_val_ne had) (perm_val_ne hbc)
      (perm_val_ne hbd) (perm_val_ne hcd)
  · simp [hq]

/-- **Reversal symmetry** for the nondegenerate signature. -/
theorem sigD_rev (π : Equiv.Perm (Fin n)) :
    sigD ((Fin.revPerm : Equiv.Perm (Fin n)) * π) = sigD π := by
  funext q
  obtain ⟨a, b, c, d⟩ := q
  unfold sigD
  by_cases hq : QuadDistinct ((a, b, c, d) : Fin n × Fin n × Fin n × Fin n)
  · simp only [hq, if_true]
    have hval : ∀ x : Fin n,
        ((Fin.revPerm * π : Equiv.Perm (Fin n)) x).val = n - 1 - (π x).val := by
      intro x
      simp [Equiv.Perm.mul_apply, Fin.val_rev]
      omega
    have hle : ∀ x : Fin n, (π x).val ≤ n - 1 := fun x => Nat.le_pred_of_lt (π x).isLt
    show code3 _ _ _ _ = code3 _ _ _ _
    rw [hval a, hval b, hval c, hval d]
    exact code3_rev (hle a) (hle b) (hle c) (hle d)
  · simp [hq]

/-- The eight caterpillar symmetries: products of the reversal `r` and the two cherry
exchanges `a` and `b = r * a * r`. -/
def symm8 (hn : 4 ≤ n) : Fin 8 → Equiv.Perm (Fin n) :=
  let a := lowSwap hn
  let r := (Fin.revPerm : Equiv.Perm (Fin n))
  let b := r * a * r
  ![1, a, b, a * b, r, r * a, r * b, r * a * b]

/-- Every one of the eight symmetries preserves the signature. -/
theorem sigD_symm8 (hn : 4 ≤ n) (i : Fin 8) (π : Equiv.Perm (Fin n)) :
    sigD ((symm8 hn i) * π) = sigD π := by
  have ha : ∀ σ : Equiv.Perm (Fin n), sigD ((lowSwap hn) * σ) = sigD σ := sigD_lowSwap hn
  have hr : ∀ σ : Equiv.Perm (Fin n),
      sigD ((Fin.revPerm : Equiv.Perm (Fin n)) * σ) = sigD σ := sigD_rev
  fin_cases i <;> simp only [symm8] <;> simp [ha, hr, mul_assoc]

lemma revPerm_apply_val (v : Fin n) :
    ((Fin.revPerm : Equiv.Perm (Fin n)) v).val = n - 1 - v.val := by
  simp [Fin.val_rev]
  omega

/-- Evaluation of a permutation at the first and the last position. -/
def evalEnds (hn : 4 ≤ n) (g : Equiv.Perm (Fin n)) : ℕ × ℕ :=
  ((g ⟨0, by omega⟩).val, (g ⟨n - 1, by omega⟩).val)

lemma lowSwap_apply_zero (hn : 4 ≤ n) :
    (lowSwap hn) ⟨0, by omega⟩ = ⟨1, by omega⟩ := Equiv.swap_apply_left _ _

lemma lowSwap_apply_one (hn : 4 ≤ n) :
    (lowSwap hn) ⟨1, by omega⟩ = ⟨0, by omega⟩ := Equiv.swap_apply_right _ _

lemma lowSwap_apply_of_val_ne (hn : 4 ≤ n) (v : Fin n) (h0 : v.val ≠ 0) (h1 : v.val ≠ 1) :
    (lowSwap hn) v = v :=
  Equiv.swap_apply_of_ne_of_ne (fun h => h0 (by rw [h])) (fun h => h1 (by rw [h]))

lemma revPerm_apply_mk (k : ℕ) (hk : k < n) :
    (Fin.revPerm : Equiv.Perm (Fin n)) ⟨k, hk⟩ = ⟨n - 1 - k, by omega⟩ := by
  apply Fin.ext
  rw [revPerm_apply_val]

/-- The eight symmetries evaluated at the first and last position. -/
lemma evalEnds_symm8 (hn : 4 ≤ n) (i : Fin 8) :
    evalEnds hn (symm8 hn i) =
      ![(0, n - 1), (1, n - 1), (0, n - 2), (1, n - 2), (n - 1, 0), (n - 2, 0), (n - 1, 1),
        (n - 2, 1)] i := by
  have hrev : ∀ k (hk : k < n),
      (Fin.revPerm : Equiv.Perm (Fin n)) ⟨k, hk⟩ = ⟨n - 1 - k, by omega⟩ := revPerm_apply_mk
  have hlast : (lowSwap hn) ⟨n - 1, by omega⟩ = ⟨n - 1, by omega⟩ :=
    lowSwap_apply_of_val_ne hn _ (by simp; omega) (by simp; omega)
  have hn2 : (lowSwap hn) ⟨n - 2, by omega⟩ = ⟨n - 2, by omega⟩ :=
    lowSwap_apply_of_val_ne hn _ (by simp; omega) (by simp; omega)
  fin_cases i <;> simp only [symm8, evalEnds] <;>
    simp [hrev, hlast, hn2, lowSwap_apply_zero hn,
      show n - 1 - 1 = n - 2 from by omega] <;> omega

set_option maxRecDepth 100000 in
lemma symm8_injective (hn : 4 ≤ n) : Function.Injective (symm8 hn) := by
  intro i j hij
  have h := congrArg (evalEnds hn) hij
  rw [evalEnds_symm8 hn i, evalEnds_symm8 hn j] at h
  fin_cases i <;> fin_cases j <;>
    first
      | rfl
      | (exfalso; simp [Prod.ext_iff] at h; try omega)

/-- **Packing bound with the exact conjectural index.**  At most `n!/8` leaf orders carry distinct
quartet signatures. -/
theorem eight_mul_card_image_sigD_le (hn : 4 ≤ n) :
    8 * ((Finset.univ : Finset (Equiv.Perm (Fin n))).image sigD).card ≤ Nat.factorial n := by
  classical
  have hfib := Finset.card_eq_sum_card_fiberwise
    (f := (sigD : Equiv.Perm (Fin n) → _))
    (s := (Finset.univ : Finset (Equiv.Perm (Fin n))))
    (t := (Finset.univ : Finset (Equiv.Perm (Fin n))).image sigD)
    (fun x _ => Finset.mem_coe.2 (Finset.mem_image_of_mem _ (Finset.mem_univ x)))
  have hcards : ∀ w ∈ (Finset.univ : Finset (Equiv.Perm (Fin n))).image sigD,
      8 ≤ {σ ∈ (Finset.univ : Finset (Equiv.Perm (Fin n))) | sigD σ = w}.card := by
    intro w hw
    obtain ⟨π, -, hπ⟩ := Finset.mem_image.1 hw
    have hinj : Function.Injective (fun i : Fin 8 => (symm8 hn i) * π) := by
      intro i j hij
      exact symm8_injective hn (mul_right_cancel hij)
    have hsub : (Finset.univ : Finset (Fin 8)).image (fun i => (symm8 hn i) * π)
        ⊆ {σ ∈ (Finset.univ : Finset (Equiv.Perm (Fin n))) | sigD σ = w} := by
      intro σ hσ
      obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hσ
      exact Finset.mem_filter.2 ⟨Finset.mem_univ _, by rw [sigD_symm8 hn i π]; exact hπ⟩
    calc (8 : ℕ) = ((Finset.univ : Finset (Fin 8)).image (fun i => (symm8 hn i) * π)).card := by
          rw [Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_fin]
      _ ≤ _ := Finset.card_le_card hsub
  have hsum : 8 * ((Finset.univ : Finset (Equiv.Perm (Fin n))).image sigD).card
      ≤ ∑ w ∈ (Finset.univ : Finset (Equiv.Perm (Fin n))).image sigD,
          {σ ∈ (Finset.univ : Finset (Equiv.Perm (Fin n))) | sigD σ = w}.card := by
    calc 8 * ((Finset.univ : Finset (Equiv.Perm (Fin n))).image sigD).card
        = ∑ _w ∈ (Finset.univ : Finset (Equiv.Perm (Fin n))).image sigD, 8 := by
          rw [Finset.sum_const, smul_eq_mul, mul_comm]
      _ ≤ _ := Finset.sum_le_sum hcards
  have hperm : (Finset.univ : Finset (Equiv.Perm (Fin n))).card = Nat.factorial n := by
    simp [Finset.card_univ, Fintype.card_perm]
  omega

end IndexEight

end QuartetCodes