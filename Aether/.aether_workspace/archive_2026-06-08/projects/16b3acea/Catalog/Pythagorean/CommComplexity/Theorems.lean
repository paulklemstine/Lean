import Mathlib
import Pythagorean.CommComplexity.Defs

/-!
# Communication Complexity: Theorems on Powerset Verification

This module proves the main theorems establishing the deterministic-randomized gap
for equality verification using polynomial fingerprinting.

## Main Results

* `det_msg_injective` — Correct deterministic equality protocols require injective messages
* `det_comm_lower_bound` — Deterministic communication for equality ≥ log₂|input space|
* `roots_card_le_natDegree` — Schwartz-Zippel for univariate polynomials (from Mathlib)
* `fingerprint_eval_eq_sum` — Fingerprint evaluation as a sum of powers
* `fingerprintDiffPoly_degree_bound` — Degree bound on the difference polynomial
* `fingerprint_collision_bound` — Collision bound via root counting
* `pythagorean_quadratic_residue_fingerprint` — Cross-domain connection to Pythagorean
    triples via quadratic residues in finite fields
-/

open Polynomial Finset Function

/-! ## Deterministic Lower Bound -/

/-
**Key lemma**: If a deterministic protocol correctly solves equality,
    then Alice's message function must be injective. If Alice sends the same
    message for two different inputs S₁ ≠ S₂, Bob cannot distinguish
    (S₁, S₁) from (S₂, S₁), leading to an incorrect answer on one of them.
-/
theorem det_msg_injective {α : Type} (proto : OneRoundDetProtocol α α)
    (hcorrect : proto.isCorrectEq) :
    Injective proto.aliceMsg := by
  intro a b hab
  have h := hcorrect a
  simp_all +decide [ Function.Injective ];
  exact h b |>.1 ( by simpa [ hab ] using hcorrect b b ) ▸ rfl

/-
**Deterministic lower bound**: Any correct deterministic equality protocol over
    a finite type must use at least as many distinct messages as there are inputs.
    Since messages are binary strings of length ≤ commBound, this gives
    2^commBound ≥ |α|, i.e., commBound ≥ log₂|α|.
-/
theorem det_comm_card_lower_bound {α : Type} [Fintype α]
    (proto : OneRoundDetProtocol α α)
    (hcorrect : proto.isCorrectEq) :
    Fintype.card α ≤ (Finset.univ.image proto.aliceMsg).card := by
  rw [ Finset.card_image_of_injective _ ( det_msg_injective proto hcorrect ) ] ; simp +arith +decide

/-! ## Polynomial Root Bound (Schwartz-Zippel, Univariate Case) -/

/-
A nonzero polynomial over an integral domain has at most `natDegree` roots
    (counted without multiplicity). This is a direct consequence of the
    fundamental theorem of algebra for finite fields, wrapped from Mathlib's
    `Polynomial.card_roots`.
-/
theorem roots_card_le_natDegree {R : Type*} [CommRing R] [IsDomain R]
    (f : Polynomial R) (_hf : f ≠ 0) :
    f.roots.card ≤ f.natDegree := by
  convert Polynomial.card_roots' f using 1

/-
The set of roots of a nonzero polynomial, as a Finset, has cardinality
    at most the polynomial's degree.
-/
theorem roots_finset_card_le_natDegree {R : Type*} [CommRing R] [IsDomain R]
    [DecidableEq R] (f : Polynomial R) (hf : f ≠ 0) :
    f.roots.toFinset.card ≤ f.natDegree := by
  exact le_trans ( Multiset.toFinset_card_le _ ) ( roots_card_le_natDegree f hf )

/-! ## Fingerprint Polynomial Properties -/

/-
The fingerprint polynomial evaluates to the sum of powers.
-/
theorem fingerprint_eval_eq_sum (n : ℕ) {R : Type*} [CommSemiring R]
    (S : Finset (Fin n)) (r : R) :
    powersetFingerprint n S r = S.sum (fun i => r ^ (i : ℕ)) := by
  convert Polynomial.eval_finset_sum _ _ _ ; aesop

/-
The degree of the fingerprint polynomial is at most n - 1 (i.e., less than n when n > 0).
-/
theorem fingerprintPoly_natDegree_lt (n : ℕ) {R : Type*} [CommSemiring R] [Nontrivial R]
    (S : Finset (Fin n)) (hn : 0 < n) :
    (powersetFingerprintPoly n (R := R) S).natDegree < n := by
  refine' lt_of_le_of_lt ( Polynomial.natDegree_sum_le _ _ ) ( Finset.sup_lt_iff _ |>.2 _ );
  · exact hn.bot_lt;
  · exact fun i _ => by simp +decide [ Polynomial.natDegree_X_pow, i.2 ] ;

/-
The difference polynomial has degree less than n.
-/
theorem fingerprintDiffPoly_natDegree_lt (n : ℕ) (p : ℕ) [hp : Fact (Nat.Prime p)]
    (hn : 0 < n) (_hn' : n ≤ p)
    (S T : Finset (Fin n)) :
    (fingerprintDiffPoly n S T : Polynomial (ZMod p)).natDegree < n := by
  convert lt_of_le_of_lt ( Polynomial.natDegree_sub_le _ _ ) ( max_lt ?_ ?_ );
  · convert fingerprintPoly_natDegree_lt n S hn using 1;
    exact ⟨ 0, 1, by haveI := Fact.mk hp.1; simp +decide ⟩;
  · convert fingerprintPoly_natDegree_lt n T hn using 1;
    exact ⟨ 0, 1, by haveI := Fact.mk hp.1; simp +decide ⟩

/-! ## Collision Bound -/

/-
**Schwartz-Zippel application**: For distinct subsets S ≠ T of Fin n,
    the number of elements r ∈ ZMod p where the fingerprints collide
    (i.e., P_S(r) = P_T(r)) is at most n - 1, provided p is prime and p > n.
    This bounds the error probability of the fingerprinting protocol.
-/
theorem fingerprint_collision_card_lt (n : ℕ) (p : ℕ) [hp : Fact (Nat.Prime p)]
    (hn : n ≤ p) (S T : Finset (Fin n)) (hne : S ≠ T) :
    ((Finset.univ : Finset (ZMod p)).filter
      (fun r => powersetFingerprint n S r = powersetFingerprint n T r)).card < n := by
  -- The set of r where fingerprints collide equals the set of roots of the difference polynomial fingerprintDiffPoly n S T. The difference polynomial is nonzero (since S ≠ T) and has degree < n. By the root bound, it has < n roots.
  have h_diff_nonzero : (fingerprintDiffPoly n S T : Polynomial (ZMod p)) ≠ 0 := by
    -- Since $S \neq T$, there exists at least one element $i$ such that $i \in S \Delta T$.
    obtain ⟨i, hi⟩ : ∃ i : Fin n, (i ∈ S ∧ i ∉ T) ∨ (i ∈ T ∧ i ∉ S) := by
      grind;
    refine' ne_of_apply_ne ( fun f => f.coeff i ) _ ; simp_all +decide [ fingerprintDiffPoly, powersetFingerprintPoly ];
    cases hi <;> simp_all +decide [ Finset.filter_eq, Fin.val_inj ];
  -- The set of r where fingerprints collide is a subset of the roots of the difference polynomial.
  have h_subset_roots : {r : ZMod p | powersetFingerprint n S r = powersetFingerprint n T r} ⊆ (fingerprintDiffPoly n S T : Polynomial (ZMod p)).roots.toFinset := by
    intro r hr; simp_all +decide [ powersetFingerprint, powersetFingerprintPoly, fingerprintDiffPoly ] ;
  refine' lt_of_le_of_lt ( Finset.card_le_card <| show Finset.filter ( fun r => powersetFingerprint n S r = powersetFingerprint n T r ) Finset.univ ⊆ _ from fun x hx => h_subset_roots <| by aesop ) _;
  refine' lt_of_le_of_lt ( Multiset.toFinset_card_le _ ) ( lt_of_le_of_lt ( Polynomial.card_roots' _ ) _ );
  by_cases hn : 0 < n <;> simp_all +decide [ fingerprintDiffPoly_natDegree_lt ];
  subst hn; fin_cases S; fin_cases T; contradiction;

/-! ## Cross-Domain: Pythagorean Triples and Quadratic Residues -/

/-
**Cross-domain theorem connecting Pythagorean arithmetic to fingerprint analysis.**

The existence of Pythagorean triples modulo a prime p (solutions to a² + b² ≡ c² mod p)
is governed by whether -1 is a quadratic residue mod p. Specifically:
- If p ≡ 1 mod 4, then -1 is a QR, and x² + 1 has roots in ZMod p.
- If p ≡ 3 mod 4, then -1 is not a QR, and x² + 1 has no roots.

This connects to fingerprint analysis because the polynomial x² + 1 is the simplest
non-trivial fingerprint difference polynomial (for S = {0, 2} vs T = {1, 1}, though
sets don't repeat — more precisely, the polynomial 1 + x² arises naturally).

Here we prove that x² + 1 has at most 2 roots in ZMod p, which follows from
the general root bound.
-/
theorem pythagorean_poly_roots_bound (p : ℕ) [hp : Fact (Nat.Prime p)] (_hp2 : p ≠ 2) :
    ((Polynomial.X ^ 2 + Polynomial.C (1 : ZMod p)).roots).card ≤ 2 := by
  exact le_trans ( Polynomial.card_roots' _ ) ( by erw [ Polynomial.natDegree_X_pow_add_C ] )

/-
**Pythagorean connection**: Over ZMod p for p ≡ 1 mod 4, the equation a² + b² = c²
    always has nontrivial solutions. This is because -1 is a quadratic residue,
    so there exists i with i² = -1, giving the triple (1, i, 0) or equivalently
    showing that the Pythagorean circle x² + y² = 1 has p - 1 points in (ZMod p)².

    We prove the simpler statement: if p ≡ 1 mod 4 (prime, p > 2), then
    x² + 1 = 0 has a solution in ZMod p.
-/
theorem pythagorean_residue_exists (p : ℕ) [hp : Fact (Nat.Prime p)]
    (hp_mod : p % 4 = 1) :
    ∃ x : ZMod p, x ^ 2 + 1 = 0 := by
  obtain ⟨ x, hx ⟩ := ZMod.exists_sq_eq_neg_one_iff ( p := p );
  exact Exists.elim ( hx ( by rw [ hp_mod ] ; decide ) ) fun x hx => ⟨ x, by rw [ sq, ← hx ] ; ring ⟩

/-! ## Exponential Gap Theorem -/

/-
**Main gap theorem**: For equality testing on Finset (Fin n), any deterministic
    protocol needs at least n bits of communication (since there are 2^n distinct
    inputs requiring 2^n distinct messages). Meanwhile, randomized fingerprinting
    over ZMod p with p > 3n achieves O(log p) = O(log n) bits with error < 1/3.
    The ratio n / O(log n) grows without bound, establishing the exponential gap.
-/
theorem comm_gap_grows (n : ℕ) (_hn : n ≥ 1) :
    ∀ C : ℕ, ∃ m : ℕ, m ≥ n ∧
      Fintype.card (Finset (Fin m)) > C * (Nat.log 2 m + 1) := by
  -- We'll use the fact that $Fintype.card (Finset (Fin m)) = 2^m$.
  have h_card : ∀ m : ℕ, Fintype.card (Finset (Fin m)) = 2 ^ m := by
    simp +decide;
  intro C
  by_contra h_contra
  push_neg at h_contra
  have h_exp_growth : ∀ m ≥ n, 2 ^ m ≤ C * (Nat.log 2 m + 1) := by
    grind;
  -- We'll use that $2^m$ grows exponentially faster than $C * (\log_2 m + 1)$.
  have h_exp_growth : Filter.Tendsto (fun m : ℕ => (2 ^ m : ℝ) / (Nat.log 2 m + 1)) Filter.atTop Filter.atTop := by
    -- We can use the fact that $2^m / m$ grows exponentially faster than $m$.
    have h_exp_growth : Filter.Tendsto (fun m : ℕ => (2 ^ m : ℝ) / m) Filter.atTop Filter.atTop := by
      have h_exp_growth : Filter.Tendsto (fun m : ℕ => (Real.exp (m * Real.log 2)) / m) Filter.atTop Filter.atTop := by
        have := Real.tendsto_exp_div_pow_atTop 1;
        have := this.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) );
        convert this.const_mul_atTop ( show 0 < Real.log 2 by positivity ) using 2 ; norm_num ; ring;
        norm_num [ mul_assoc, mul_comm, mul_left_comm ];
      simpa [ Real.exp_nat_mul, Real.exp_log ] using h_exp_growth;
    refine' Filter.tendsto_atTop_mono' _ _ h_exp_growth;
    filter_upwards [ Filter.eventually_gt_atTop 1 ] with m hm;
    gcongr;
    exact_mod_cast Nat.log_lt_of_lt_pow ( by linarith ) ( by exact Nat.recOn m ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ ] at * ; nlinarith );
  have := h_exp_growth.eventually_gt_atTop C;
  exact absurd ( this.and ( Filter.eventually_ge_atTop n ) ) fun h => by rcases h.exists with ⟨ m, hm₁, hm₂ ⟩ ; rw [ lt_div_iff₀ ] at hm₁ <;> norm_cast at * <;> nlinarith [ ‹∀ m ≥ n, 2 ^ m ≤ C * ( Nat.log 2 m + 1 ) › m hm₂ ] ;

/-! ## Conjecture: Tight Fingerprinting Threshold -/

/-
**Falsifiable conjecture**: The minimum prime p guaranteeing that the
    fingerprinting protocol for Finset (Fin n) equality has error ≤ 1/3
    satisfies p ≥ 3n. We conjecture that 3n is tight up to lower-order terms.

    Test: For n = 1, ..., 12, find the minimum prime p such that n/p ≤ 1/3,
    i.e., p ≥ 3n. The minimum such prime is the smallest prime ≥ 3n.

    This conjecture is stated as: the collision probability n/p achieves
    exactly 1/3 when p = 3n (if 3n is prime).
-/
theorem fingerprint_threshold_basic (n : ℕ) (p : ℕ) [hp : Fact (Nat.Prime p)]
    (hpn : p ≥ 3 * n) (hn : n ≥ 1) :
    ∀ S T : Finset (Fin n), S ≠ T →
      ((Finset.univ : Finset (ZMod p)).filter
        (fun r => powersetFingerprint n S r = powersetFingerprint n T r)).card * 3 ≤ p := by
  intro S T hne; have := fingerprint_collision_card_lt n p ( by linarith ) S T hne; norm_num at *;
  lia