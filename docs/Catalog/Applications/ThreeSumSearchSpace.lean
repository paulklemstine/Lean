/-
# Search space of the 3SUM-mod-`p` factoring test

Second cycle of the 3SUM / birthday-bound investigation.  The companion files

* `Catalog/Applications/ThreeSumFactoring.lean` (a mod-`p` triple reveals `p`),
* `Catalog/Applications/BirthdayBoundHierarchy.lean` (collision cost thresholds)

treat *when a witness works* and *how many selections must be inspected*.  Here
we treat the two remaining structural questions.

**1. Entry magnitude (an existence barrier, not a pigeonhole barrier).**
A triple with positive entries bounded by `K` has sum at most `3K`.  Hence:

* if `3K < p` **no** triple in the box is a witness (`no_reveal_of_entries_small`),
* if `p ≤ 3K` a witness always exists (`exists_zeroSum_triple_of_le`),

so the box side must satisfy `K ≥ p/3` (`zeroSum_witness_iff`), which for a
balanced semiprime is again of order `√N` (`entry_size_barrier`).  This is a
*different* mechanism from the birthday bound: it constrains the magnitude of
the entries rather than the number of selections, yet lands on the same `√N`.

**2. Exact density of the solution set.**  The `r`-SUM equation `∑ xᵢ = 0` in
`ZMod p` has exactly `p ^ r` solutions among `p ^ (r+1)` tuples
(`card_zeroSum_tuples`): density exactly `1/p` at *every* level of the
hierarchy.  This is the rigorous version of the heuristic "`k ^ r` triples, one
hit per `p` of them, so `k ≈ p ^ (1/r)`" appearing in the hierarchy table, and
it shows the hierarchy's level parameter changes only the arity, never the
density.
-/
import Mathlib
import Applications.ThreeSumFactoring

namespace ThreeSumSearchSpace

open Finset

/-! ## 1. The entry-magnitude barrier -/

/-- Below the threshold no witness exists: if the positive entries are bounded by
`K` and `3K < p`, no triple sum is divisible by `p`. -/
theorem no_reveal_of_entries_small {p K a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (haK : a ≤ K) (hbK : b ≤ K) (hcK : c ≤ K) (h : 3 * K < p) : ¬ p ∣ a + b + c := by
  intro hd
  have hle : p ≤ a + b + c := Nat.le_of_dvd (by omega) hd
  omega

/-- Above the threshold a witness always exists: if `3 ≤ p ≤ 3K` there is a
triple of positive entries bounded by `K` whose sum is exactly `p`. -/
theorem exists_zeroSum_triple_of_le {p K : ℕ} (h3 : 3 ≤ p) (hK : p ≤ 3 * K) :
    ∃ a b c : ℕ, 0 < a ∧ a ≤ K ∧ 0 < b ∧ b ≤ K ∧ 0 < c ∧ c ≤ K ∧ p ∣ a + b + c := by
  refine ⟨min K (p - 2), min K (p - min K (p - 2) - 1),
    p - min K (p - 2) - min K (p - min K (p - 2) - 1), by omega, by omega, by omega,
    by omega, by omega, by omega, ?_⟩
  have : min K (p - 2) + min K (p - min K (p - 2) - 1) +
      (p - min K (p - 2) - min K (p - min K (p - 2) - 1)) = p := by omega
  rw [this]

/-- **Witness existence is exactly the condition `p ≤ 3K`.** -/
theorem zeroSum_witness_iff {p K : ℕ} (h3 : 3 ≤ p) :
    (∃ a b c : ℕ, 0 < a ∧ a ≤ K ∧ 0 < b ∧ b ≤ K ∧ 0 < c ∧ c ≤ K ∧ p ∣ a + b + c)
      ↔ p ≤ 3 * K := by
  refine ⟨fun ⟨a, b, c, ha, haK, hb, hbK, hc, hcK, hd⟩ => ?_,
    fun h => exists_zeroSum_triple_of_le h3 h⟩
  by_contra hlt
  push_neg at hlt
  exact no_reveal_of_entries_small ha hb hc haK hbK hcK hlt hd

/-- **The entry-magnitude barrier is `√N` again.**  If a balanced semiprime
`N = p * q` (with `q ≤ 2p`) admits a 3SUM witness inside the box `[1,K]³`, then
`N ≤ 18 * K ^ 2`, i.e. `K ≥ √(N/18)`. -/
theorem entry_size_barrier {N p q K : ℕ} (hN : N = p * q) (h3 : 3 ≤ p) (hbal : q ≤ 2 * p)
    (hw : ∃ a b c : ℕ, 0 < a ∧ a ≤ K ∧ 0 < b ∧ b ≤ K ∧ 0 < c ∧ c ≤ K ∧ p ∣ a + b + c) :
    N ≤ 18 * K ^ 2 := by
  have hp3K : p ≤ 3 * K := (zeroSum_witness_iff h3).1 hw
  have hNle : N ≤ 2 * p * p := by
    rw [hN]
    calc p * q ≤ p * (2 * p) := Nat.mul_le_mul_left p hbal
      _ = 2 * p * p := by ring
  nlinarith [hNle, hp3K]

/-- Conversely, a search box too small for the prime is provably useless: no
triple inside it can reveal any factor of `N = p * q`. -/
theorem box_too_small_useless {p q K a b c : ℕ} (hp : p.Prime) (hq : q.Prime)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (haK : a ≤ K) (hbK : b ≤ K)
    (hcK : c ≤ K) (h : 3 * K < p) (hKq : 3 * K < q) :
    Nat.gcd (a + b + c) (p * q) = 1 := by
  have hnp : ¬ p ∣ a + b + c := no_reveal_of_entries_small ha hb hc haK hbK hcK h
  have hnq : ¬ q ∣ a + b + c := no_reveal_of_entries_small ha hb hc haK hbK hcK hKq
  have hcop : Nat.Coprime (a + b + c) p := ((Nat.Prime.coprime_iff_not_dvd hp).2 hnp).symm
  have hcoq : Nat.Coprime (a + b + c) q := ((Nat.Prime.coprime_iff_not_dvd hq).2 hnq).symm
  exact Nat.Coprime.mul_right hcop hcoq

/-! ## 2. Exact density of the `r`-SUM solution set -/

/-- **Zero-sum tuples have density exactly `1/p`.**  For every level `r`, the
number of `(r+1)`-tuples in `ZMod p` summing to zero is `p ^ r`. -/
theorem card_zeroSum_tuples (p r : ℕ) [NeZero p] :
    Fintype.card {x : Fin (r + 1) → ZMod p // ∑ i, x i = 0} = p ^ r := by
  have e : {x : Fin (r + 1) → ZMod p // ∑ i, x i = 0} ≃ (Fin r → ZMod p) :=
    { toFun := fun x => fun i => x.1 i.castSucc
      invFun := fun y => ⟨Fin.snoc y (-(∑ i, y i)), by
        rw [Fin.sum_univ_castSucc]
        simp⟩
      left_inv := by
        rintro ⟨x, hx⟩
        apply Subtype.ext
        rw [Fin.sum_univ_castSucc] at hx
        have hlast : x (Fin.last r) = -(∑ i : Fin r, x i.castSucc) := by
          linear_combination hx
        funext i
        refine Fin.lastCases ?_ ?_ i
        · simp [hlast]
        · intro j; simp
      right_inv := by
        intro y
        funext i
        simp }
  rw [Fintype.card_congr e, Fintype.card_fun, ZMod.card, Fintype.card_fin]

/-- The 3SUM instance of the density theorem: exactly `p ^ 2` of the `p ^ 3`
residue triples satisfy `a + b + c ≡ 0`. -/
theorem card_zeroSum_triples (p : ℕ) [NeZero p] :
    Fintype.card {x : Fin 3 → ZMod p // ∑ i, x i = 0} = p ^ 2 :=
  card_zeroSum_tuples p 2

/-- The sumset (birthday) instance: exactly `p` of the `p ^ 2` residue pairs
satisfy `a + b ≡ 0`. -/
theorem card_zeroSum_pairs (p : ℕ) [NeZero p] :
    Fintype.card {x : Fin 2 → ZMod p // ∑ i, x i = 0} = p :=
  by simpa using card_zeroSum_tuples p 1

/-- **Density form.**  The solution set of the level-`r` equation occupies
exactly a `1/p` fraction of the whole tuple space. -/
theorem zeroSum_density (p r : ℕ) [NeZero p] :
    p * Fintype.card {x : Fin (r + 1) → ZMod p // ∑ i, x i = 0}
      = Fintype.card (Fin (r + 1) → ZMod p) := by
  rw [card_zeroSum_tuples, Fintype.card_fun, ZMod.card, Fintype.card_fin, pow_succ]
  ring

end ThreeSumSearchSpace