import Mathlib

/-!
# Bruhat length and the chain-rank bound for Schubert posets

The conjecture in this mission bounds a (multigraded) regularity invariant of a Schubert
variety `S_σ` by *the length of the longest chain of Bruhat-ordered Schubert varieties* from
the bottom up to `σ`.  The relevant order-theoretic fact — and the reason "longest chain"
is a well-defined finite quantity — is that the Bruhat order on the symmetric group is
**graded by Coxeter length** `ℓ(σ) = #{inversions of σ}`: every saturated chain from the
identity to `σ` has exactly `ℓ(σ)` steps, and `ℓ` is bounded by `C(n,2)`.

Here we formalize this rank structure directly.  We define the inversion length `len σ`,
bound it by `n.choose 2`, compute it on the identity, and prove the central *chain-rank
bound*: any chain of permutations starting at the identity whose length strictly increases at
each step has at most `len (top)` steps — hence at most `n.choose 2` steps overall.  This is
exactly the finiteness/upper-bound mechanism the regularity conjecture relies on.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Length of the longest chain to σ" is governed by the inversion
  statistic; chains in a length-graded poset cannot be longer than the rank of their top.
Experiment (Experimenter): Defined `len` via the inversion finset and attempted the bound
  `len ≤ C(n,2)`, the value at `1`, and the chain-rank inequality.
Analysis (Analyst): The chain bound reduces to: a strictly increasing ℕ-sequence starting at
  `len 1 = 0` reaches at least its index, so a `(k+1)`-term chain forces `len top ≥ k`.  This
  is the abstract skeleton of "regularity ≤ longest chain length".
Critique (Critic): We do *not* assume the chain steps are Bruhat covers (which would need the
  full Coxeter machinery); we only assume strict length increase, which every strictly-Bruhat-
  increasing chain satisfies.  Thus the bound is honest and slightly more general than needed.
Synthesis (PI): `len_le_choose_two`, `len_one`, and `chain_steps_le_len`/`chain_steps_le_choose`
  package the rank bound that underwrites the conjecture's finiteness.
-- !-- Lab Notes -- !--
-/

namespace SchubertLength

open Equiv

/-- The set of inversions of `σ`: pairs of positions `i < j` whose values are out of order. -/
def invSet {n : ℕ} (σ : Equiv.Perm (Fin n)) : Finset (Fin n × Fin n) :=
  Finset.univ.filter (fun p => p.1 < p.2 ∧ σ p.2 < σ p.1)

/-- The Coxeter/Bruhat length of `σ`: the number of inversions. -/
def len {n : ℕ} (σ : Equiv.Perm (Fin n)) : ℕ := (invSet σ).card

/-- The set of all "upper" position pairs `i < j`. -/
def upperPairs (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.univ.filter (fun p => p.1 < p.2)

theorem invSet_subset_upperPairs {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    invSet σ ⊆ upperPairs n := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Finset.mem_filter.mp hx |>.2.1 ⟩

/-
The number of `i < j` position pairs is `n.choose 2`.
-/
theorem upperPairs_card (n : ℕ) : (upperPairs n).card = n.choose 2 := by
  simp [upperPairs];
  rw [ Finset.card_filter ];
  erw [ Finset.sum_product ] ; simp +decide [ Nat.choose_two_right ];
  convert Finset.sum_range_id n using 1;
  simp +decide [ Finset.filter_lt_eq_Ioi ];
  rw [ ← Finset.sum_range_reflect, Finset.sum_range ]

/-
Length is bounded by `n.choose 2` (the length of the longest element `w₀`).
-/
theorem len_le_choose_two {n : ℕ} (σ : Equiv.Perm (Fin n)) : len σ ≤ n.choose 2 := by
  exact le_trans ( Finset.card_le_card ( invSet_subset_upperPairs σ ) ) ( by rw [ upperPairs_card ] )

/-
The identity has length `0` (it sits at the bottom of the Bruhat order).
-/
theorem len_one {n : ℕ} : len (1 : Equiv.Perm (Fin n)) = 0 := by
  simp +decide [ len, invSet ];
  exact fun a b h => le_of_lt h

/-- A *length chain* of `k` steps: permutations `c 0, …, c k` starting at the identity, with
the Bruhat length strictly increasing at every step.  Every strictly-Bruhat-increasing chain
is of this form. -/
structure LengthChain (n k : ℕ) where
  steps : Fin (k + 1) → Equiv.Perm (Fin n)
  start : steps 0 = 1
  mono : ∀ i : Fin k, len (steps i.castSucc) < len (steps i.succ)

/-
Along a length chain, the length is at least the step index.
-/
theorem LengthChain.len_ge_index {n k : ℕ} (c : LengthChain n k) (i : Fin (k + 1)) :
    (i : ℕ) ≤ len (c.steps i) := by
  induction' i using Fin.inductionOn with i IH;
  · exact Nat.zero_le _;
  · exact Nat.succ_le_of_lt ( lt_of_le_of_lt IH ( c.mono i ) )

/-
**Chain-rank bound.** The number of steps of any length chain ending at `w` is at most
`len w` — the combinatorial core of "regularity ≤ length of the longest chain".
-/
theorem chain_steps_le_len {n k : ℕ} (c : LengthChain n k) :
    k ≤ len (c.steps (Fin.last k)) := by
  convert c.len_ge_index ( Fin.last k )

/-
Consequently, no chain of Schubert length can be longer than `n.choose 2`.
-/
theorem chain_steps_le_choose {n k : ℕ} (c : LengthChain n k) : k ≤ n.choose 2 := by
  exact le_trans ( chain_steps_le_len c ) ( len_le_choose_two _ )

end SchubertLength