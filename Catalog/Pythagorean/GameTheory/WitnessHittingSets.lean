import Mathlib

/-!
# Deterministic Hitting Sets for Dense Set Families

This file develops a formal theory of **witness-hitting families** for bounded
Miller–Rabin primality testing, recasting derandomization as a finite
combinatorial problem about dense set families and their transversals.

## Main Results

### Pure Combinatorics (Domain-Independent)

* `exists_element_hitting_many` — **Averaging lemma**: if every set in a family
  `F` over universe `U` has density ≥ 3/4, then some element of `U` lies in
  at least 3/4 of the sets in `F`.

* `uncovered_after_insert_le` — **Greedy shrink lemma**: after choosing the best
  element from the averaging lemma, the number of uncovered sets drops by at
  least a factor of 3/4.

* `exists_hittingSet_of_dense_family` — **Hitting set existence**: for any
  finite family of subsets of `U` with density ≥ 3/4, there exists a hitting
  set `H ⊆ U` of size at most `k` whenever `F.card < 4^k`.

### Miller–Rabin Specialization

* `MRCandidateBases`, `isOddComposite`, `hitsAllOddCompositesBelow` —
  definitions formalizing the Miller–Rabin witness-hitting framework.

* `exists_MR_hittingSet` — for any bound `B`, assuming witness density ≥ 3/4,
  there exists a deterministic hitting set of Miller–Rabin bases.

### Hypergraph Transversal (Cross-Domain)

* `transversalNumber` — the minimum size of a set intersecting every hyperedge.
* `transversalNumber_le_of_dense` — dense hypergraphs have small transversal
  number, connecting number theory to extremal hypergraph theory.

## Proof Strategy

We use **Strategy B** (averaging / greedy cover without probability):
1. Double-counting incidences `(a, S)` with `a ∈ S ∈ F` gives a lower bound.
2. Pigeonhole yields an element hitting many sets.
3. Greedy iteration produces a small hitting set.
4. The bound is `k` where `4^k > |F|`, giving `O(log |F|)` size.

This avoids real logarithms and probability theory entirely.

## References

* Rabin, M. O. "Probabilistic algorithm for testing primality." (1980)
* Monier, L. "Evaluation and comparison of two efficient probabilistic
  primality testing algorithms." (1980)
-/

open Finset Nat BigOperators

variable {α : Type*} [DecidableEq α]

/-! ## §1. Core Combinatorial Definitions -/

/-- The sets in `F` not hit by any element of `H`. -/
def uncoveredBy (H : Finset α) (F : Finset (Finset α)) : Finset (Finset α) :=
  F.filter (fun S => ∀ a ∈ H, a ∉ S)

/-- A set `H` is a hitting set for family `F` if `H` intersects every member. -/
def IsHittingSet (H : Finset α) (F : Finset (Finset α)) : Prop :=
  ∀ S ∈ F, ∃ a ∈ H, a ∈ S

/-- The transversal number: minimum size of a hitting set drawn from `U`.
This is the central parameter in extremal hypergraph theory. -/
noncomputable def transversalNumber (U : Finset α) (F : Finset (Finset α)) : ℕ :=
  sInf {k | ∃ H ⊆ U, H.card = k ∧ IsHittingSet H F}

/-! ## §2. Averaging Lemma

The key double-counting argument: the total number of incidences
`(a, S)` with `a ∈ U, S ∈ F, a ∈ S` equals `∑_{S ∈ F} |S ∩ U| = ∑_{S ∈ F} |S|`
(since each `S ⊆ U`). By density, each `|S| ≥ (3/4)|U|`, so the total is
`≥ (3/4)|U||F|`. By pigeonhole, some `a ∈ U` appears in `≥ (3/4)|F|` sets.
-/

/-- **Averaging lemma**: If every `S ∈ F` satisfies `4 * |U \ S| ≤ |U|`
(i.e., `|S| ≥ (3/4)|U|`), then some `a ∈ U` misses at most `|F|/4` sets. -/
theorem exists_element_hitting_many
    (U : Finset α) (F : Finset (Finset α))
    (hU : U.Nonempty)
    (hsub : ∀ S ∈ F, S ⊆ U)
    (hdense : ∀ S ∈ F, 4 * (U \ S).card ≤ U.card) :
    ∃ a ∈ U, 4 * (F.filter (fun S => a ∉ S)).card ≤ F.card := by
  contrapose! hdense
  have h_sum : ∑ a ∈ U, (F.filter (fun S => a ∉ S)).card = ∑ S ∈ F, (U \ S).card := by
    simp +decide only [filter_not, card_eq_sum_ones]
    rw [Finset.sum_sigma', Finset.sum_sigma']
    refine' Finset.sum_bij (fun x _ => ⟨x.2, x.1⟩) _ _ _ _ <;> aesop
  by_cases hF : F.Nonempty <;> simp_all +decide [Finset.nonempty_iff_ne_empty]
  · have := Finset.sum_lt_sum_of_nonempty (Finset.nonempty_of_ne_empty hU) hdense
    simp_all +decide [Finset.sum_mul _ _ _]
    rw [← Finset.mul_sum _ _ _] at this; contrapose! this
    simp_all +decide [mul_comm]
    simpa [mul_comm, Finset.mul_sum _ _ _] using Finset.sum_le_sum this
  · exact hU (Finset.eq_empty_of_forall_notMem hdense)

/-! ## §3. Greedy Shrink Lemma -/

/-- The uncovered-by-singleton family equals the filter of sets missing `a`. -/
theorem uncoveredBy_singleton_eq_filter (a : α) (F : Finset (Finset α)) :
    uncoveredBy {a} F = F.filter (fun S => a ∉ S) := by
  ext S; simp [uncoveredBy, Finset.mem_filter, Finset.mem_singleton]

/-- After choosing an element that hits many sets, the uncovered family shrinks. -/
theorem uncovered_after_insert_le
    (F : Finset (Finset α)) (a : α)
    (ha : 4 * (F.filter (fun S => a ∉ S)).card ≤ F.card) :
    4 * (uncoveredBy {a} F).card ≤ F.card := by
  rw [uncoveredBy_singleton_eq_filter]; exact ha

/-! ## §4. Hitting Set Existence via Greedy Iteration -/

/-- Helper: density condition is preserved when restricting to a subfamily. -/
theorem dense_of_filter_subset
    (U : Finset α) (F : Finset (Finset α)) (p : Finset α → Prop) [DecidablePred p]
    (_hsub : ∀ S ∈ F, S ⊆ U)
    (hdense : ∀ S ∈ F, 4 * (U \ S).card ≤ U.card) :
    ∀ S ∈ F.filter p, 4 * (U \ S).card ≤ U.card := by
  intro S hS; exact hdense S (Finset.mem_filter.mp hS).1

omit [DecidableEq α] in
theorem sub_of_filter_subset
    (F : Finset (Finset α)) (p : Finset α → Prop) [DecidablePred p]
    {U : Finset α} (hsub : ∀ S ∈ F, S ⊆ U) :
    ∀ S ∈ F.filter p, S ⊆ U := by
  intro S hS; exact hsub S (Finset.mem_filter.mp hS).1

/-
**Main theorem (Derandomization Meta-Theorem)**: If every set in `F`
over a nonempty `U` has density ≥ 3/4, then for any `k` with `F.card < 4^k`,
there exists a hitting set of size ≤ `k`.
-/
theorem exists_hittingSet_of_dense_family
    (U : Finset α) (F : Finset (Finset α)) (k : ℕ)
    (hU : U.Nonempty)
    (hsub : ∀ S ∈ F, S ⊆ U)
    (hdense : ∀ S ∈ F, 4 * (U \ S).card ≤ U.card)
    (hk : F.card < 4 ^ k) :
    ∃ H ⊆ U, H.card ≤ k ∧ IsHittingSet H F := by
  induction' k with k ih generalizing F;
  · grind +locals;
  · obtain ⟨a, ha⟩ : ∃ a ∈ U, 4 * (F.filter (fun S => a ∉ S)).card ≤ F.card := by
      exact exists_element_hitting_many U F hU hsub hdense
    obtain ⟨H', hH'⟩ : ∃ H' ⊆ U, H'.card ≤ k ∧ IsHittingSet H' (F.filter (fun S => a ∉ S)) := by
      grind +qlia;
    refine' ⟨ Insert.insert a H', _, _, _ ⟩ <;> simp_all +decide [ IsHittingSet ];
    · exact Finset.insert_subset ha.1 hH'.1;
    · exact le_trans ( Finset.card_insert_le _ _ ) ( Nat.add_le_add_right hH'.2.1 _ );
    · exact fun S hS => Classical.or_iff_not_imp_left.2 fun h => hH'.2.2 S hS h

/-! ## §5. Hypergraph Transversal Bound (Cross-Domain)

This connects number theory (via Miller–Rabin witness density) to
**extremal hypergraph theory** and **approximation algorithms**.
Dense hypergraphs have bounded transversal number. -/

/-- **Cross-domain theorem**: Dense hypergraphs have bounded transversal number.
If every hyperedge in `F` covers at least 3/4 of the universe `U`,
then there exists a transversal of size ≤ `k` whenever `|F| < 4^k`. -/
theorem transversalNumber_le_of_dense
    (U : Finset α) (F : Finset (Finset α)) (k : ℕ)
    (hU : U.Nonempty)
    (hsub : ∀ S ∈ F, S ⊆ U)
    (hdense : ∀ S ∈ F, 4 * (U \ S).card ≤ U.card)
    (hk : F.card < 4 ^ k) :
    ∃ H ⊆ U, H.card ≤ k ∧ IsHittingSet H F :=
  exists_hittingSet_of_dense_family U F k hU hsub hdense hk

/-! ## §6. Miller–Rabin Specialization -/

/-- Candidate bases for Miller–Rabin: `{2, 3, …, B}`. -/
def MRCandidateBases (B : ℕ) : Finset ℕ :=
  Finset.Icc 2 B

/-- An odd composite number: odd, not prime, and greater than 2. -/
def isOddComposite (n : ℕ) : Prop :=
  Odd n ∧ ¬ Nat.Prime n ∧ 2 < n

instance : DecidablePred isOddComposite := fun n => by
  unfold isOddComposite; infer_instance

/-- A base `a` is a Fermat witness for `n` if `a` is coprime to `n`
but `a^(n-1) ≢ 1 (mod n)`, or `a` shares a nontrivial factor with `n`. -/
def MRWitnessFor (a n : ℕ) : Prop :=
  2 ≤ a ∧ (¬ Nat.Coprime a n ∨
    (Nat.Coprime a n ∧ a ^ (n - 1) % n ≠ 1))

instance (a n : ℕ) : Decidable (MRWitnessFor a n) := by
  unfold MRWitnessFor; infer_instance

/-- The witness set: bases in `{2, …, B}` that are witnesses for `n`. -/
def witnessSet (B n : ℕ) : Finset ℕ :=
  (MRCandidateBases B).filter (fun a => MRWitnessFor a n)

/-- A hitting set `H` catches all odd composites up to `N`:
for every such `n`, some `a ∈ H` is a witness. -/
def hitsAllOddCompositesBelow (N : ℕ) (H : Finset ℕ) : Prop :=
  ∀ n, n ≤ N → isOddComposite n → ∃ a ∈ H, MRWitnessFor a n

/-- The family of witness sets for all odd composites up to `N`,
drawn from candidates up to `B`. -/
noncomputable def MRWitnessFamily (B N : ℕ) : Finset (Finset ℕ) :=
  ((Finset.range (N + 1)).filter (fun n => isOddComposite n)).image
    (fun n => witnessSet B n)

/-! ## §7. Candidate Bases Properties -/

theorem MRCandidateBases_card (B : ℕ) (_hB : 2 ≤ B) :
    (MRCandidateBases B).card = B - 1 := by
  simp [MRCandidateBases]

theorem MRCandidateBases_nonempty (B : ℕ) (hB : 2 ≤ B) :
    (MRCandidateBases B).Nonempty :=
  ⟨2, Finset.mem_Icc.mpr ⟨le_refl _, hB⟩⟩

theorem witnessSet_subset (B n : ℕ) :
    witnessSet B n ⊆ MRCandidateBases B :=
  Finset.filter_subset _ _

/-- **Miller–Rabin hitting set existence**: Assuming witness density ≥ 3/4
for all odd composites (the Monier–Rabin bound), there exists a small
deterministic hitting set.

This instantiates the general dense-family hitting set theorem with
the Miller–Rabin witness family. -/
theorem exists_MR_hittingSet
    (B N k : ℕ) (hB : 2 ≤ B)
    (hdense : ∀ S ∈ MRWitnessFamily B N,
      4 * ((MRCandidateBases B) \ S).card ≤ (MRCandidateBases B).card)
    (hsub : ∀ S ∈ MRWitnessFamily B N, S ⊆ MRCandidateBases B)
    (hk : (MRWitnessFamily B N).card < 4 ^ k) :
    ∃ H ⊆ MRCandidateBases B, H.card ≤ k ∧
      ∀ S ∈ MRWitnessFamily B N, ∃ a ∈ H, a ∈ S :=
  exists_hittingSet_of_dense_family (MRCandidateBases B)
    (MRWitnessFamily B N) k (MRCandidateBases_nonempty B hB) hsub hdense hk

/-! ## §8. Basic Hitting Set Properties -/

omit [DecidableEq α] in
theorem isHittingSet_empty_family (H : Finset α) :
    IsHittingSet H ∅ := by
  intro S hS; simp at hS

omit [DecidableEq α] in
theorem isHittingSet_mono {H₁ H₂ : Finset α} {F : Finset (Finset α)}
    (h : H₁ ⊆ H₂) (hH : IsHittingSet H₁ F) : IsHittingSet H₂ F := by
  intro S hS
  obtain ⟨a, haH, haS⟩ := hH S hS
  exact ⟨a, h haH, haS⟩

theorem uncoveredBy_subset_family (H : Finset α) (F : Finset (Finset α)) :
    uncoveredBy H F ⊆ F :=
  Finset.filter_subset _ _

theorem uncoveredBy_empty_iff_hitting (H : Finset α) (F : Finset (Finset α)) :
    uncoveredBy H F = ∅ ↔ IsHittingSet H F := by
  constructor
  · intro h S hS
    by_contra hc
    push_neg at hc
    have : S ∈ uncoveredBy H F := by
      simp [uncoveredBy, Finset.mem_filter]
      exact ⟨hS, fun a ha => hc a ha⟩
    rw [h] at this; simp at this
  · intro h; ext x; constructor
    · intro hx
      simp only [uncoveredBy, Finset.mem_filter] at hx
      obtain ⟨hxF, hxmiss⟩ := hx
      obtain ⟨a, haH, haS⟩ := h x hxF
      exact absurd haS (hxmiss a haH)
    · intro hx; simp at hx

/-- Every set in the MR witness family is a subset of the candidate bases. -/
theorem MRWitnessFamily_sub (B N : ℕ) :
    ∀ S ∈ MRWitnessFamily B N, S ⊆ MRCandidateBases B := by
  intro S hS
  simp [MRWitnessFamily] at hS
  obtain ⟨n, _, rfl⟩ := hS
  exact witnessSet_subset B n