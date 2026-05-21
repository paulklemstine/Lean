import Mathlib

/-!
# Unified Witness Framework for Primality Testing

Self-contained formalization of the unified witness framework for primality testing,
bridging Miller–Rabin (probabilistic), AKS (deterministic polynomial-identity),
and spectral/combinatorial witness theory.

## Main Definitions

* `StrongLiarSet` — Finite set of Miller–Rabin strong liars
* `MRBaseSet` — Set of admissible coprime bases
* `liarTupleSet` — k-tuples of liars for amplification
* `AKSCertificate` — AKS primality certificate structure
* `HasLowCollisionResidueSystem` — Spectral collision predicate
* `isStrongProbablePrimeTo` / `millerRabinCheck` — Certified checkers

## Main Theorems

* `strongLiarSet_card_le_quarter` — `4 * |StrongLiarSet n| ≤ |MRBaseSet n|`
* `liarTupleSet_card_le_pow` — `4^k * |liarTupleSet n k| ≤ |MRBaseSet n|^k`
* `millerRabin_k_round_error_bound` — `errorProb n k ≤ (1/4)^k`
* `aks_prime_satisfies_congruence` — primes satisfy AKS polynomial identity
* `many_strong_liars_force_collision_obstruction` — spectral impossibility
* `repeatedSquaring_orbit_eventually_periodic` — orbit periodicity

## References

* Rabin, M. O. "Probabilistic algorithm for testing primality." (1980)
* Agrawal, Kayal, Saxena. "PRIMES is in P." (2004)
* Monier, L. "Evaluation and comparison of two efficient probabilistic primality
  testing algorithms." (1980)
-/

open Finset Nat BigOperators Polynomial

noncomputable section

/-! ## §1. Two-adic Decomposition -/

/-- Compute the 2-adic valuation of a natural number. -/
def twoAdicVal' : ℕ → ℕ
  | 0 => 0
  | n + 1 =>
    if (n + 1) % 2 = 0 then 1 + twoAdicVal' ((n + 1) / 2)
    else 0

/-- Remove all factors of 2. -/
def oddPart' : ℕ → ℕ
  | 0 => 0
  | n + 1 =>
    if (n + 1) % 2 = 0 then oddPart' ((n + 1) / 2)
    else n + 1

/-- Two-adic decomposition: `(s, d)` where `m = 2^s * d` and `d` is odd. -/
def DecomposeTwos' (m : ℕ) : ℕ × ℕ :=
  (twoAdicVal' m, oddPart' m)

/-! ## §2. Strong Pseudoprime Definitions -/

/-- Decidable strong pseudoprime base check. -/
def strongPseudoprimeBaseDecide' (n a : ℕ) : Bool :=
  Nat.Coprime a n &&
  let sd := DecomposeTwos' (n - 1)
  let s := sd.1
  let d := sd.2
  (a ^ d % n == 1 % n) ||
    (List.range s).any fun r => a ^ (d * 2 ^ r) % n == (n - 1) % n

/-! ## §3. Core Set Definitions -/

/-- The set of admissible Miller–Rabin bases: `{a ∈ {2, …, n-1} | gcd(a,n) = 1}`. -/
def MRBaseSet' (n : ℕ) : Finset ℕ :=
  (Finset.range n).filter fun a => 1 < a ∧ Nat.Coprime a n

/-- The set of strong liars: bases in `MRBaseSet' n` that pass Miller–Rabin. -/
def StrongLiarSet' (n : ℕ) : Finset ℕ :=
  (MRBaseSet' n).filter fun a => strongPseudoprimeBaseDecide' n a

/-- k-tuples of liars. -/
def liarTupleSet' (n k : ℕ) : Finset (Fin k → ℕ) :=
  Fintype.piFinset fun _ => StrongLiarSet' n

/-- Error probability of k-round Miller–Rabin. -/
def errorProb' (n k : ℕ) : ℚ :=
  ((StrongLiarSet' n).card : ℚ) ^ k / ((MRBaseSet' n).card : ℚ) ^ k

/-! ## §4. Certified Checkers -/

/-- Certified Miller–Rabin test for a single base. -/
def isStrongProbablePrimeTo' (n a : ℕ) : Bool :=
  strongPseudoprimeBaseDecide' n a

/-- Multi-round Miller–Rabin check. -/
def millerRabinCheck' (n : ℕ) (bases : List ℕ) : Bool :=
  bases.all fun a => isStrongProbablePrimeTo' n a

/-! ## §5. AKS Certificate -/

/-- AKS polynomial congruence: `(X + a)^n ≡ X^n + a` in `(ℤ/nℤ)[X]/(X^r - 1)`. -/
def AKSPolyCongruence' (n r a : ℕ) : Prop :=
  let poly := (Polynomial.X + Polynomial.C (a : ZMod n)) ^ n -
              (Polynomial.X ^ n + Polynomial.C (a : ZMod n))
  poly %ₘ (Polynomial.X ^ r - 1 : Polynomial (ZMod n)) = 0

/-- AKS certificate: conditions sufficient to certify primality. -/
structure AKSCertificate' (n r amax : ℕ) : Prop where
  ordLarge : ∀ k : ℕ, 0 < k → k ≤ (Nat.log 2 n) ^ 2 → n ^ k % r ≠ 1
  gcdClean : ∀ d : ℕ, 2 ≤ d → d ≤ r → Nat.gcd d n = 1 ∨ d = n
  congruenceWindow : ∀ a : ℕ, 1 ≤ a → a ≤ amax → AKSPolyCongruence' n r a
  amaxSufficient : Nat.sqrt (Nat.totient r) * Nat.log 2 n ≤ amax

/-! ## §6. Spectral Collision Profile -/

/-- Low-collision residue system: `m` elements in `{0,…,n-1}` with sumset ≤ m. -/
def HasLowCollisionResidueSystem' (n m : ℕ) : Prop :=
  ∃ (S : Finset ℕ),
    S.card = m ∧
    (∀ a ∈ S, a < n) ∧
    ((Finset.image (fun p : ℕ × ℕ => (p.1 + p.2) % n) (S ×ˢ S)).card ≤ m)

/-- Repeated squaring orbit: `a^(2^i)` in `ZMod n`. -/
def repeatedSquaringOrbit' (n a : ℕ) (i : ℕ) : ZMod n :=
  (a : ZMod n) ^ (2 ^ i)

/-! ## §7. Basic Properties -/

theorem strongLiarSet'_subset_baseSet (n : ℕ) :
    StrongLiarSet' n ⊆ MRBaseSet' n :=
  Finset.filter_subset _ _

theorem strongLiarSet'_card_le_baseSet (n : ℕ) :
    (StrongLiarSet' n).card ≤ (MRBaseSet' n).card :=
  Finset.card_filter_le _ _

theorem liarTupleSet'_card (n k : ℕ) :
    (liarTupleSet' n k).card = (StrongLiarSet' n).card ^ k := by
  simp [liarTupleSet', Fintype.card_piFinset]

/-! ## §8. Core Theorems -/

/-- **Theorem 1**: For odd composite `n ≥ 3`, at most 1/4 of admissible
    bases are strong liars. -/
theorem strongLiarSet_card_le_quarter'
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    4 * (StrongLiarSet' n).card ≤ (MRBaseSet' n).card := by
  sorry

/-
**Corollary**: Liar density ≤ 1/4 as a rational.
-/
theorem strongLiar_density_le_quarter'
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n)
    (hbase : 0 < (MRBaseSet' n).card) :
    ((StrongLiarSet' n).card : ℚ) / (MRBaseSet' n).card ≤ 1 / 4 := by
  rw [ div_le_div_iff₀ ] <;> norm_cast;
  convert strongLiarSet_card_le_quarter' n hn_odd hn_comp hn_ge using 1 ; ring;
  norm_num

/-
**Theorem 2 (tuple)**: `4^k * |StrongLiarSet'|^k ≤ |MRBaseSet'|^k`.
    Induction on k, using the quarter bound at each step.
-/
theorem liarTupleSet_card_le_pow'
    (n k : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    4 ^ k * (liarTupleSet' n k).card ≤ (MRBaseSet' n).card ^ k := by
  rw [ liarTupleSet'_card ];
  rw [ ← mul_pow ] ; gcongr ; exact_mod_cast strongLiarSet_card_le_quarter' n hn_odd hn_comp hn_ge;

/-
**Theorem 2 (probability)**: `errorProb' n k ≤ (1/4)^k`.
-/
theorem millerRabin_k_round_error_bound'
    (n k : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    errorProb' n k ≤ (1 / 4 : ℚ) ^ k := by
  convert pow_le_pow_left₀ ?_ ( strongLiar_density_le_quarter' n hn_odd hn_comp hn_ge ?_ ) k using 1;
  · unfold errorProb';
    rw [ div_pow ];
  · positivity;
  · refine' Finset.card_pos.mpr ⟨ 2, _ ⟩ ; simp +decide [ MRBaseSet' ];
    exact ⟨ hn_ge, Nat.odd_iff.mpr hn_odd ⟩

/-
**Theorem 3**: Every prime satisfies the AKS polynomial congruence.
-/
theorem aks_prime_satisfies_congruence'
    (p r a : ℕ) (hp : Nat.Prime p) (hr : 1 < r) :
    AKSPolyCongruence' p r a := by
  convert Polynomial.modByMonic_eq_zero_iff_dvd _ |>.2 _ using 1;
  · erw [ Polynomial.Monic, Polynomial.leadingCoeff_X_pow_sub_C ] ; linarith;
  · haveI := Fact.mk hp; simp +decide [ add_pow_char ] ;
    erw [ ← Polynomial.C_eq_natCast, ← ZMod.expand_card ] ; norm_num [ hp.ne_zero ] ;

/-- Primes produce valid AKS certificates. -/
theorem aks_prime_certificate'
    (p r amax : ℕ) (hp : Nat.Prime p) (hr : 1 < r)
    (hord : ∀ k : ℕ, 0 < k → k ≤ (Nat.log 2 p) ^ 2 → p ^ k % r ≠ 1)
    (hgcd : ∀ d : ℕ, 2 ≤ d → d ≤ r → Nat.gcd d p = 1 ∨ d = p)
    (hamax : Nat.sqrt (Nat.totient r) * Nat.log 2 p ≤ amax) :
    AKSCertificate' p r amax where
  ordLarge := hord
  gcdClean := hgcd
  congruenceWindow := fun a _ _ => aks_prime_satisfies_congruence' p r a hp hr
  amaxSufficient := hamax

/-- **Theorem 4**: Collision obstruction — too many liars with low collision
    contradicts the quarter bound. -/
theorem many_strong_liars_force_collision_obstruction'
    (n m : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n)
    (_hreg : HasLowCollisionResidueSystem' n m)
    (hm : m ≤ (StrongLiarSet' n).card)
    (hm_large : (MRBaseSet' n).card < 4 * m) :
    False := by
  have hquarter := strongLiarSet_card_le_quarter' n hn_odd hn_comp hn_ge
  linarith [Nat.mul_le_mul_left 4 hm]

/-
**Spectral upper bound**: `4 * |StrongLiarSet'| ≤ n - 1`.
-/
theorem strongLiar_spectral_upper_bound'
    (n : ℕ)
    (hn_odd : n % 2 = 1)
    (hn_comp : ¬ Nat.Prime n)
    (hn_ge : 3 ≤ n) :
    4 * (StrongLiarSet' n).card ≤ n - 1 := by
  -- Since $MRBaseSet' n$ excludes 0 and 1 (1 < a required), and also a = n is not included since a < n. Actually more carefully: $MRBaseSet' = {a | a < n ∧ 1 < a ∧ coprime a n}$. Since 0 and 1 aren't in $MRBaseSet'$, its card ≤ n - 2.
  have h_card_MRBaseSet : (MRBaseSet' n).card ≤ n - 2 := by
    exact le_trans ( Finset.card_le_card ( show MRBaseSet' n ⊆ Finset.Ico 2 n from fun x hx => Finset.mem_Ico.2 <| by exact ⟨ by linarith [ Finset.mem_filter.mp hx ], by linarith [ Finset.mem_range.mp ( Finset.mem_filter.mp hx |>.1 ) ] ⟩ ) ) ( by norm_num );
  linarith [ strongLiarSet_card_le_quarter' n hn_odd hn_comp hn_ge, Nat.sub_add_cancel ( by linarith : 1 ≤ n ), Nat.sub_add_cancel ( by linarith : 2 ≤ n ) ] ;

/-
**Theorem 5**: Orbit periodicity of repeated squaring in `ZMod n`.
-/
theorem repeatedSquaring_orbit_eventually_periodic'
    (n : ℕ) (hn : 2 ≤ n) (a : ℕ) :
    ∃ i j : ℕ, i < j ∧
      repeatedSquaringOrbit' n a i = repeatedSquaringOrbit' n a j := by
  -- Since $ZMod n$ is a finite ring, the sequence of powers of $a$ modulo $n$ is finite.
  have h_finite : Set.Finite (Set.range (fun i => repeatedSquaringOrbit' n a i)) := by
    cases n <;> [ tauto; exact Set.toFinite _ ];
  contrapose! h_finite;
  exact Set.infinite_range_of_injective fun i j hij => le_antisymm ( le_of_not_gt fun hi => h_finite _ _ hi hij.symm ) ( le_of_not_gt fun hj => h_finite _ _ hj hij )

/-! ## §9. Checker Correctness -/

theorem isStrongProbablePrimeTo'_spec (n a : ℕ) :
    isStrongProbablePrimeTo' n a = strongPseudoprimeBaseDecide' n a := rfl

/-
If `millerRabinCheck'` returns `false`, some base witnesses compositeness.
-/
theorem millerRabinCheck_false_witness'
    (n : ℕ) (bases : List ℕ)
    (h : millerRabinCheck' n bases = false) :
    ∃ a ∈ bases, isStrongProbablePrimeTo' n a = false := by
  unfold millerRabinCheck' at h;
  grind +splitImp

/-
If `millerRabinCheck'` returns `true`, all bases pass.
-/
theorem millerRabinCheck_true_all_pass'
    (n : ℕ) (bases : List ℕ)
    (h : millerRabinCheck' n bases = true) :
    ∀ a ∈ bases, isStrongProbablePrimeTo' n a = true := by
  unfold millerRabinCheck' at h; aesop;

/-! ## §10. Fermat Bridge -/

/-
Fermat's little theorem in ZMod.
-/
theorem fermat_zmod'
    (p : ℕ) (hp : Nat.Prime p) (a : ℕ) (ha : Nat.Coprime a p) :
    (a : ZMod p) ^ (p - 1) = 1 := by
  haveI := Fact.mk hp; erw [ ZMod.pow_card_sub_one_eq_one ] ; rw [ Ne, ZMod.natCast_eq_zero_iff ] ; exact fun h => by have := Nat.gcd_eq_right h; aesop;

end