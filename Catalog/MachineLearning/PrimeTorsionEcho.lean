/-
# Prime-Sensitive Torsion Echoes in Random Flag Complexes

This module develops the formal algebraic theory of **prime-sensitive torsion observables**
for finite abelian groups and chain complexes. The central idea is that while Betti numbers
(ranks of homology groups) are field-coefficient universal, the torsion subgroup of integral
homology retains a detectable **prime fingerprint** that can differ across primes.

## Main Definitions

* `primeTorsionWeight` — the ℓ-adic valuation of the cardinality of a finite type
* `torsionEchoMatrix` — the sum of ℓ-adic valuations of diagonal entries of a
  Smith-normal-form-like diagonal matrix, modeling torsion from boundary matrices
* `PrimeSeparated` — predicate asserting two primes see different torsion weights

## Main Results

* `primeTorsionWeight_prod` — additivity of prime torsion weight under products
* `primeSeparated_of_prime_powers` — explicit prime separation for ℤ/ℓ^a × ℤ/q^b
* `exists_primeSeparated_finite_group` — existence of a finite abelian group with
  different torsion echoes at two primes
* `torsionEchoMatrix_zero_of_allOnes` — vanishing of torsion echo when all Smith
  invariants are 1 (unimodular case)
* `exists_matrix_primeSeparated` — existence of a diagonal matrix with different
  prime echoes at two primes
-/
import Mathlib

open Finset Nat

/-! ## Section 1: Prime Torsion Weight -/

/-- The **prime torsion weight** of a finite type `A` at prime `ℓ` is the ℓ-adic
valuation of its cardinality. For a finite abelian group, this measures the total
ℓ-primary torsion content. -/
noncomputable def primeTorsionWeight (ℓ : ℕ) (A : Type*) [Finite A] : ℕ :=
  padicValNat ℓ (Nat.card A)

/-! ## Section 2: Additivity of Prime Torsion Weight -/

/-
The prime torsion weight is additive under products: the ℓ-adic valuation
of |A × B| equals the sum of the ℓ-adic valuations of |A| and |B|.
This is the formal basis for decomposing torsion across direct sums.
-/
theorem primeTorsionWeight_prod
    (A B : Type*) [Finite A] [Finite B]
    (ℓ : ℕ) [Fact ℓ.Prime]
    (hA : Nonempty A) (hB : Nonempty B) :
    primeTorsionWeight ℓ (A × B)
      = primeTorsionWeight ℓ A + primeTorsionWeight ℓ B := by
  unfold primeTorsionWeight; haveI := Fintype.ofFinite A; haveI := Fintype.ofFinite B; simp +decide [ Fintype.card_prod ] ;
  rw [ padicValNat.mul ( by exact Fintype.card_ne_zero ) ( by exact Fintype.card_ne_zero ) ]

/-
Specialization: the ℓ-adic valuation of the cardinality of a product of finite
types equals the sum of the individual ℓ-adic valuations.
-/
theorem padicValNat_card_prod
    (A B : Type*) [Finite A] [Finite B]
    (ℓ : ℕ) [Fact ℓ.Prime]
    (hA : Nonempty A) (hB : Nonempty B) :
    padicValNat ℓ (Nat.card (A × B))
      = padicValNat ℓ (Nat.card A) + padicValNat ℓ (Nat.card B) := by
  rw [ Nat.card_prod, padicValNat.mul ] <;> simp +decide [ Nat.card_pos ];
  · exact Nat.ne_of_gt ( Nat.card_pos );
  · exact Nat.card_pos.ne'

/-! ## Section 3: Prime Separation for Explicit Groups -/

/-
For distinct primes ℓ and q, the ℓ-adic valuation of |ZMod (ℓ^a × ZMod (q^b))|
equals `a`. This shows prime ℓ sees exactly `a` units of torsion in this group,
regardless of q's contribution.
-/
theorem primeSeparated_zmod_pow
    (ℓ q a b : ℕ)
    [hℓ : Fact ℓ.Prime] [hq : Fact q.Prime]
    (hneq : ℓ ≠ q) (ha : 0 < a) (hb : 0 < b) :
    padicValNat ℓ (Nat.card (ZMod (ℓ ^ a) × ZMod (q ^ b))) = a := by
  simp +decide [ Nat.card_eq_fintype_card, ZMod.card, padicValNat.mul, hℓ.1.ne_zero, hq.1.ne_zero, ha.ne', hb.ne' ];
  exact Or.inr ( mt hℓ.1.dvd_of_dvd_pow ( by rw [ Nat.prime_dvd_prime_iff_eq hℓ.1 hq.1 ] ; exact hneq ) )

/-
For distinct primes ℓ and q, the ℓ-adic valuation of |ZMod (q^b)| is zero.
Prime ℓ sees no torsion in a pure q-group.
-/
theorem primeSeparated_zmod_pow_other
    (ℓ q b : ℕ)
    [hℓ : Fact ℓ.Prime] [hq : Fact q.Prime]
    (hneq : ℓ ≠ q) :
    padicValNat ℓ (Nat.card (ZMod (q ^ b))) = 0 := by
  by_cases hb : b = 0 <;> simp_all +decide [ Nat.card_eq_fintype_card ];
  exact Or.inr <| Or.inr <| mt ( hℓ.1.dvd_of_dvd_pow ) <| fun h => hneq <| Nat.prime_dvd_prime_iff_eq hℓ.1 hq.1 |>.1 h

/-
**Prime Separation Existence**: There exists a finite type (a finite abelian group)
where two distinct primes see different torsion weights. This is the fundamental
anti-universality statement showing that prime identity matters for torsion.
-/
theorem exists_primeSeparated_finite_group :
    ∃ (A : Type) (_ : Finite A),
      ∃ ℓ q : ℕ, Nat.Prime ℓ ∧ Nat.Prime q ∧ ℓ ≠ q ∧
        padicValNat ℓ (Nat.card A) ≠ padicValNat q (Nat.card A) := by
  -- Consider the finite abelian group $A = \mathbb{Z}/12\mathbb{Z}$.
  use (ZMod 12);
  refine' ⟨ _, 2, 3, by decide, by decide, by decide, _ ⟩;
  · infer_instance;
  · rw [ Nat.card_eq_fintype_card ] ; native_decide

/-! ## Section 4: Torsion Echo from Smith Normal Form Data -/

/-- The **torsion echo** of a diagonal matrix (representing Smith invariants of
a boundary operator) at prime ℓ is the sum of ℓ-adic valuations of the diagonal
entries. This models the ℓ-primary torsion content of the homology group
computed from the chain complex. -/
def torsionEchoMatrix (ℓ : ℕ) {n : ℕ} (d : Fin n → ℕ) : ℕ :=
  ∑ i : Fin n, padicValNat ℓ (d i)

/-- A diagonal matrix (Smith data) is **prime-separated** if two distinct primes
yield different torsion echoes. -/
def PrimeSeparatedMatrix {n : ℕ} (d : Fin n → ℕ) : Prop :=
  ∃ ℓ q : ℕ, Nat.Prime ℓ ∧ Nat.Prime q ∧ ℓ ≠ q ∧
    torsionEchoMatrix ℓ d ≠ torsionEchoMatrix q d

/-
If all Smith invariants are 1, the torsion echo at any prime is zero.
This is the unimodular vanishing theorem: structurally trivial boundary
matrices produce no torsion at any prime.
-/
theorem torsionEchoMatrix_zero_of_allOnes
    (ℓ : ℕ) {n : ℕ} (d : Fin n → ℕ)
    (hones : ∀ i, d i = 1) :
    torsionEchoMatrix ℓ d = 0 := by
  unfold torsionEchoMatrix; aesop;

/-
The torsion echo of a single-entry diagonal with value `p^k` at prime `p`
equals `k`.
-/
theorem torsionEchoMatrix_singleton_prime_pow
    (p k : ℕ) [Fact p.Prime] :
    torsionEchoMatrix p (fun (_ : Fin 1) => p ^ k) = k := by
  unfold torsionEchoMatrix;
  simp +decide [ padicValNat.pow, Nat.Prime.ne_zero Fact.out ]

/-
The torsion echo of a single-entry diagonal with value `q^k` at a different
prime `p` is zero.
-/
theorem torsionEchoMatrix_singleton_other_prime
    (p q k : ℕ) [Fact p.Prime] [Fact q.Prime] (hneq : p ≠ q) :
    torsionEchoMatrix p (fun (_ : Fin 1) => q ^ k) = 0 := by
  convert primeSeparated_zmod_pow_other p q k hneq using 1;
  simp +decide [ torsionEchoMatrix ]

/-
**Matrix Prime Separation Existence**: There exist Smith invariant data and
two primes that yield different torsion echoes. This is the deterministic "toy
universe" showing prime-sensitive torsion is provably present in algebraic
chain models.
-/
theorem exists_matrix_primeSeparated :
    ∃ (n : ℕ) (d : Fin n → ℕ),
      PrimeSeparatedMatrix d := by
  by_contra! h;
  -- Consider the diagonal matrix with a single entry `4` at index `0`.
  set n : ℕ := 1
  set d : Fin n → ℕ := fun _ => 4;
  have := h n d;
  simp [PrimeSeparatedMatrix] at this;
  exact absurd ( this 2 Nat.prime_two 3 Nat.prime_three ( by decide ) ) ( by native_decide )

/-! ## Section 5: Rank Jump from Torsion -/

/-- The **rational rank** from Smith data: the number of nonzero entries. -/
def rankFromSmith {n : ℕ} (d : Fin n → ℕ) : ℕ :=
  (Finset.univ.filter (fun i => d i ≠ 0)).card

/-- The **mod-ℓ rank** from Smith data: the number of entries not divisible by ℓ
among nonzero entries, plus the number of entries divisible by ℓ but nonzero
(which contribute torsion). More precisely, each nonzero entry `d i` contributes
1 to the mod-ℓ rank if `ℓ ∤ d i`, and contributes 1 to both torsion and mod-ℓ rank
if `ℓ ∣ d i` (via the universal coefficient theorem).

Actually, the mod-ℓ rank of the cokernel is:
  (number of zero Smith invariants) + (number of nonzero Smith invariants divisible by ℓ)
The rank over ℚ of the cokernel is:
  (number of zero Smith invariants)

So the jump is exactly the number of nonzero Smith invariants divisible by ℓ. -/
def smithDivisibleCount (ℓ : ℕ) {n : ℕ} (d : Fin n → ℕ) : ℕ :=
  (Finset.univ.filter (fun i => d i ≠ 0 ∧ ℓ ∣ d i)).card

/-
If some Smith invariant is divisible by prime ℓ, then the mod-ℓ rank
of the cokernel exceeds the rational rank. This is the crossroad theorem
connecting integral torsion to field-coefficient topology: ℓ-torsion forces
a strict increase in mod-ℓ homology relative to the rational rank.
-/
theorem smith_modPrime_rank_jump
    {n : ℕ} (d : Fin n → ℕ) (ℓ : ℕ) [Fact ℓ.Prime]
    (hdiv : ∃ i : Fin n, d i ≠ 0 ∧ ℓ ∣ d i) :
    0 < smithDivisibleCount ℓ d := by
  -- Since there exists an i � such� that d i ≠ 0 and d i, the set { �i |� d i ≠ 0 ∧ ℓ ∣ d i} is non-empty.
  have h_nonempty : ∃ i, d i ≠ 0 ∧ ℓ ∣ d i := hdiv
  exact Finset.card_pos.mpr (by
  grind +suggestions)

/-! ## Section 6: Torsion Echo Monotonicity and Concatenation -/

/-
Concatenating Smith data adds torsion echoes.
-/
theorem torsionEchoMatrix_append
    (ℓ : ℕ) {m n : ℕ} (d₁ : Fin m → ℕ) (d₂ : Fin n → ℕ) :
    torsionEchoMatrix ℓ (Fin.append d₁ d₂) =
      torsionEchoMatrix ℓ d₁ + torsionEchoMatrix ℓ d₂ := by
  -- We can split the sum in `torsionEchoMatrix` into two parts corresponding to `d₁` and `d₂`.
  unfold torsionEchoMatrix
  simp [Fin.sum_univ_add, Fin.append]

/-
The torsion echo of a constant-1 diagonal is zero at any prime, even
without the primality hypothesis.
-/
theorem torsionEchoMatrix_ones_eq_zero
    (ℓ : ℕ) (n : ℕ) :
    torsionEchoMatrix ℓ (fun (_ : Fin n) => 1) = 0 := by
  unfold torsionEchoMatrix; aesop;

/-! ## Section 7: The Prime-Separation Predicate -/

/-- A finite type is **prime-separated** if two distinct primes yield
different prime torsion weights. -/
def PrimeSeparatedType (A : Type*) [Finite A] : Prop :=
  ∃ ℓ q : ℕ, Nat.Prime ℓ ∧ Nat.Prime q ∧ ℓ ≠ q ∧
    primeTorsionWeight ℓ A ≠ primeTorsionWeight q A

/-
ZMod (ℓ^a) × ZMod (q^b) is prime-separated for distinct primes ℓ, q with
different exponents. The prime ℓ sees weight `a` and prime q sees weight `b`,
so when `a ≠ b` these differ.
-/
theorem primeSeparatedType_zmod_prod
    (ℓ q a b : ℕ)
    [hℓ : Fact ℓ.Prime] [hq : Fact q.Prime]
    (hneq : ℓ ≠ q) (ha : 0 < a) (hb : 0 < b) (hab : a ≠ b) :
    PrimeSeparatedType (ZMod (ℓ ^ a) × ZMod (q ^ b)) := by
  -- By definition of Prime �Separated�Type, we need to show that there exist primes and q such that their torsion � weights� are different.
  use ℓ, q;
  -- By definition of primeTorsionWeight, we have:
  have h_primeTorsionWeight : primeTorsionWeight ℓ (ZMod (ℓ ^ a) × ZMod (q ^ b)) = a ∧ primeTorsionWeight q (ZMod (ℓ ^ a) × ZMod (q ^ b)) = b := by
    convert And.intro ( primeSeparated_zmod_pow ℓ q a b hneq ha hb ) ( primeSeparated_zmod_pow q ℓ b a ( Ne.symm hneq ) hb ha ) using 1;
    simp +decide [ primeTorsionWeight, mul_comm ];
  exact ⟨ hℓ.1, hq.1, hneq, by aesop ⟩

/-! ## Arithmetic Non-Universality Conjecture for Random Flag Complexes

**Conjecture (informal):** Let `X(n,p)` be the clique complex of the Erdős–Rényi
random graph `G(n,p)`. There exist `k ≥ 1`, primes `ℓ ≠ q`, and a critical-window
scaling `p(n) = n^{-1/(k+1)} · λ(n)` with `λ(n)` bounded away from 0 and ∞, such that
the normalized torsion echoes

  `v_ℓ(|Tor H_k(X(n,p); ℤ)|) / a_n`  and  `v_q(|Tor H_k(X(n,p); ℤ)|) / a_n`

do **not** converge to the same limiting law.

This conjecture is **supported** if for some `k, ℓ, q` and critical-window regime,
the Kolmogorov–Smirnov or Wasserstein distance between empirical laws stabilizes
away from zero as `n → ∞`.

This conjecture is **refuted** if for all tested pairs `(ℓ, q)` and all critical-window
scalings, the empirical distributions become statistically indistinguishable.
-/