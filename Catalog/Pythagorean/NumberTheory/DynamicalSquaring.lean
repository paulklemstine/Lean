import Mathlib

/-!
# Dynamical Systems Perspective on Repeated Squaring

The map f(x) = x² on ℤ/nℤ is a dynamical system whose fixed points are exactly the
idempotents of the ring. The number of idempotents equals 2^ω(n) where ω(n) counts
distinct prime factors. Primes have exactly 2 idempotents {0, 1}; composites with
≥ 2 distinct prime factors have nontrivial idempotents that encode the factorization.

## Main Results

* `prime_idempotent_trivial` — In ℤ/pℤ (p prime), every idempotent is 0 or 1.
* `squaring_fixed_iff_idempotent` — x is a fixed point of the squaring map iff x² = x.
* `nontrivial_idempotent_of_coprime_prod` — If n = m * k with coprime m, k > 1,
  there exists a nontrivial idempotent in ℤ/nℤ.
* `composite_has_nontrivial_idempotent` — Composites with ≥ 2 distinct prime factors
  have nontrivial idempotents.
* `prime_power_idempotent_trivial` — In ℤ/p^kℤ (p prime, k ≥ 1), idempotents are trivial.
-/

open Finset Nat BigOperators

noncomputable section

/-! ## §1. The Squaring Map and Fixed Points -/

/-- The squaring (repeated squaring) map on ℤ/nℤ. -/
def squaringMap (n : ℕ) : ZMod n → ZMod n := fun x => x * x

/-- The k-th iterate of the squaring map. -/
def squaringIterate (n : ℕ) : ℕ → ZMod n → ZMod n
  | 0, x => x
  | k + 1, x => squaringMap n (squaringIterate n k x)

/-- An element is idempotent if it equals its own square. -/
def IsIdempotent {n : ℕ} (x : ZMod n) : Prop := x * x = x

/-- The set of idempotents in ℤ/nℤ. -/
def idempotentSet (n : ℕ) [NeZero n] : Finset (ZMod n) :=
  Finset.univ.filter (fun x => x * x = x)

/-- A fixed point of the squaring map is exactly an idempotent. -/
theorem squaring_fixed_iff_idempotent {n : ℕ} (x : ZMod n) :
    squaringMap n x = x ↔ IsIdempotent x := by
  simp [squaringMap, IsIdempotent]

/-! ## §2. Idempotents in Prime Rings -/

/-
In ℤ/pℤ where p is prime, every idempotent is trivial (0 or 1).
    This follows from ℤ/pℤ being an integral domain: x(x-1) = 0 implies x = 0 or x = 1.
-/
theorem prime_idempotent_trivial (p : ℕ) (hp : Nat.Prime p) (x : ZMod p)
    (hx : x * x = x) : x = 0 ∨ x = 1 := by
  haveI := Fact.mk hp; exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ h <| by linear_combination hx;

/-
A prime ring has exactly two idempotents.
-/
theorem prime_idempotent_card (p : ℕ) (hp : Nat.Prime p) :
    haveI : NeZero p := ⟨hp.ne_zero⟩
    (idempotentSet p).card = 2 := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  convert Finset.card_eq_two.mpr _;
  infer_instance;
  refine' ⟨ 0, 1, _, _ ⟩ <;> simp_all +decide [ Finset.ext_iff, idempotentSet ];
  · haveI := Fact.mk hp; simp +decide ;
  · exact fun a => ⟨ fun ha => by haveI := Fact.mk hp; exact or_iff_not_imp_left.mpr fun ha' => mul_left_cancel₀ ha' <| by linear_combination' ha, fun ha => by rcases ha with ( rfl | rfl ) <;> simp +decide ⟩

/-! ## §3. Idempotents in Prime Power Rings -/

/-
In ℤ/p^kℤ where p is prime and k ≥ 1, every idempotent is trivial.
    In a local ring, the only idempotents are 0 and 1.
-/
theorem prime_power_idempotent_trivial (p k : ℕ) (hp : Nat.Prime p) (hk : k ≥ 1)
    (x : ZMod (p ^ k)) (hx : x * x = x) : x = 0 ∨ x = 1 := by
  -- Since $p$ is prime, $p^k$ is a prime power, and thus $\mathbb{Z}/p^k\mathbb{Z}$ is a local ring. The maximal ideal is $(p)$.
  have h_local : IsLocalRing (ZMod (p ^ k)) := by
    haveI : Fact ( Nat.Prime p ) := ⟨ hp ⟩;
    refine' { .. };
    · exact ⟨ 0, 1, by haveI := Fact.mk ( show 1 < p ^ k from one_lt_pow₀ hp.one_lt ( by linarith ) ) ; exact zero_ne_one ⟩;
    · intro a b hab
      have h_unit : IsUnit a ∨ IsUnit b := by
        have h_not_div : ¬(p ∣ a.val) ∨ ¬(p ∣ b.val) := by
          have h_not_div : ¬(p ∣ (a.val + b.val)) := by
            have h_not_div : (a.val + b.val) ≡ 1 [MOD p ^ k] := by
              simp +decide [ ← ZMod.natCast_eq_natCast_iff, hab ];
            rw [ Nat.dvd_iff_mod_eq_zero, h_not_div.of_dvd <| dvd_pow_self _ <| by linarith ] ; norm_num [ Nat.mod_eq_of_lt hp.two_le ];
          exact not_and_or.mp fun h => h_not_div <| dvd_add h.1 h.2
        have h_unit : ∀ {x : ZMod (p ^ k)}, ¬(p ∣ x.val) → IsUnit x := by
          intro x hx_not_div
          have h_coprime : Nat.gcd x.val (p ^ k) = 1 := by
            exact Nat.Coprime.pow_right _ ( Nat.Coprime.symm <| hp.coprime_iff_not_dvd.mpr hx_not_div );
          have h_unit : ∃ y : ℕ, x.val * y ≡ 1 [MOD p ^ k] := by
            have := Nat.exists_mul_mod_eq_one_of_coprime h_coprime;
            exact Exists.elim ( this ( one_lt_pow₀ hp.one_lt ( by linarith ) ) ) fun m hm => ⟨ m, by rw [ ← hm.2, Nat.ModEq, Nat.mod_mod ] ⟩;
          obtain ⟨ y, hy ⟩ := h_unit;
          rw [ isUnit_iff_exists_inv ];
          use y;
          simp_all +decide [ ← ZMod.natCast_eq_natCast_iff ];
        exact Or.imp ( h_unit ) ( h_unit ) h_not_div;
      exact h_unit;
  by_cases h : x = 0 <;> simp_all +decide [ mul_eq_zero, sub_eq_zero ];
  -- Since $x$ is a non-zero idempotent, it must be a unit.
  have h_unit : IsUnit x := by
    by_contra h_nonunit;
    have h_unit : IsUnit (1 - x) := by
      exact Classical.not_not.1 fun h => h_nonunit <| by have := h_local.isUnit_or_isUnit_of_add_one ( show x + ( 1 - x ) = 1 by ring ) ; aesop;
    cases' h_unit.exists_left_inv with y hy; replace hy := congr_arg ( fun z => z * x ) hy; simp_all +decide [ mul_assoc, sub_mul ] ;
  exact h_unit.mul_left_inj.mp ( by aesop )

/-! ## §4. Nontrivial Idempotents from CRT -/

/-
The CRT isomorphism preserves the squaring map: it is equivariant.
-/
theorem crt_squaring_equivariant {m k : ℕ} (hcop : Nat.Coprime m k)
    (x : ZMod (m * k)) :
    (ZMod.chineseRemainder hcop) (squaringMap (m * k) x) =
    (squaringMap m ((ZMod.chineseRemainder hcop x).1),
     squaringMap k ((ZMod.chineseRemainder hcop x).2)) := by
  convert RingEquiv.map_mul ( ZMod.chineseRemainder hcop ) x x using 1

/-
If n = m * k with coprime m, k both > 1, then ℤ/nℤ has a nontrivial idempotent.
    The element corresponding to (1, 0) under CRT is idempotent but neither 0 nor 1.
-/
theorem nontrivial_idempotent_of_coprime_prod (m k : ℕ) (hm : 1 < m) (hk : 1 < k)
    (hcop : Nat.Coprime m k) :
    ∃ e : ZMod (m * k), e * e = e ∧ e ≠ 0 ∧ e ≠ 1 := by
  -- By the Chinese Remainder Theorem, there exists an element `e` in `ZMod (m * k)` such that `e ≡ 1 (mod m)` and `e ≡ 0 (mod k)`.
  obtain ⟨e, he⟩ : ∃ e : ZMod (m * k), (ZMod.chineseRemainder hcop e).1 = 1 ∧ (ZMod.chineseRemainder hcop e).2 = 0 := by
    exact ⟨ ZMod.chineseRemainder hcop |>.symm ( 1, 0 ), by simp +decide, by simp +decide ⟩;
  -- Show that `e` is indeed a nontrivial idempotent.
  have h_idempotent : e * e = e := by
    exact ( ZMod.chineseRemainder hcop ).injective <| by aesop;
  have h_ne_zero : e ≠ 0 := by
    intro h; have := he.1; simp_all +decide ;
    rcases m with ( _ | _ | m ) <;> rcases k with ( _ | _ | k ) <;> cases he ; contradiction;
    · contradiction;
    · contradiction
  have h_ne_one : e ≠ 1 := by
    intro h; simp_all +decide ;
    rcases m with ( _ | _ | m ) <;> rcases k with ( _ | _ | k ) <;> cases he <;> contradiction
  use e, h_idempotent, h_ne_zero, h_ne_one

/-! ## §5. Composite Detection via Idempotents -/

/-
Helper: a composite number that is not a prime power has at least two
    distinct prime factors, hence can be written as a product of two coprime factors > 1.
-/
theorem exists_coprime_factorization_of_not_prime_power (n : ℕ) (hn : n > 1)
    (hω : (Nat.factorization n).support.card ≥ 2) :
    ∃ m k, m > 1 ∧ k > 1 ∧ n = m * k ∧ Nat.Coprime m k := by
  -- Let $p$ be a prime factor of $n$.
  obtain ⟨p, hp⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ n := by
    exact Nat.exists_prime_and_dvd hn.ne';
  -- Let $a$ be the largest power of $p$ dividing $n$, and let $k = n / a$.
  obtain ⟨a, ha⟩ : ∃ a : ℕ, a > 0 ∧ p ^ a ∣ n ∧ ¬p ^ (a + 1) ∣ n := by
    exact ⟨ Nat.factorization n p, Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by aesop ) ), Nat.ordProj_dvd _ _, Nat.pow_succ_factorization_not_dvd hn.ne_bot hp.1 ⟩;
  -- Let $k$ be the quotient $k = n / p^a$.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, n = p ^ a * k ∧ Nat.Coprime (p ^ a) k := by
    exact ⟨ n / p ^ a, by rw [ Nat.mul_div_cancel' ha.2.1 ], Nat.Coprime.pow_left _ <| hp.1.coprime_iff_not_dvd.mpr fun h => ha.2.2 <| by convert Nat.mul_dvd_mul_left ( p ^ a ) h using 1; rw [ Nat.mul_div_cancel' ha.2.1 ] ⟩;
  refine' ⟨ p ^ a, k, _, _, hk.1, hk.2 ⟩ <;> contrapose! hω <;> simp_all +decide [ Nat.factorization_eq_zero_iff ];
  · exact absurd hω ( not_le_of_gt ( one_lt_pow₀ hp.1.one_lt ha.1.ne' ) );
  · interval_cases k <;> simp_all +decide [ Nat.primeFactors_mul, Nat.primeFactors_pow ];
    rw [ Nat.primeFactors_pow ] <;> aesop

/-
**Main Theorem**: A composite number with ≥ 2 distinct prime factors has a
    nontrivial idempotent in its residue ring. This is a dynamical signature of
    compositeness: the squaring map has extra fixed points beyond {0, 1}.
-/
theorem composite_has_nontrivial_idempotent (n : ℕ) (hn : n > 1)
    (hω : (Nat.factorization n).support.card ≥ 2) :
    ∃ e : ZMod n, e * e = e ∧ e ≠ 0 ∧ e ≠ 1 := by
  -- Apply the lemma `exists_coprime_factorization_of_not_prime_power` to get $m$ and $k$.
  obtain ⟨m, k, hm, hk, hn_eq, hcop⟩ : ∃ m k : ℕ, m > 1 ∧ k > 1 ∧ n = m * k ∧ Nat.Coprime m k := by
    exact?;
  obtain ⟨ e, he ⟩ := nontrivial_idempotent_of_coprime_prod m k hm hk hcop;
  subst hn_eq; exact ⟨ e, he ⟩ ;

/-! ## §6. Primality as a Dynamical Property -/

/-- Primes have exactly two fixed points of the squaring map.
    This is equivalent to saying the functional graph has no nontrivial attractors. -/
theorem prime_has_two_fixed_points (p : ℕ) (hp : Nat.Prime p) :
    haveI : NeZero p := ⟨hp.ne_zero⟩
    (idempotentSet p).card = 2 :=
  prime_idempotent_card p hp

/-
The dynamical characterization: if every idempotent is trivial and n > 1,
    then n must be a prime power. Contrapositively, multiple prime factors
    force nontrivial idempotents (extra attractors in the squaring dynamics).
-/
theorem nontrivial_idempotent_iff_multiple_prime_factors (n : ℕ) (hn : n > 1) :
    (∃ e : ZMod n, e * e = e ∧ e ≠ 0 ∧ e ≠ 1) ↔
    (Nat.factorization n).support.card ≥ 2 := by
  refine' ⟨ fun ⟨ e, he₁, he₂, he₃ ⟩ ↦ _, fun h ↦ _ ⟩;
  · by_contra h_contra;
    -- If the support of the factorization of $n$ has fewer than 2 elements, then $n$ must be a prime power.
    obtain ⟨p, k, hp, hk, rfl⟩ : ∃ p k : ℕ, Nat.Prime p ∧ k ≥ 1 ∧ n = p ^ k := by
      interval_cases _ : Finset.card n.factorization.support <;> simp_all +decide;
      · grind +revert;
      · rw [ Finset.card_eq_one ] at *;
        obtain ⟨ p, hp ⟩ := ‹_›; exact ⟨ p, Nat.prime_of_mem_primeFactors <| hp.symm ▸ Finset.mem_singleton_self _, n.factorization p, Nat.pos_of_ne_zero <| Finsupp.mem_support_iff.mp <| by aesop, by nth_rw 1 [ ← Nat.factorization_prod_pow_eq_self hn.ne_bot ] ; rw [ Finsupp.prod ] ; aesop ⟩ ;
    exact he₃ <| Or.resolve_left ( prime_power_idempotent_trivial p k hp hk e he₁ ) he₂;
  · convert composite_has_nontrivial_idempotent n hn h

end