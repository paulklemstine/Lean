import Mathlib

/-!
# Local-Global Bridge for Integer Vector Coprimality

This file formalizes the statement that **coprimality of an integer vector is a local
(per-prime) condition**, the foundational fact behind the Euler-product factorization of the
autocorrelation of simultaneously visible lattice points.

## Main definitions

* `VectorCoprimalityLocalGlobal.vecGcd w` : the (non-negative) gcd of all coordinates of an
  integer vector `w : Fin k → ℤ`.
* `VectorCoprimalityLocalGlobal.redMod p w` : the coordinatewise reduction of `w` modulo `p`.
* `VectorCoprimalityLocalGlobal.IsPrim x` : the coordinates of `x : Fin k → R` generate the unit
  ideal of the commutative ring `R` (a representation-independent primitivity condition).
* `VectorCoprimalityLocalGlobal.primDensity n k` : the density of primitive residue vectors in
  `(ZMod n) ^ k`.

## Main results

* `dvd_vecGcd_iff` (Theorem 1): `d ∣ vecGcd w ↔ ∀ i, d ∣ w i`.
* `redMod_eq_iff` (Theorem 2): `redMod p v = redMod p x ↔ (p : ℤ) ∣ vecGcd (v - x)`.
* `vecGcd_eq_one_iff` (Theorem 3, **the local-global bridge**):
  `vecGcd w = 1 ↔ ∀ p : ℕ, p.Prime → redMod p w ≠ 0`.
* `primDensity_mul` (corrected Theorem 4): for coprime `p q`,
  `primDensity (p*q) k = primDensity p k * primDensity q k`.

## Note on Theorem 4 of the research brief

The research brief proposed a "Theorem 4" of the form
`localDensity (p*q) S = localDensity p S * localDensity q S`, where
`localDensity p S = 1 - |redMod p '' S| / p^k`.  **This statement is false**: see
`localDensity_mul_counterexample` below, which exhibits `p = 2`, `q = 3`, `k = 1` and a two-point
set `S` for which the image cardinalities are all `2`, giving
`localDensity 6 S = 2/3 ≠ 0 = localDensity 2 S * localDensity 3 S`.
The image of a *fixed* finite set of integer vectors under reduction is not a CRT "product/cylinder"
set, so its cardinality is not multiplicative.

The multiplicativity that genuinely underlies the Euler product is the multiplicativity of the
**density of primitive residue vectors** (a Jordan-totient style quantity), captured here by
`primDensity_mul`.  The brief's definitions `redModFinset` and `localDensity` are retained (with the
counterexample proven) so that the record is complete.
-/

open Finset

namespace VectorCoprimalityLocalGlobal

/-! ## Definitions -/

/-- The gcd of all coordinates of an integer vector `w : Fin k → ℤ`.  Because `Finset.gcd` over `ℤ`
returns the normalized (non-negative) gcd, `vecGcd` is always non-negative and `vecGcd 0 = 0`. -/
def vecGcd {k : ℕ} (w : Fin k → ℤ) : ℤ := Finset.univ.gcd w

/-- Coordinatewise reduction of an integer vector modulo `p`. -/
def redMod (p : ℕ) {k : ℕ} (w : Fin k → ℤ) : Fin k → ZMod p := fun i => (w i : ZMod p)

/-! ## Basic properties of `vecGcd` -/

@[simp] theorem vecGcd_zero {k : ℕ} : vecGcd (0 : Fin k → ℤ) = 0 := by
  rw [vecGcd, Finset.gcd_eq_zero_iff]; intro x _; rfl

theorem vecGcd_nonneg {k : ℕ} (w : Fin k → ℤ) : 0 ≤ vecGcd w := by
  rw [vecGcd, ← Finset.normalize_gcd, ← Int.abs_eq_normalize]; exact abs_nonneg _

/-! ## Theorem 1 -/

/-- **Theorem 1.** An integer `d` divides the gcd of the coordinates of `w` iff it divides every
coordinate. -/
theorem dvd_vecGcd_iff {k : ℕ} (d : ℤ) (w : Fin k → ℤ) :
    d ∣ vecGcd w ↔ ∀ i, d ∣ w i := by
  rw [vecGcd, Finset.dvd_gcd_iff]; simp

/-! ## Theorem 2 -/

/-- **Theorem 2.** Two integer vectors reduce to the same class modulo `p` iff `p` divides the gcd
of their coordinatewise difference. -/
theorem redMod_eq_iff {k : ℕ} (p : ℕ) (v x : Fin k → ℤ) :
    redMod p v = redMod p x ↔ (p : ℤ) ∣ vecGcd (v - x) := by
  rw [funext_iff, dvd_vecGcd_iff]
  refine forall_congr' (fun i => ?_)
  simp only [redMod, Pi.sub_apply]
  rw [ZMod.intCast_eq_intCast_iff, Int.modEq_iff_dvd]
  exact dvd_sub_comm

theorem redMod_zero {k : ℕ} (p : ℕ) : redMod p (0 : Fin k → ℤ) = 0 := by
  funext i; simp [redMod]

/-- The reduction of `w` modulo `p` is the zero vector iff `p` divides the gcd of its
coordinates. -/
theorem redMod_eq_zero_iff {k : ℕ} (p : ℕ) (w : Fin k → ℤ) :
    redMod p w = 0 ↔ (p : ℤ) ∣ vecGcd w := by
  have h := redMod_eq_iff p w 0
  rw [sub_zero, redMod_zero] at h
  exact h

/-! ## Theorem 3 — the local-global bridge -/

/-- **Theorem 3 (main result).** An integer vector is coprime (its coordinate gcd is `1`) iff for
every prime `p` its reduction modulo `p` is non-zero.  Coprimality is thus a local, per-prime
condition. -/
theorem vecGcd_eq_one_iff {k : ℕ} (w : Fin k → ℤ) :
    vecGcd w = 1 ↔ ∀ p : ℕ, p.Prime → redMod p w ≠ 0 := by
  simp only [ne_eq, redMod_eq_zero_iff]
  constructor
  · intro h p hp hdvd
    rw [h] at hdvd
    have hle := Int.le_of_dvd (by norm_num) hdvd
    have h2 : (2 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp.two_le
    omega
  · intro h
    have hnn := vecGcd_nonneg w
    by_contra hne
    have hna : (vecGcd w).natAbs ≠ 1 := by
      intro hcontra
      apply hne
      have := Int.natAbs_of_nonneg hnn
      omega
    obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd hna
    apply h p hp
    have : (p : ℤ) ∣ ((vecGcd w).natAbs : ℤ) := Int.natCast_dvd_natCast.mpr hpd
    rwa [Int.natAbs_of_nonneg hnn] at this

/-! ## Theorem 4

The brief's proposed multiplicativity `localDensity (p*q) S = localDensity p S * localDensity q S`
is false.  We record the brief's definitions and disprove the claim, then state and prove the
correct multiplicative density. -/

/-- The image of a finite set of integer vectors under reduction modulo `p` (brief's definition). -/
def redModFinset (p : ℕ) {k : ℕ} (S : Finset (Fin k → ℤ)) : Finset (Fin k → ZMod p) :=
  S.image (redMod p)

/-- The brief's "local density": `1 - |redMod p '' S| / p^k` (retained for the record; note the
multiplicativity claimed for it in the brief is false, see `localDensity_mul_counterexample`). -/
def localDensity (p : ℕ) {k : ℕ} (S : Finset (Fin k → ℤ)) : ℚ :=
  1 - (redModFinset p S).card / (p : ℚ) ^ k

/-- The explicit two-point counterexample set `{0, 1} ⊆ (Fin 1 → ℤ)`. -/
def counterSet : Finset (Fin 1 → ℤ) := {(fun _ => 0), (fun _ => 1)}

/-- The brief's Theorem 4 is **false**: for `p = 2`, `q = 3`, `k = 1` and `S = {0, 1}` we have
`localDensity 6 S = 2/3` while `localDensity 2 S * localDensity 3 S = 0`. -/
theorem localDensity_mul_counterexample :
    localDensity 6 counterSet ≠ localDensity 2 counterSet * localDensity 3 counterSet := by
  native_decide

/-- Consequently, the universally quantified multiplicativity claim of the brief fails. -/
theorem not_localDensity_mul :
    ¬ (∀ (p q : ℕ), p.Prime → q.Prime → Nat.Coprime p q →
        ∀ {k : ℕ} (S : Finset (Fin k → ℤ)),
          localDensity (p * q) S = localDensity p S * localDensity q S) := by
  intro h
  exact localDensity_mul_counterexample
    (h 2 3 (by norm_num) (by norm_num) (by norm_num) counterSet)

/-! ### Corrected Theorem 4: multiplicativity of the primitive-residue density -/

/-- A vector `x : Fin k → R` over a commutative ring `R` is *primitive* if its coordinates generate
the unit ideal, i.e. there is a linear combination of the coordinates equal to `1`.  This condition
is representation independent and, over a field `ZMod p`, is equivalent to `x` being non-zero. -/
def IsPrim {R : Type*} [CommRing R] {k : ℕ} (x : Fin k → R) : Prop :=
  ∃ a : Fin k → R, ∑ i, a i * x i = 1

/-- Primitivity is preserved by a ring isomorphism applied coordinatewise. -/
lemma isPrim_ringEquiv {R S : Type*} [CommRing R] [CommRing S] {k : ℕ}
    (e : R ≃+* S) (x : Fin k → R) : IsPrim x ↔ IsPrim (fun i => e (x i)) := by
  constructor;
  · exact fun ⟨ a, ha ⟩ => ⟨ fun i => e ( a i ), by simpa [ map_sum, map_mul ] using congrArg e ha ⟩;
  · rintro ⟨ a, ha ⟩;
    exact ⟨ fun i => e.symm ( a i ), by simpa [ map_sum, map_mul ] using congr_arg e.symm ha ⟩

/-- Over a product ring, a vector is primitive iff each of its projections is primitive. -/
lemma isPrim_prod {R S : Type*} [CommRing R] [CommRing S] {k : ℕ}
    (x : Fin k → R × S) :
    IsPrim x ↔ IsPrim (fun i => (x i).1) ∧ IsPrim (fun i => (x i).2) := by
  constructor <;> intro h;
  · constructor <;> rcases h with ⟨ a, ha ⟩;
    · use fun i => (a i).1;
      convert congr_arg Prod.fst ha using 1;
      simp +decide [ Prod.fst_sum ];
    · use fun i => (a i).2;
      convert congr_arg Prod.snd ha using 1;
      simp +decide [ Prod.snd_sum ];
  · obtain ⟨ a₁, ha₁ ⟩ := h.1
    obtain ⟨ a₂, ha₂ ⟩ := h.2
    use fun i => (a₁ i, a₂ i);
    simp_all +decide [ Prod.ext_iff, Prod.fst_sum, Prod.snd_sum ]

/-- The density of primitive residue vectors in `(ZMod n) ^ k`. -/
noncomputable def primDensity (n k : ℕ) : ℚ :=
  (Nat.card {x : Fin k → ZMod n // IsPrim x} : ℚ) / (n : ℚ) ^ k

/-- The number of primitive residue vectors is multiplicative across coprime moduli (Chinese
Remainder Theorem). -/
lemma numPrim_mul {p q k : ℕ} (h : Nat.Coprime p q) :
    Nat.card {x : Fin k → ZMod (p * q) // IsPrim x}
      = Nat.card {x : Fin k → ZMod p // IsPrim x}
        * Nat.card {x : Fin k → ZMod q // IsPrim x} := by
  convert Nat.card_congr ?_ using 1;
  rw [ ← Nat.card_prod ];
  have e := ZMod.chineseRemainder h;
  refine' Equiv.trans ( Equiv.subtypeEquiv ( Equiv.piCongrRight fun _ => e.toEquiv ) _ ) _;
  use fun x => IsPrim ( fun i => x i |>.1 ) ∧ IsPrim ( fun i => x i |>.2 );
  · intro a;
    convert isPrim_prod ( fun i => e ( a i ) ) using 1;
    convert isPrim_ringEquiv e a using 1;
  · exact ⟨ fun x => ⟨ ⟨ fun i => x.val i |>.1, x.property.1 ⟩, ⟨ fun i => x.val i |>.2, x.property.2 ⟩ ⟩, fun x => ⟨ fun i => ( x.1.val i, x.2.val i ), x.1.property, x.2.property ⟩, fun x => rfl, fun x => rfl ⟩

/-- **Corrected Theorem 4.** The primitive-residue density is multiplicative across coprime moduli.
This is the genuine local factor multiplicativity underlying the Euler product for the density of
simultaneously visible lattice points. -/
theorem primDensity_mul {p q k : ℕ} (hpq : Nat.Coprime p q) :
    primDensity (p * q) k = primDensity p k * primDensity q k := by
  unfold primDensity
  rw [numPrim_mul hpq]
  push_cast
  rw [mul_pow, div_mul_div_comm]

end VectorCoprimalityLocalGlobal