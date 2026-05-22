import Mathlib

/-!
# Tropical Low-Rank Attack: Power Compression Through Factorization

This file formalizes the **tropical low-rank attack principle**: if a matrix `G` factors
as `G = U * V` through a smaller intermediate dimension `r`, then every power of `G`
is governed by the smaller `r × r` core matrix `H = V * U`. Specifically,
  `G ^ a = U * H ^ (a - 1) * V` for all `a ≥ 1`.

This creates a genuine attack surface for tropical cryptographic protocols: any hidden
exponent problem on `G ^ a` descends to a lower-dimensional problem on `H ^ (a - 1)`.

## Main results

* `mul_pow_sandwich` — The core algebraic identity over any `Semiring`: if `G = U * V`,
  then `G ^ a = U * (V * U) ^ (a - 1) * V`.
* `tropical_pow_factorization` — Specialization to tropical matrices over `Tropical (WithTop ℤ)`.
* `core_power_collision_implies_full_collision` — Collisions in the core transfer to
  collisions in the full matrix: `H ^ (a-1) = H ^ (b-1) → G ^ a = G ^ b`.
* `tropical_rank_pow_le` — Low tropical rank is preserved under all powers.

## Cryptanalytic significance

In a tropical semigroup key-exchange protocol where the public key reveals `G ^ a`,
low rank of `G` means that exponent recovery reduces to a problem of dimension `r`
instead of `n`. This is a tropical analogue of classical low-rank cryptanalysis.
-/

noncomputable section

open Matrix

/-! ## Part 1: The General Sandwich-Power Identity

This identity holds over any semiring and any fintype index sets. It is the algebraic
heart of the low-rank attack. -/

/-
**Sandwich-Power Identity.** For rectangular matrices `U : n × r` and `V : r × n`
over any semiring, the `a`-th power of `U * V` factors through the smaller core `V * U`:
  `(U * V) ^ a = U * (V * U) ^ (a - 1) * V` for `a ≥ 1`.
-/
theorem mul_pow_sandwich
    {α : Type*} [Semiring α]
    {n r : ℕ}
    (U : Matrix (Fin n) (Fin r) α)
    (V : Matrix (Fin r) (Fin n) α)
    (a : ℕ) (ha : 1 ≤ a) :
    (U * V) ^ a = U * (V * U) ^ (a - 1) * V := by
  -- By induction on $a$, we can show that $(U * V)^a = U * (V * U)^{a-1} * V$ for all $a \geq 1$.
  induction' a with k hk;
  · grobner;
  · cases k <;> simp_all +decide [ pow_succ', Matrix.mul_assoc ]

/-
Auxiliary lemma: `(U * V) ^ a * U = U * (V * U) ^ a` for all `a`.
-/
theorem mul_pow_mul_left
    {α : Type*} [Semiring α]
    {n r : ℕ}
    (U : Matrix (Fin n) (Fin r) α)
    (V : Matrix (Fin r) (Fin n) α)
    (a : ℕ) :
    (U * V) ^ a * U = U * (V * U) ^ a := by
  induction' a with a ih;
  · simp +decide;
  · simp +decide only [pow_succ, Matrix.mul_assoc];
    simp +decide only [← Matrix.mul_assoc, ← ih]

/-! ## Part 2: Tropical Specialization

We specialize to the tropical semiring `Tropical (WithTop ℤ)`, where addition is `min`
and multiplication is `+`. Matrix multiplication over this semiring is the standard
min-plus matrix product used in shortest-path algorithms. -/

/-- Tropical matrix type abbreviation. -/
abbrev TropMat (n m : ℕ) := Matrix (Fin n) (Fin m) (Tropical (WithTop ℤ))

/-- **Tropical Power Compression.** Over the min-plus semiring, if `G = U ⊗ V`
(tropical matrix product), then `G^a = U ⊗ H^(a-1) ⊗ V` where `H = V ⊗ U`. -/
theorem tropical_pow_factorization
    {n r : ℕ}
    (U : TropMat n r)
    (V : TropMat r n)
    (a : ℕ) (ha : 1 ≤ a) :
    (U * V) ^ a = U * (V * U) ^ (a - 1) * V :=
  mul_pow_sandwich U V a ha

/-! ## Part 3: Collision Transfer — Cryptanalytic Core

These theorems show that structural properties of the compressed core `H = V * U`
transfer directly to the full matrix `G = U * V`. -/

/-
**Core collision implies full collision.** If two powers of the core `H = V * U`
agree, then the corresponding powers of `G = U * V` also agree. This is the key
cryptanalytic reduction: periodicity in the small core forces periodicity in the
full matrix.
-/
theorem core_power_collision_implies_full_collision
    {α : Type*} [Semiring α]
    {n r : ℕ}
    (U : Matrix (Fin n) (Fin r) α)
    (V : Matrix (Fin r) (Fin n) α)
    {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b)
    (hcore : (V * U) ^ (a - 1) = (V * U) ^ (b - 1)) :
    (U * V) ^ a = (U * V) ^ b := by
  grind +suggestions

/-
**Core periodicity implies full periodicity.** If the core matrix `H = V * U`
has eventual period `p` (i.e., `H^(k+p) = H^k` for all `k ≥ N`), then the full
matrix `G = U * V` has the same eventual period.
-/
theorem core_periodicity_implies_full_periodicity
    {α : Type*} [Semiring α]
    {n r : ℕ}
    (U : Matrix (Fin n) (Fin r) α)
    (V : Matrix (Fin r) (Fin n) α)
    {N p : ℕ} (hp : 0 < p)
    (hperiod : ∀ k, N ≤ k → (V * U) ^ (k + p) = (V * U) ^ k) :
    ∀ k, N + 1 ≤ k → (U * V) ^ (k + p) = (U * V) ^ k := by
  intro k hk;
  -- Apply the factorization theorem to both (k+p) and k.
  have h_factor : (U * V) ^ (k + p) = U * (V * U) ^ (k + p - 1) * V ∧ (U * V) ^ k = U * (V * U) ^ (k - 1) * V := by
    exact ⟨ mul_pow_sandwich U V _ ( by linarith ), mul_pow_sandwich U V _ ( by linarith ) ⟩;
  rcases k with ( _ | k ) <;> simp_all +decide

/-! ## Part 4: Tropical Rank and Power Rank Bound

We define a notion of tropical factorization rank and show it is preserved under powers. -/

/-- A matrix `G` has **tropical factorization rank** at most `r` if it can be written
as `U * V` for some `U : n × r` and `V : r × n`. -/
def HasTropFactRank (G : TropMat n n) (r : ℕ) : Prop :=
  ∃ (U : TropMat n r) (V : TropMat r n), U * V = G

/-
**Low rank is preserved under powers.** If `G` has tropical factorization rank
at most `r`, then so does every positive power `G ^ a`.
-/
theorem tropical_rank_pow_le
    {n r : ℕ}
    (G : TropMat n n)
    (hr : HasTropFactRank G r)
    (a : ℕ) (ha : 1 ≤ a) :
    HasTropFactRank (G ^ a) r := by
  obtain ⟨ U, V, rfl ⟩ := hr;
  exact ⟨ U * ( V * U ) ^ ( a - 1 ), V, by rw [ mul_pow_sandwich U V a ha ] ⟩

/-
**Low-rank power reduction.** If `G` has tropical factorization rank at most `r`,
then there exist factor matrices `U, V` such that every power of `G` factors through
the `r × r` core `H = V * U`. This is the master theorem for the tropical low-rank
attack.
-/
theorem low_rank_power_reduction
    {n r : ℕ}
    (G : TropMat n n)
    (hr : HasTropFactRank G r) :
    ∃ (U : TropMat n r) (V : TropMat r n),
      U * V = G ∧
      ∀ a : ℕ, 1 ≤ a →
        G ^ a = U * (V * U) ^ (a - 1) * V := by
  obtain ⟨ U, V, rfl ⟩ := hr; exact ⟨ U, V, rfl, fun a ha => mul_pow_sandwich _ _ _ ha ⟩ ;

end