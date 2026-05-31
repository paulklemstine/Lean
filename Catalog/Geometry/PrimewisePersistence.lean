/-
# Primewise Persistent Homology for Arithmetic Manifold Discrimination

This file develops the theory of prime-indexed persistence invariants
that can potentially distinguish isospectral but nonisometric arithmetic manifolds.

We define:
- `PersistenceInterval`: birth-death pairs with ordering
- `Barcode`: finite lists of persistence intervals
- `PrimewiseBarcode`: prime-indexed families of barcodes
- `BottleneckMatchCost`: matching cost for bottleneck distance

Key results:
- Triangle inequality for interval matching cost
- Rank function monotonicity in both arguments
- Betti number bounds and additivity
- Separating prime existence for distinct length lists
-/

import Mathlib

open Finset Nat BigOperators

noncomputable section

/-! ## Persistence Intervals -/

/-- A persistence interval represents a topological feature born at time `birth`
    and dying at time `death`, with birth ≤ death. -/
structure PersistenceInterval where
  birth : ℕ
  death : ℕ
  valid : birth ≤ death
  deriving DecidableEq

namespace PersistenceInterval

/-- The lifetime (persistence) of an interval. -/
def lifetime (I : PersistenceInterval) : ℕ := I.death - I.birth

/-- An interval is alive at filtration parameter t. -/
def aliveAt (I : PersistenceInterval) (t : ℕ) : Prop :=
  I.birth ≤ t ∧ t < I.death

instance decAliveAt (I : PersistenceInterval) (t : ℕ) : Decidable (I.aliveAt t) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-- The lifetime of an interval with birth = death is zero. -/
theorem lifetime_eq_zero_of_birth_eq_death (I : PersistenceInterval)
    (h : I.birth = I.death) : I.lifetime = 0 := by
  simp [lifetime, h]

/-- An interval with positive lifetime has strict inequality birth < death. -/
theorem birth_lt_death_of_pos_lifetime (I : PersistenceInterval)
    (h : 0 < I.lifetime) : I.birth < I.death := by
  simp [lifetime] at h; omega

/-- An interval is not alive before its birth. -/
theorem not_aliveAt_before_birth (I : PersistenceInterval) (t : ℕ)
    (h : t < I.birth) : ¬I.aliveAt t := by
  simp [aliveAt]; omega

/-- An interval is not alive at or after its death. -/
theorem not_aliveAt_after_death (I : PersistenceInterval) (t : ℕ)
    (h : I.death ≤ t) : ¬I.aliveAt t := by
  simp [aliveAt]; omega

end PersistenceInterval

/-! ## Barcodes -/

/-- A barcode is a finite list of persistence intervals. -/
abbrev Barcode := List PersistenceInterval

namespace Barcode

/-- The Betti number at filtration parameter t: count of intervals alive at t. -/
def bettiAt (B : Barcode) (t : ℕ) : ℕ :=
  (B.filter (fun I => decide (I.aliveAt t))).length

/-- Empty barcode has zero Betti numbers everywhere. -/
theorem bettiAt_nil (t : ℕ) : bettiAt [] t = 0 := by
  simp [bettiAt]

/-- Betti number is bounded by the barcode length. -/
theorem bettiAt_le_length (B : Barcode) (t : ℕ) :
    B.bettiAt t ≤ B.length := by
  exact List.length_filter_le _ _

/-- Concatenation of barcodes adds Betti numbers. -/
theorem bettiAt_append (B₁ B₂ : Barcode) (t : ℕ) :
    (B₁ ++ B₂).bettiAt t = B₁.bettiAt t + B₂.bettiAt t := by
  simp [bettiAt, List.filter_append, List.length_append]

end Barcode

/-! ## Rank Function -/

/-- The rank function β(s, t) counts intervals [b, d) with b ≤ s and t < d.
    This encodes the persistent Betti numbers. -/
def rankFunction (B : Barcode) (s t : ℕ) : ℕ :=
  (B.filter (fun I => decide (I.birth ≤ s ∧ t < I.death))).length

/-
The rank function is monotone decreasing in the second argument.
-/
theorem rankFunction_antitone_snd (B : Barcode) (s t₁ t₂ : ℕ)
    (h : t₁ ≤ t₂) : rankFunction B s t₂ ≤ rankFunction B s t₁ := by
  unfold rankFunction;
  induction' B with I B ih <;> simp_all +decide [ List.filter_cons ];
  grind

/-
The rank function is monotone increasing in the first argument.
-/
theorem rankFunction_monotone_fst (B : Barcode) (s₁ s₂ : ℕ) (t : ℕ)
    (h : s₁ ≤ s₂) : rankFunction B s₁ t ≤ rankFunction B s₂ t := by
  unfold rankFunction;
  induction' B with I B ih;
  · rfl;
  · grind

/-- The rank function at (s, s) equals the Betti number at s. -/
theorem rankFunction_diagonal_eq_betti (B : Barcode) (s : ℕ) :
    rankFunction B s s = B.bettiAt s := by
  simp [rankFunction, Barcode.bettiAt, PersistenceInterval.aliveAt]

/-- The rank function of an empty barcode is zero. -/
theorem rankFunction_nil (s t : ℕ) : rankFunction [] s t = 0 := by
  simp [rankFunction]

/-- The rank function is bounded by the barcode length. -/
theorem rankFunction_le_length (B : Barcode) (s t : ℕ) :
    rankFunction B s t ≤ B.length :=
  List.length_filter_le _ _

/-! ## Interval Matching Cost (Bottleneck Distance) -/

/-- The cost of matching two persistence intervals:
    max of |birth₁ - birth₂| and |death₁ - death₂|. -/
def intervalMatchCost (I J : PersistenceInterval) : ℕ :=
  max (Int.natAbs ((I.birth : ℤ) - J.birth)) (Int.natAbs ((I.death : ℤ) - J.death))

/-- Matching an interval to itself costs zero. -/
theorem intervalMatchCost_self (I : PersistenceInterval) :
    intervalMatchCost I I = 0 := by
  simp [intervalMatchCost]

/-- Matching cost is symmetric. -/
theorem intervalMatchCost_symm (I J : PersistenceInterval) :
    intervalMatchCost I J = intervalMatchCost J I := by
  simp only [intervalMatchCost]
  congr 1 <;> simp [← Int.natAbs_neg ((I.birth : ℤ) - J.birth),
                     ← Int.natAbs_neg ((I.death : ℤ) - J.death)]

/-
Triangle inequality for interval match cost.
-/
theorem intervalMatchCost_triangle (I J K : PersistenceInterval) :
    intervalMatchCost I K ≤ intervalMatchCost I J + intervalMatchCost J K := by
  grind +locals

/-! ## Primewise Barcodes -/

/-- A primewise barcode assigns a barcode to each prime number.
    This models the construction K_p(M) for varying primes p. -/
structure PrimewiseBarcode where
  atPrime : ℕ → Barcode

/-- The set of primes at which two primewise barcodes disagree. -/
def separatingPrimes (F G : PrimewiseBarcode) : Set ℕ :=
  {p | Nat.Prime p ∧ F.atPrime p ≠ G.atPrime p}

/-! ## Prime Density -/

/-- Count of primes up to n. -/
def primeCount (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun p => Nat.Prime p)).card

/-- A set of primes has positive lower density. -/
def HasPositivePrimeDensity (S : Set ℕ) [DecidablePred (· ∈ S)] : Prop :=
  ∃ (δ : ℚ), 0 < δ ∧ ∃ N : ℕ, ∀ n ≥ N,
    primeCount n > 0 →
    δ * primeCount n ≤ ((Finset.range (n + 1)).filter (fun p => Nat.Prime p ∧ p ∈ S)).card

/-! ## Mod-p Filtration -/

/-- Given a list of natural numbers and a prime p, compute the sorted list
    of distinct residues mod p. This determines the filtration structure. -/
def modPResidues (lengths : List ℕ) (p : ℕ) : List ℕ :=
  (lengths.map (· % p)).eraseDups

/-
The number of distinct residues mod p is at most p.
-/
theorem modPResidues_length_le (lengths : List ℕ) (p : ℕ) (hp : 0 < p) :
    (modPResidues lengths p).length ≤ p := by
  -- The list of residues is a subset of {0, 1, ..., p-1}, and thus the length of the list after removing duplicates is at most p.
  have h_subset : (List.map (fun x => x % p) lengths).eraseDups.toFinset ⊆ Finset.range p := by
    intro x hx
    generalize_proofs at *; (
    have h_subset : ∀ x ∈ (lengths.map (fun x => x % p)).eraseDups, x < p := by
      intros x hx; exact (by
      have h_subset : ∀ x ∈ (lengths.map (fun x => x % p)).eraseDups, x ∈ List.map (fun x => x % p) lengths := by
        induction' ( List.map ( fun x => x % p ) lengths ) using List.reverseRecOn with x xs ih <;> simp_all +decide [ List.eraseDups_append ];
        simp_all +decide [ List.removeAll ];
        grind
      generalize_proofs at *; (
      exact List.mem_map.mp ( h_subset x hx ) |> fun ⟨ y, hy, hy' ⟩ => hy'.symm ▸ Nat.mod_lt _ hp));
    generalize_proofs at *; (
    exact Finset.mem_range.mpr ( h_subset x ( List.mem_toFinset.mp hx ) )))
  generalize_proofs at *; (
  convert Finset.card_le_card h_subset using 1
  generalize_proofs at *; (
  rw [ List.toFinset_card_of_nodup ] ; unfold modPResidues ; aesop;
  -- The eraseDupsBy loop preserves the nodup property.
  have h_eraseDupsBy_nodup : ∀ (l : List ℕ) (acc : List ℕ), List.Nodup acc → List.Nodup (List.eraseDupsBy.loop (fun x1 x2 => x1 == x2) l acc) := by
    intros l acc hacc; induction' l with hd tl ih generalizing acc <;> simp_all +decide [ List.eraseDupsBy.loop ] ;
    cases h : acc.any fun x2 => hd == x2 <;> simp_all +decide [ List.eraseDupsBy.loop ] ; aesop;
  generalize_proofs at *; (
  exact h_eraseDupsBy_nodup _ _ ( by simp +decide )));
  norm_num)

/-
Distinct lists can be separated by their mod-p residue structure.
-/
theorem exists_prime_separating_residues
    (a b : List ℕ) (hdiff : a ≠ b) :
    ∃ p, Nat.Prime p ∧ a.map (· % p) ≠ b.map (· % p) := by
  contrapose! hdiff;
  -- If a.map (· % p) = b.map (· % p) for all primes p, then a and b must be equal.
  have h_eq : ∀ p : ℕ, Nat.Prime p → (a.map (· % p)).length = (b.map (· % p)).length ∧ ∀ (i : ℕ), i < (a.map (· % p)).length → (a.map (· % p))[i]! = (b.map (· % p))[i]! := by
    aesop;
  refine' List.ext_get _ _ <;> simp_all +decide [ Nat.mod_eq_of_lt ];
  · simpa using congr_arg List.length ( hdiff 2 Nat.prime_two );
  · intro n hn hn'; have := hdiff ( Nat.find ( Nat.exists_infinite_primes ( Max.max ( a[n] + 1 ) ( b[n] + 1 ) ) ) ) ( Nat.find_spec ( Nat.exists_infinite_primes ( Max.max ( a[n] + 1 ) ( b[n] + 1 ) ) ) |>.2 ) ; replace := congr_arg ( fun l => l[n]! ) this ; simp_all +decide [ Nat.mod_eq_of_lt ] ;

/-! ## Sunada-Type Isospectral Pairs -/

/-- A Sunada configuration: two subgroups of the same size with identical
    conjugacy class intersection counts (isospectrality condition). -/
structure SunadaConfig where
  numClasses : ℕ
  classCount₁ : Fin numClasses → ℕ
  classCount₂ : Fin numClasses → ℕ
  isospectral : classCount₁ = classCount₂

/-- For a Sunada configuration, the spectra agree on all conjugacy classes. -/
theorem sunada_class_agree (T : SunadaConfig) (c : Fin T.numClasses) :
    T.classCount₁ c = T.classCount₂ c := by
  rw [T.isospectral]

/-! ## Euler Characteristic via Barcodes -/

/-- For an alternating sum of Betti numbers, barcodes give
    the Euler characteristic at each filtration level. -/
def eulerCharAt (evens odds : Barcode) (t : ℕ) : ℤ :=
  (evens.bettiAt t : ℤ) - (odds.bettiAt t : ℤ)

/-- The Euler characteristic of empty barcodes is zero. -/
theorem eulerChar_empty (t : ℕ) : eulerCharAt [] [] t = 0 := by
  simp [eulerCharAt, Barcode.bettiAt]

/-- Euler characteristic is additive under concatenation. -/
theorem eulerCharAt_append (e₁ e₂ o₁ o₂ : Barcode) (t : ℕ) :
    eulerCharAt (e₁ ++ e₂) (o₁ ++ o₂) t =
    eulerCharAt e₁ o₁ t + eulerCharAt e₂ o₂ t := by
  simp [eulerCharAt, Barcode.bettiAt_append]
  omega

/-! ## Key Theorem: Distinguishing via Residues -/

/-
**Core Separation Lemma**: If two natural number lists agree as multisets
    (same elements with same multiplicity) but differ in order,
    then for any prime p larger than all elements, the mod-p images
    preserve the ordering difference.

    This is the foundational result that makes primewise invariants
    potentially useful for geometric discrimination.
-/
theorem large_prime_preserves_order
    (a b : List ℕ) (M : ℕ)
    (hbound_a : ∀ x ∈ a, x ≤ M)
    (hbound_b : ∀ x ∈ b, x ≤ M)
    (p : ℕ) (hp : Nat.Prime p) (hp_large : M < p)
    (hdiff : a ≠ b) :
    a.map (· % p) ≠ b.map (· % p) := by
  convert hdiff using 1;
  · rw [ List.map_congr_left fun x hx => Nat.mod_eq_of_lt ( lt_of_le_of_lt ( hbound_a x hx ) hp_large ) ] ; aesop;
  · exact Eq.symm ( List.map_congr_left fun x hx => Nat.mod_eq_of_lt ( lt_of_le_of_lt ( hbound_b x hx ) hp_large ) ) ▸ by norm_num;

/-
**Agreement Bound**: The number of primes at which two bounded
    distinct lists have identical mod-p images is finite.
    Specifically, any agreement prime must divide some pairwise difference.
-/
theorem finite_agreement_primes
    (a b : List ℕ)
    (hlen : a.length = b.length) (hlen_pos : 0 < a.length)
    (hdiff : ∃ i, ∃ hi : i < a.length,
      a.get ⟨i, hi⟩ ≠ b.get ⟨i, by omega⟩) :
    Set.Finite {p : ℕ | Nat.Prime p ∧ a.map (· % p) = b.map (· % p)} := by
  -- Let $M = \max(\max �(a�), \max(b))$.
  set M := max (a.foldl max 0) (b.foldl max 0) with hM_def
  generalize_proofs at *; (
  -- By the large_prime_preserves_order theorem, any prime p > M separates the lists.
  have h_large_prime : ∀ p, Nat.Prime p → M < p → (a.map (· % p)) ≠ (b.map (· % p)) := by
    intro p hp hpM
    have h_bound_a : ∀ x ∈ a, x ≤ M := by
      intro x hx
      have h_foldl_max : x ≤ List.foldl max 0 a := by
        have h_foldl_max : ∀ {l : List ℕ}, x ∈ l → x ≤ List.foldl max 0 l := by
          intros l hl; induction' l using List.reverseRecOn with l IH <;> aesop;
        generalize_proofs at *; (exact h_foldl_max hx)
      generalize_proofs at *; (
      exact le_trans h_foldl_max ( le_max_left _ _ ))
    have h_bound_b : ∀ x ∈ b, x ≤ M := by
      -- By definition of $M$, we know that every element in $b$ is less than or equal to $M$.
      intros x hx
      have h_foldl_b : ∀ {l : List ℕ}, x ∈ l → x ≤ List.foldl max 0 l := by
        intros l hl; induction' l using List.reverseRecOn with l IH <;> aesop;
      generalize_proofs at *; (
      exact le_trans ( h_foldl_b hx ) ( le_max_right _ _ ))
    generalize_proofs at *; (
    apply large_prime_preserves_order a b M h_bound_a h_bound_b p hp hpM; aesop;)
  generalize_proofs at *; (
  exact Set.finite_iff_bddAbove.mpr ⟨ M, fun p hp => not_lt.1 fun contra => h_large_prime p hp.1 contra hp.2 ⟩))

/-! ## Main Conjecture -/

/-- **Conjecture (Testable)**: For any two distinct lists of natural numbers
    with the same multiset, the set of primes that separate their
    mod-p residue patterns has density 1.

    This is computationally testable: given specific isospectral pairs,
    compute mod-p residues for p ∈ {2, 3, 5, 7, 11, 13, 17, 19, 23, 29}
    and check if barcodes differ. The conjecture predicts that only
    finitely many primes should fail to separate. -/
def conjecture_density_one_separation : Prop :=
  ∀ (a b : List ℕ),
    a.length = b.length →
    List.Perm a b →
    a ≠ b →
    ∃ (S : Set ℕ),
      Set.Finite S ∧
      ∀ p, Nat.Prime p → p ∉ S → a.map (· % p) ≠ b.map (· % p)

/-
The conjecture follows from the large prime preservation theorem:
    the exceptional set consists of primes up to the maximum element.
-/
theorem conjecture_density_one_holds :
    conjecture_density_one_separation := by
  intro a b hlen hperm hdiff
  set M := a ++ b |>.foldl max 0 with hM_def;
  refine' ⟨ { p : ℕ | p ≤ M }, _, _ ⟩;
  · exact Set.finite_Iic M;
  · have h_large_prime_preserves_order : ∀ x ∈ a ++ b, x ≤ M := by
      -- By definition of `foldl max`, the maximum element in the list `a ++ b` is greater than or equal to any element in the list.
      have h_max_ge : ∀ {l : List ℕ}, ∀ x ∈ l, x ≤ List.foldl max 0 l := by
        intros l x hx; induction' l using List.reverseRecOn with l IH <;> aesop;
      exact h_max_ge;
    exact fun p pp hp => large_prime_preserves_order a b M ( fun x hx => h_large_prime_preserves_order x <| List.mem_append_left _ hx ) ( fun x hx => h_large_prime_preserves_order x <| List.mem_append_right _ hx ) p pp ( not_le.mp hp ) hdiff

end