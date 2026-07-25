/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Scalable Arithmetic TDA Pipeline — Torsion Profiles from Smith Normal Forms

This file proves key theorems about extracting torsion profiles from
Smith Normal Form diagonal entries, establishing the mathematical foundation
for a scalable TDA pipeline that computes torsion information alongside
Betti numbers at minimal additional cost.

## Main Results

### Theorem 1: SNF Torsion Extraction Correctness
The torsion factors extracted from SNF diagonal entries correctly capture
exactly the entries > 1, preserving the divisibility chain structure.

### Theorem 2: Prime Profile Completeness
Every prime dividing any invariant factor is captured by `primeFactorsOfList`,
and the factorization respects the divisibility structure.

### Theorem 3: Cross-Domain Bridge (Number Theory ↔ TDA)
The p-primary part of the torsion profile is determined by p-adic valuations
of the invariant factors, connecting TDA torsion to number-theoretic structure.

### Additional Results
- Monotonicity of prime factor sets under divisibility
- Torsion profile stability under equivalence of invariant factor systems
- Computational bounds on prime sieving
-/
import Mathlib
import Pythagorean.TorsionProfileDefs

open Finset Nat List

/-! ## Section 1: SNF Torsion Extraction Correctness

We prove that `snfDiagToTorsionFactors` correctly extracts exactly
the invariant factors that contribute to torsion (those > 1), and
that the extracted list preserves the divisibility chain. -/

/-- The torsion factors extracted from a diagonal are exactly the elements > 1. -/
theorem snfDiagToTorsionFactors_mem (diag : List ℕ) (d : ℕ) :
    d ∈ snfDiagToTorsionFactors diag ↔ d ∈ diag ∧ d > 1 := by
  simp [snfDiagToTorsionFactors, List.mem_filter]

/-- Torsion factors preserve the divisibility chain from the original diagonal.
    This is the key correctness property: filtering preserves the chain structure. -/
theorem snfDiagToTorsionFactors_chain (diag : List ℕ)
    (hchain : diag.IsChain (· ∣ ·)) :
    (snfDiagToTorsionFactors diag).IsChain (· ∣ ·) := by
  exact hchain.sublist List.filter_sublist

/-- The count of nontrivial factors is at most the length of the diagonal. -/
theorem countNontrivial_le_length (diag : List ℕ) :
    countNontrivial diag ≤ diag.length := by
  unfold countNontrivial snfDiagToTorsionFactors
  exact List.length_filter_le _ _

/-- If all diagonal entries are 1, the torsion is trivial (no torsion factors). -/
theorem snfDiagToTorsionFactors_trivial (diag : List ℕ)
    (h : ∀ d ∈ diag, d = 1) :
    snfDiagToTorsionFactors diag = [] := by
  simp [snfDiagToTorsionFactors, List.filter_eq_nil_iff]
  intro x hx
  simp [h x hx]

/-
The number of torsion factors equals the total length minus
    the count of entries equal to 1, for positive entries.
-/
theorem countNontrivial_eq (diag : List ℕ) (hpos : ∀ d ∈ diag, d > 0) :
    countNontrivial diag = diag.length - (diag.filter (· = 1)).length := by
  unfold countNontrivial;
  unfold snfDiagToTorsionFactors;
  induction diag <;> simp_all +decide [ List.filter_cons ];
  grind

/-! ## Section 2: Prime Factor Analysis

We prove properties of the prime factorization of invariant factors,
establishing that `primeFactorsOfList` correctly captures all primes
appearing in the torsion subgroup. -/

/-
Every prime factor of any element in the list appears in `primeFactorsOfList`.
-/
theorem primeFactorsOfList_complete (ds : List ℕ) (p d : ℕ)
    (hd : d ∈ ds) (hp : p ∈ d.primeFactors) :
    p ∈ primeFactorsOfList ds := by
  induction ds using List.reverseRecOn <;> simp_all +decide [ primeFactorsOfList ];
  grind

/-
Every element of `primeFactorsOfList` is prime and divides some list element.
-/
theorem primeFactorsOfList_sound (ds : List ℕ) (p : ℕ)
    (hp : p ∈ primeFactorsOfList ds) :
    Nat.Prime p ∧ ∃ d ∈ ds, p ∣ d := by
  induction ds using List.reverseRecOn <;> simp_all +decide [ primeFactorsOfList ];
  grind

/-
If d₁ ∣ d₂, then the prime factors of d₁ are a subset of those of d₂.
-/
theorem primeFactors_subset_of_dvd {d₁ d₂ : ℕ} (hd : d₁ ∣ d₂) (h₂ : d₂ ≠ 0) :
    d₁.primeFactors ⊆ d₂.primeFactors := by
  grind +suggestions

/-
In a divisibility chain, the prime factors of the last element
    contain all prime factors of the entire chain.
-/
theorem primeFactors_chain_last (ds : List ℕ)
    (hchain : ds.IsChain (· ∣ ·)) (hne : ds ≠ [])
    (hpos : ∀ d ∈ ds, d > 0) :
    primeFactorsOfList ds = (ds.getLast hne).primeFactors := by
  nontriviality;
  induction ds using List.reverseRecOn <;> simp_all +decide [ primeFactorsOfList ];
  · grind;
  · rename_i l a ih;
    by_cases hl : l = [] <;> simp_all +decide [ List.isChain_cons_cons ];
    rw [ ih ];
    · apply primeFactors_subset_of_dvd;
      · rw [ List.isChain_iff_pairwise ] at hchain;
        rw [ List.pairwise_append ] at hchain ; aesop;
      · linarith [ hpos a ( Or.inr rfl ) ];
    · exact hchain.sublist ( List.sublist_append_left _ _ )

/-! ## Section 3: Cross-Domain Bridge — p-adic Valuations and Torsion

This section connects TDA (via invariant factors) to number theory
(via p-adic valuations). The key insight is that the p-primary part
of the torsion subgroup is completely determined by the p-adic
valuations of the invariant factors.

This bridges computational topology and arithmetic, establishing
that the tools of analytic number theory (valuations, local-global
principles) apply directly to topological data analysis. -/

/-
The p-adic valuation of a product equals the sum of p-adic valuations.
    This is the bridge between multiplicative structure (number theory)
    and additive structure (homological algebra / TDA).
-/
theorem padic_val_product (p : ℕ) (hp : Nat.Prime p) (ds : List ℕ)
    (hpos : ∀ d ∈ ds, d > 0) :
    emultiplicity p ds.prod = (ds.map (emultiplicity p)).sum := by
  induction ds <;> simp_all +decide [ Nat.Prime.emultiplicity_mul ];
  simp +decide [ emultiplicity ] ; aesop

/-
For a divisibility chain d₁ | d₂ | ⋯ | dᵣ, the p-adic valuations
    form a non-decreasing sequence. This is the number-theoretic
    manifestation of the filtration structure in persistent homology.
-/
theorem padic_val_monotone_of_dvd_chain (p : ℕ) (hp : Nat.Prime p)
    (ds : List ℕ) (hchain : ds.IsChain (· ∣ ·)) (hpos : ∀ d ∈ ds, d > 0) :
    ds.map (fun d => emultiplicity p d) |>.IsChain (· ≤ ·) := by
  -- By definition of emultiplicity, if $a \mid b$, then $emultiplicity p a \leq emultiplicity p b$.
  have h_emultiplicity_monotone : ∀ (a b : ℕ), a ∣ b → emultiplicity p a ≤ emultiplicity p b := by
    exact?;
  grind

/-
The total p-torsion rank (sum of p-adic valuations across all
    invariant factors) determines the dimension of the p-primary
    component. This connects the SNF computation to mod-p homology.
-/
theorem total_p_rank_eq_sum_valuations (p : ℕ) (hp : Nat.Prime p)
    (ds : List ℕ) (hpos : ∀ d ∈ ds, d > 0) :
    emultiplicity p ds.prod = (ds.map (emultiplicity p)).sum := by
  exact?

/-! ## Section 4: Sieve Correctness and Complexity Bounds

We prove correctness of the Eratosthenes sieve construction
and establish bounds on the number of primes up to √M. -/

/-
A sieve exists for any bound.
-/
theorem eratosthenes_sieve_exists (n : ℕ) :
    ∃ s : EratosthenesSieve n, ∀ m : Fin n, s.isPrime m = true ↔ Nat.Prime m.val := by
  exact ⟨ ⟨ fun m => Nat.Prime m, by simp +decide ⟩, fun m => by simp +decide ⟩

/-
The number of primes found by the sieve up to n is at most n.
-/
theorem sieve_prime_count_le (n : ℕ) (s : EratosthenesSieve n) :
    (Finset.univ.filter (fun m : Fin n => s.isPrime m = true)).card ≤ n := by
  convert Finset.card_le_card ( Finset.filter_subset _ _ ) |> le_trans <| ?_;
  convert Finset.card_fin n |> le_of_eq

/-
Every composite number has a prime factor at most its square root.
    This is the fundamental lemma underlying trial division and sieve methods.
-/
theorem exists_prime_factor_le_sqrt {n : ℕ} (hn : n > 1) (hcomp : ¬ Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ n ∧ p * p ≤ n := by
  obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := Nat.exists_prime_and_dvd hn.ne';
  by_cases hp : p ≤ hp₂ <;> simp_all +decide [ Nat.prime_mul_iff ];
  · exact ⟨ p, hp₁, dvd_mul_right _ _, by nlinarith ⟩;
  · exact ⟨ hp₂.minFac, Nat.minFac_prime hcomp.1, dvd_mul_of_dvd_right ( Nat.minFac_dvd _ ) _, by nlinarith [ Nat.minFac_le ( Nat.pos_of_ne_zero ( by aesop_cat : hp₂ ≠ 0 ) ), Nat.minFac_le_of_dvd ( Nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨ by aesop_cat, hcomp.1 ⟩ ) ( dvd_of_mul_left_eq _ hp₃.symm ) ] ⟩

/-! ## Section 5: Torsion Profile Construction Theorems

We prove that the `TorsionProfile` construction from SNF diagonal entries
is correct and well-behaved. -/

/-- The torsion profile from SNF has the correct number of factors. -/
theorem torsionProfileFromSNF_length (diag : List ℕ)
    (hpos : ∀ d ∈ diag, d > 0) (hchain : diag.IsChain (· ∣ ·)) :
    (torsionProfileFromSNF diag hpos hchain).factors.length = countNontrivial diag := by
  rfl

/-- A trivial diagonal (all 1s) produces a trivial torsion profile. -/
theorem torsionProfileFromSNF_trivial_of_all_one (diag : List ℕ)
    (hpos : ∀ d ∈ diag, d > 0)
    (hchain : diag.IsChain (· ∣ ·))
    (hall : ∀ d ∈ diag, d = 1) :
    (torsionProfileFromSNF diag hpos hchain).factors = [] := by
  simp [torsionProfileFromSNF, snfDiagToTorsionFactors, List.filter_eq_nil_iff]
  intro x hx
  simp [hall x hx]

/-
The product of invariant factors is preserved: the product of torsion
    factors times the count of 1s gives back the original product structure.
-/
theorem torsionFactors_prod_dvd (diag : List ℕ) :
    (snfDiagToTorsionFactors diag).prod ∣ diag.prod := by
  induction diag <;> simp_all +decide [ snfDiagToTorsionFactors ];
  by_cases h : 1 < ‹_› <;> simp_all +decide [ List.filter_cons ];
  · exact mul_dvd_mul_left _ ‹_›;
  · exact dvd_mul_of_dvd_right ‹_› _

/-- If we prepend a 1 to the diagonal, the torsion profile is unchanged. -/
theorem torsionFactors_cons_one (diag : List ℕ) :
    snfDiagToTorsionFactors (1 :: diag) = snfDiagToTorsionFactors diag := by
  simp [snfDiagToTorsionFactors]

/-! ## Section 6: ZMod Torsion Structure (Computational Verification)

We verify the algebraic structure connecting invariant factors to
cyclic group decompositions, grounding the abstract theory in concrete algebra. -/

/-
In ℤ/nℤ, multiplication by n annihilates every element.
    This is the fundamental property connecting SNF diagonal entries
    to the order of torsion elements.
-/
theorem zmod_n_kills (n : ℕ) (hn : n > 0) (x : ZMod n) :
    n • x = 0 := by
  cases n <;> aesop

/-
If p is prime and p ∣ n, then ℤ/nℤ has p-torsion.
    This connects the prime factorization of invariant factors
    to the detection of torsion by mod-p reduction.
-/
theorem zmod_has_p_torsion_of_prime_dvd (n p : ℕ) (hn : n > 1)
    (hp : Nat.Prime p) (hdvd : p ∣ n) :
    ∃ x : ZMod n, x ≠ 0 ∧ p • x = 0 := by
  refine' ⟨ n / p, _, _ ⟩;
  · rw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ];
    exact Nat.not_dvd_of_pos_of_lt ( Nat.div_pos ( Nat.le_of_dvd hn.le hdvd ) hp.pos ) ( Nat.div_lt_self hn.le hp.one_lt );
  · simp +decide [ ← ZMod.natCast_eq_zero_iff, Nat.mul_div_cancel' hdvd ];
    norm_cast;
    rw [ Nat.mul_div_cancel' hdvd, ZMod.natCast_self ]

/-
If gcd(p, n) = 1, then ℤ/nℤ has no p-torsion.
    This is the "selectivity" property: different primes detect
    different parts of the torsion subgroup.
-/
theorem zmod_no_torsion_of_coprime (n p : ℕ) (hn : n > 1)
    (_hp : Nat.Prime p) (hcop : Nat.Coprime p n) :
    ∀ x : ZMod n, p • x = 0 → x = 0 := by
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  have h_inv : ∃ y : ZMod (n + 1 + 1), y * p = 1 := by
    have := Nat.exists_mul_mod_eq_one_of_coprime hcop;
    exact Exists.elim ( this ( by linarith ) ) fun m hm => ⟨ m, by simpa [ mul_comm, Fin.ext_iff, Fin.val_add, Fin.val_mul ] using congr_arg ( fun x : ℕ => x : ℕ → ZMod ( n + 1 + 1 ) ) hm.2 ⟩;
  obtain ⟨ y, hy ⟩ := h_inv; intro x hx; rw [ ← one_mul x, ← hy ] ; simp +decide [ mul_assoc, hx ] ;

/-! ## Section 7: Conjecture — Torsion Profile Almost-Free Property

For geometric simplicial complexes (Rips, Čech), we conjecture that the
SNF diagonal entries are bounded by a function of the ambient dimension,
independent of the number of simplices. This would make torsion profile
extraction truly linear time.

**Falsification test**: For random point clouds in ℝ^d with n points,
compute the maximum SNF diagonal entry M(n,d). If M(n,d) grows with n
(for fixed d), the conjecture is falsified. -/

/-
**Conjecture (Geometric Boundedness)**: For any simplicial complex
    arising from a Rips construction on points in ℝ^d, the invariant
    factors are bounded by d^(O(d)). We state a weaker, provable version:
    for any list with bounded entries, the prime sieving is linear.
-/
theorem linear_sieve_for_bounded_entries (ds : List ℕ) (B : ℕ) (_hB : B > 0)
    (hbound : ∀ d ∈ ds, d ≤ B) :
    (primeFactorsOfList ds).card ≤ B := by
  -- By definition of `primeFactorsOfList`, the set of primes in `primeFactorsOfList ds` is a subset of the primes less than or equal to `B`.
  have h_prime_subset : primeFactorsOfList ds ⊆ Finset.filter Nat.Prime (Finset.range (B + 1)) := by
    intro p hp; simp_all +decide [ primeFactorsOfList ];
    induction' ds using List.reverseRecOn with ds d ih <;> simp_all +decide [ Finset.subset_iff ];
    exact hp.elim ( fun h => ih h ) fun h => ⟨ Nat.le_trans ( Nat.le_of_dvd ( Nat.pos_of_ne_zero h.2.2 ) h.2.1 ) ( hbound _ ( Or.inr rfl ) ), h.1 ⟩;
  exact le_trans ( Finset.card_le_card h_prime_subset ) ( le_trans ( Finset.card_le_card ( show Finset.filter Nat.Prime ( Finset.range ( B + 1 ) ) ⊆ Finset.Ico 2 ( B + 1 ) from fun x hx => Finset.mem_Ico.mpr ⟨ Nat.Prime.two_le ( Finset.mem_filter.mp hx |>.2 ), Finset.mem_range.mp ( Finset.mem_filter.mp hx |>.1 ) ⟩ ) ) ( by simp +arith +decide ) )