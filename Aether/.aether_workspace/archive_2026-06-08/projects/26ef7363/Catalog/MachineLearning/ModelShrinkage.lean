/-
# Model-Shrinkage Distance as a Proof-Complexity Invariant

This module develops a semantic framework for proof complexity based on
*model-shrinkage*: the idea that each proof step that narrows the set of
satisfying assignments must "pay" for the resulting information loss.

The core objects are:
- `Assignment n`: the type `Fin n → Bool` of Boolean assignments on `n` variables.
- `deficiency n S`: the entropy deficiency `n - Nat.log2 |S|`.
- `restrictedAssignments`: assignments fixing a subset of coordinates.
- `prodAssignments`: product of assignment sets on disjoint variable blocks.
- Bounded-shrinkage derivation chains and their length lower bounds.

## Cross-domain connections

- **Information theory**: deficiency behaves like entropy defect; additivity
  under independent composition mirrors Shannon entropy additivity.
- **Coding theory / Boolean cube**: coordinate restrictions are affine subcubes
  of codimension |I|; exact shrinkage equals geometric codimension.
- **Proof complexity**: bounded-shrinkage chains model semantic derivations in
  resolution and Frege systems; the length lower bound is a proto-lower-bound
  linking proof length to information loss.

Keywords: proof complexity, model counting, #SAT, Boolean cube, entropy,
codimension, information theory, direct-sum, semantic lower bounds,
resolution complexity, Frege systems, combinatorial filtrations
-/

import Mathlib

open Finset BigOperators

/-- A Boolean assignment on `n` variables. -/
abbrev Assignment (n : ℕ) := Fin n → Bool

/-- The full set of all Boolean assignments on `n` variables. -/
noncomputable def fullAssignments (n : ℕ) : Finset (Assignment n) :=
  Fintype.elems

/-- The entropy deficiency of a set of assignments `S ⊆ {0,1}^n`:
    `def(S) := n - Nat.log2 |S|`.
    Measures how far `S` is from filling the full Boolean cube. -/
def deficiency (n : ℕ) (S : Finset (Assignment n)) : ℕ :=
  n - Nat.log (2 : ℕ) S.card

/-- Assignments that agree with pattern `b` on coordinates in `I`. -/
def restrictedAssignments (n : ℕ) (I : Finset (Fin n))
    (b : {i // i ∈ I} → Bool) : Finset (Assignment n) :=
  Finset.univ.filter (fun σ => ∀ (i : Fin n) (hi : i ∈ I), σ i = b ⟨i, hi⟩)

/-! ## Theorem 1: Telescoping model-shrinkage identity -/

/-
The telescoping identity for `Nat.log`-based shrinkage along a chain:
    `∑ᵢ (log₂ |Sᵢ| - log₂ |Sᵢ₊₁|) = log₂ |S₀| - log₂ |Sₖ|`.
-/
theorem sum_log_card_telescopes
    {α : Type} [DecidableEq α]
    (S : Fin (k + 1) → Finset α)
    (hmono : ∀ i : Fin k, S i.succ ⊆ S i.castSucc)
    (hnonempty : ∀ i, (S i).Nonempty) :
    (∑ i : Fin k, (Nat.log 2 (S i.castSucc).card - Nat.log 2 (S i.succ).card)) =
      Nat.log 2 (S 0).card - Nat.log 2 (S (Fin.last k)).card := by
  induction' k with k ih;
  · aesop;
  · have := ih ( fun i => S i.castSucc ) ( fun i => hmono i.castSucc ) ( fun i => hnonempty i.castSucc );
    simp_all +decide [ Fin.sum_univ_castSucc ];
    rw [ tsub_add_tsub_cancel ];
    · refine' Nat.log_mono_right _;
      have h_mono : ∀ i j : Fin (k + 2), i ≤ j → S j ⊆ S i := by
        intro i j hij; induction' j using Fin.inductionOn with j ih ih; aesop;
        cases hij.eq_or_lt <;> [ aesop; exact Finset.Subset.trans ( hmono _ ) ( ih <| Nat.le_of_lt_succ ‹_› ) ];
      exact Finset.card_le_card ( h_mono _ _ ( Nat.zero_le _ ) );
    · exact Nat.log_mono_right ( Finset.card_le_card ( hmono ( Fin.last k ) ) )

/-! ## Theorem 2: Coordinate restriction gives exact shrinkage -/

/-
The number of assignments agreeing with pattern `b` on `I` is `2^(n - |I|)`.
-/
theorem card_restrictedAssignments (n : ℕ) (I : Finset (Fin n))
    (b : {i // i ∈ I} → Bool) :
    (restrictedAssignments n I b).card = 2 ^ (n - I.card) := by
  have h_card : (restrictedAssignments n I b).card = 2 ^ (n - I.card) := by
    have : restrictedAssignments n I b = Finset.image (fun σ : {i // i ∉ I} → Bool => fun i : Fin n => if hi : i ∈ I then b ⟨i, hi⟩ else σ ⟨i, hi⟩) (Finset.univ : Finset ({i // i ∉ I} → Bool)) := by
      ext σ; simp [restrictedAssignments];
      constructor;
      · intro hσ; use fun i => σ i; ext i; aesop;
      · grind
    rw [ this, Finset.card_image_of_injective ];
    · simp +decide [ Finset.card_univ ];
    · intro σ₁ σ₂ h; ext ⟨ i, hi ⟩ ; replace h := congr_fun h i; aesop;
  exact h_card

/-
Model shrinkage from the full cube to a coordinate restriction equals `|I|`.
-/
theorem shrinkage_of_coordinate_restriction (n : ℕ) (I : Finset (Fin n))
    (b : {i // i ∈ I} → Bool) :
    Nat.log 2 (Fintype.card (Assignment n)) - Nat.log 2 (restrictedAssignments n I b).card
      = I.card := by
  -- By definition of $Fintype.card$, we know that $Fintype.card (Assignment n) = 2^n$.
  have h_card : Fintype.card (Assignment n) = 2 ^ n := by
    norm_num;
  have := card_restrictedAssignments n I b;
  rw [ h_card, this, Nat.log_pow, Nat.log_pow ] <;> norm_num;
  rw [ Nat.sub_sub_self ( le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ]

/-! ## Theorem 3: Entropy deficiency is monotone under implication -/

/-
Deficiency is monotone: if `T ⊆ S` and `T` is nonempty, then `def(S) ≤ def(T)`.
-/
theorem deficiency_monotone
    {n : ℕ} {S T : Finset (Assignment n)}
    (hTS : T ⊆ S) (hT : T.Nonempty) :
    deficiency n S ≤ deficiency n T := by
  exact Nat.sub_le_sub_left ( Nat.log_mono_right <| Finset.card_le_card hTS ) _

/-
Deficiency equality characterization under subset inclusion.
-/
theorem deficiency_eq_iff_of_subset
    {n : ℕ} {S T : Finset (Assignment n)}
    (hTS : T ⊆ S) (hT : T.Nonempty) :
    deficiency n S = deficiency n T ↔ Nat.log 2 S.card = Nat.log 2 T.card := by
  constructor <;> intro h;
  · unfold deficiency at h;
    rw [ tsub_right_inj ] at h;
    · exact h;
    · refine' Nat.le_trans ( Nat.log_mono_right <| Finset.card_le_univ _ ) _;
      simp +arith +decide [ pow_succ' ];
    · refine' Nat.le_trans ( Nat.log_mono_right <| Finset.card_le_univ _ ) _;
      simp +arith +decide [ pow_succ' ];
  · unfold deficiency; aesop;

/-! ## Theorem 4: Additivity under independent variable splitting -/

/-- Product of assignment sets on disjoint variable blocks. -/
def prodAssignments (S : Finset (Assignment m)) (T : Finset (Assignment n)) :
    Finset (Assignment (m + n)) :=
  (S ×ˢ T).map ⟨fun p => Fin.addCases (p.1 ·) (p.2 ·),
    fun ⟨a₁, a₂⟩ ⟨b₁, b₂⟩ h => by
      simp only [Prod.mk.injEq]
      have hf := congr_fun h
      constructor
      · funext i
        have := hf (Fin.castAdd n i)
        simp [Fin.addCases] at this
        exact this
      · funext j
        have := hf (Fin.natAdd m j)
        simp [Fin.addCases] at this
        exact this⟩

/-
Cardinality of product assignments.
-/
theorem card_prodAssignments (S : Finset (Assignment m)) (T : Finset (Assignment n)) :
    (prodAssignments S T).card = S.card * T.card := by
  rw [ prodAssignments, Finset.card_map, Finset.card_product ]

/-
Deficiency is sub-additive under independent variable splitting:
    `def(S ⊗ T) ≤ def(S) + def(T)`. Equality holds when both cardinalities
    are exact powers of two (the "ideal" case). This follows from
    `Nat.log 2 (a * b) ≥ Nat.log 2 a + Nat.log 2 b`.
-/
theorem deficiency_add_le (S : Finset (Assignment m)) (T : Finset (Assignment n))
    (hS : S.Nonempty) (hT : T.Nonempty) :
    deficiency (m + n) (prodAssignments S T) ≤
      deficiency m S + deficiency n T := by
  unfold deficiency;
  -- Applying the logarithm property: $\log_b(xy) \geq \log_b(x) + \log_b(y)$
  have h_log_prop : Nat.log 2 (S.card * T.card) ≥ Nat.log 2 S.card + Nat.log 2 T.card := by
    refine Nat.le_log_of_pow_le ( by decide ) ?_;
    rw [ pow_add ] ; exact Nat.mul_le_mul ( Nat.pow_log_le_self 2 hS.card_pos.ne' ) ( Nat.pow_log_le_self 2 hT.card_pos.ne' ) ;
  rw [ card_prodAssignments ] ; omega;

/-
Deficiency is exactly additive when both cardinalities are powers of two.
-/
theorem deficiency_add_of_pow2 (S : Finset (Assignment m)) (T : Finset (Assignment n))
    (hS : ∃ a, S.card = 2 ^ a) (hT : ∃ b, T.card = 2 ^ b) :
    deficiency (m + n) (prodAssignments S T) =
      deficiency m S + deficiency n T := by
  -- Let S.card = 2^a, T.card = 2^b. Then (prodAssignments S T).card = 2^a * 2^b = 2^(a+b).
  obtain ⟨a, ha⟩ := hS
  obtain ⟨b, hb⟩ := hT
  have h_card : (prodAssignments S T).card = 2 ^ (a + b) := by
    rw [ card_prodAssignments, ha, hb, pow_add ];
  -- By definition of $deficiency$, we have:
  unfold deficiency;
  rw [ h_card, ha, hb, Nat.log_pow, Nat.log_pow, Nat.log_pow ] <;> norm_num;
  rw [ tsub_add_tsub_comm ];
  · contrapose! ha;
    exact ne_of_lt ( lt_of_le_of_lt ( Finset.card_le_univ _ ) ( by simpa using pow_lt_pow_right₀ ( by decide ) ha ) );
  · contrapose! hb;
    exact ne_of_lt ( lt_of_le_of_lt ( Finset.card_le_univ _ ) ( by simpa [ Fintype.card_pi ] using pow_lt_pow_right₀ one_lt_two hb ) )

/-! ## Theorem 5: Lower bound for bounded-shrinkage derivation systems -/

/-
In a bounded-shrinkage chain where each step satisfies
    `|Sᵢ| ≤ B · |Sᵢ₊₁|`, iterating gives `|S₀| ≤ B^k · |Sₖ|`.
    This is the core multiplicative bound underlying proof-length lower bounds.
-/
theorem card_bound_of_bounded_shrink
    {α : Type} [DecidableEq α]
    (S : Fin (k + 1) → Finset α)
    (B : ℕ)
    (hB : ∀ i : Fin k, (S i.castSucc).card ≤ B * (S i.succ).card) :
    (S 0).card ≤ B ^ k * (S (Fin.last k)).card := by
  induction' k with k ih;
  · grind +locals;
  · specialize ih ( fun i => S i.succ ) ( fun i => hB i.succ ) ; simp_all +decide [ pow_succ', mul_assoc, Fin.last ] ;
    exact le_trans ( hB 0 ) ( Nat.mul_le_mul_left _ ih )

/-
Lower bound on derivation length: if each step shrinks by at most factor `B`,
    then `k ≥ log_B(|S₀| / |Sₖ|)`. Uses `Nat.log` base `B`.
-/
theorem length_lower_bound_of_bounded_shrink
    {α : Type} [DecidableEq α]
    (S : Fin (k + 1) → Finset α)
    (B : ℕ)
    (hB : ∀ i : Fin k, (S i.castSucc).card ≤ B * (S i.succ).card)
    (hpos : 1 < B)
    (hnonempty : ∀ i, (S i).Nonempty) :
    k ≥ Nat.log B ((S 0).card / (S (Fin.last k)).card) := by
  -- By definition of $S$, we know that $|S₀| \leq B^k |Sₖ|$.
  have h_card_bound : (S 0).card ≤ B ^ k * (S (Fin.last k)).card := by
    exact card_bound_of_bounded_shrink S B hB;
  refine' Nat.le_trans ( Nat.log_mono_right <| Nat.div_le_div_right h_card_bound ) _;
  rw [ Nat.mul_div_cancel _ ( Finset.card_pos.mpr ( hnonempty _ ) ) ] ; exact Nat.le_of_eq ( Nat.log_pow hpos _ ) ;

/-! ## Computational verification helpers -/

/-
The cardinality of the full assignment space is `2^n`.
-/
theorem card_assignment (n : ℕ) : Fintype.card (Assignment n) = 2 ^ n := by
  exact Fintype.card_pi.trans ( by norm_num )

/-
All assignments form a nonempty set.
-/
theorem fullAssignments_nonempty (n : ℕ) : (Finset.univ : Finset (Assignment n)).Nonempty := by
  exact ⟨ fun _ => Bool.true, Finset.mem_univ _ ⟩

/-
The deficiency of the full assignment space is zero.
-/
theorem deficiency_full (n : ℕ) :
    deficiency n (Finset.univ : Finset (Assignment n)) = 0 := by
  simp +decide [ deficiency, card_assignment ]

#print axioms sum_log_card_telescopes
#print axioms card_restrictedAssignments
#print axioms shrinkage_of_coordinate_restriction
#print axioms deficiency_monotone
#print axioms deficiency_eq_iff_of_subset
#print axioms card_prodAssignments
#print axioms deficiency_add_le
#print axioms deficiency_add_of_pow2
#print axioms card_bound_of_bounded_shrink
#print axioms length_lower_bound_of_bounded_shrink
#print axioms card_assignment
#print axioms deficiency_full