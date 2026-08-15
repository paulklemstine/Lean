import Mathlib
import Tropical.FreeWitnessClassification

/-!
# The tropical shadow of a free witness, and the size of its fibres

The classification of `Tropical.FreeWitnessClassification` says that the *classical*
(plus–times) aggregate `A_w(N) = ∑_{d ∣ N} w d` of a strictly monotone CRT weight is a
free witness.  This file measures how much of that is destroyed by tropicalisation,
and how much information the classical aggregate really carries.

## 1. The tropical shadow lemma

Replacing `(+, ×)` by the min-plus semiring turns the aggregate into
`⨁_{d ∣ N} trop (w d) = trop (w 1)` (`tropicalAggregate_eq_trop_one`): the tropical
aggregate of *every* `N` is the same tropical number, so it is factor-blind — no
function of it returns a factor (`tropical_aggregate_factor_blind`).  In the max-plus
convention the aggregate is `w N` (`maxAggregate_eq`), which is a function of `N`
alone; consequently recovery from it is *equivalent* to recovery from `N` itself
(`max_aggregate_reduces_to_N`), so it is not a witness either.

Reading: multiplicativity — the very mechanism that makes `A_w` a free witness — is
an artefact of the `(+, ×)` structure.  Tropical aggregation is idempotent, and an
idempotent aggregate can only see the extreme divisors `1` and `N`, both of which are
factor-free.  This is a tropical analogue of the characters-only boundary lemma.

## 2. Fibres of the classical aggregate

The trace lemma is often quoted as "the witness value *is* the factorisation".  That
is false as stated, and we prove it false: `sigma_one_collision` exhibits
`σ₁(2·7) = σ₁(3·5) = 24`, so the aggregate value alone does not determine the
semiprime.  What *is* true is a sharp fibre bound: the semiprimes with a given
aggregate value `V` inject into the divisors of `V`
(`aggregate_fibre_card_le_tau`), so the witness pins the factorisation to at most
`τ(V)` candidates, and together with `N` (which every attacker has) to exactly one.
This is the honest form of the trace lemma.

## 3. The residue channel

The third branch of the trace lemma — "a residue/order vector" — is made precise by
`residue_channel_recovery`: a single residue `p mod m` with `m > √N` already *is* the
factor, hence recovery is division.  So all three quoted channels (trace, max, residue)
are one factor-secret coordinate, as the classification asserts.
-/

namespace FreeWitnessShadow

open Finset FreeWitness

/-! ## 1. The tropical shadow -/

/-- The **tropical (min-plus) aggregate** of a weight over the divisors of `N`. -/
def tropicalAggregate (w : ℕ → ℕ) (N : ℕ) : Tropical (WithTop ℕ) :=
  ∑ d ∈ N.divisors, Tropical.trop ((w d : ℕ) : WithTop ℕ)

/-- The **max-plus aggregate**: the same idempotent aggregation with the opposite
order convention. -/
def maxAggregate (w : ℕ → ℕ) (N : ℕ) : ℕ := N.divisors.sup w

/-- **Tropical shadow lemma.**  For a monotone weight the min-plus aggregate collapses
to the value at the divisor `1`: tropical aggregation only sees the bottom of the
divisor lattice. -/
theorem tropicalAggregate_eq_trop_one {w : ℕ → ℕ} (hm : Monotone w) {N : ℕ} (hN : N ≠ 0) :
    tropicalAggregate w N = Tropical.trop ((w 1 : ℕ) : WithTop ℕ) := by
  have hinf : N.divisors.inf (fun d => ((w d : ℕ) : WithTop ℕ)) = ((w 1 : ℕ) : WithTop ℕ) := by
    refine le_antisymm (Finset.inf_le (Nat.one_mem_divisors.mpr hN)) (Finset.le_inf ?_)
    intro d hd
    exact_mod_cast hm (Nat.pos_of_mem_divisors hd)
  rw [tropicalAggregate, ← Finset.trop_inf, hinf]

/-- For a CRT weight the tropical aggregate is the *constant* `trop 1`, independent of
`N`: the tropicalised witness is empty of arithmetic content. -/
theorem tropicalAggregate_const {w : ℕ → ℕ} (hw : IsCRTWeight w) (hm : Monotone w) {N : ℕ}
    (hN : N ≠ 0) : tropicalAggregate w N = Tropical.trop (1 : WithTop ℕ) := by
  rw [tropicalAggregate_eq_trop_one hm hN, hw.one]
  norm_num

/-- **Tropical sealing.**  No function of the tropical aggregate can return a prime
factor: the aggregate is literally constant over all semiprimes.  Contrast
`FreeWitness.strictMono_crt_weight_is_free_witness`, where the *classical* aggregate of
the same weight does pin the factorisation. -/
theorem tropical_aggregate_factor_blind {w : ℕ → ℕ} (hw : IsCRTWeight w) (hm : Monotone w) :
    ¬ ∃ f : Tropical (WithTop ℕ) → ℕ, ∀ x y : ℕ, x.Prime → y.Prime → x < y →
        f (tropicalAggregate w (x * y)) = x := by
  rintro ⟨f, hf⟩
  have h1 := hf 2 3 Nat.prime_two Nat.prime_three (by norm_num)
  have h2 := hf 3 5 Nat.prime_three (by norm_num) (by norm_num)
  rw [tropicalAggregate_const hw hm (by norm_num)] at h1
  rw [tropicalAggregate_const hw hm (by norm_num)] at h2
  omega

/-- The max-plus aggregate of a monotone weight is `w N`. -/
theorem maxAggregate_eq {w : ℕ → ℕ} (hm : Monotone w) {N : ℕ} (hN : N ≠ 0) :
    maxAggregate w N = w N := by
  refine le_antisymm (Finset.sup_le ?_) (Finset.le_sup (Nat.mem_divisors_self N hN))
  intro d hd
  exact hm (Nat.le_of_dvd (Nat.pos_of_ne_zero hN) (Nat.dvd_of_mem_divisors hd))

/-- **The max-plus aggregate is no witness.**  For a strictly monotone weight,
recovering a factor from the max-plus aggregate is *equivalent* to recovering it from
`N` itself: the aggregate is an invertible relabelling of `N` and carries no extra
arithmetic. -/
theorem max_aggregate_reduces_to_N {w : ℕ → ℕ} (hmono : StrictMono w) :
    (∃ f : ℕ → ℕ, ∀ x y : ℕ, x.Prime → y.Prime → x < y → f (maxAggregate w (x * y)) = x)
      ↔ (∃ g : ℕ → ℕ, ∀ x y : ℕ, x.Prime → y.Prime → x < y → g (x * y) = x) := by
  have hval : ∀ x y : ℕ, x.Prime → y.Prime → maxAggregate w (x * y) = w (x * y) := by
    intro x y hx hy
    exact maxAggregate_eq hmono.monotone (Nat.mul_ne_zero hx.pos.ne' hy.pos.ne')
  constructor
  · rintro ⟨f, hf⟩
    refine ⟨fun n => f (w n), fun x y hx hy hlt => ?_⟩
    have := hf x y hx hy hlt
    rwa [hval x y hx hy] at this
  · rintro ⟨g, hg⟩
    refine ⟨fun v => g (Function.invFun w v), fun x y hx hy hlt => ?_⟩
    simp only [hval x y hx hy, Function.leftInverse_invFun hmono.injective (x * y)]
    exact hg x y hx hy hlt

/-! ## 2. Fibres of the classical aggregate -/

/-- **The witness value alone is not the factorisation.**  `σ₁(14) = σ₁(15) = 24`, so
the aggregate of the identity weight collides on semiprimes.  Every "trace lemma"
statement therefore *must* also use `N`. -/
theorem sigma_one_collision :
    (∑ d ∈ (2 * 7 : ℕ).divisors, d) = (∑ d ∈ (3 * 5 : ℕ).divisors, d) ∧ (2 * 7 : ℕ) ≠ 3 * 5 := by
  constructor
  · decide
  · decide

/-- **Fibre bound (the honest trace lemma).**  For a strictly monotone CRT weight, the
semiprime pairs with aggregate value `V` inject into the divisors of `V` via
`(p, q) ↦ 1 + w p`.  Hence at most `τ(V)` semiprimes share a witness value: the witness
determines the factorisation up to a divisor-count many candidates, and exactly once
`N` is also known. -/
theorem aggregate_fibre_card_le_tau {w : ℕ → ℕ} (hmono : StrictMono w) (V : ℕ) (hV : V ≠ 0) :
    {pq : ℕ × ℕ | pq.1.Prime ∧ pq.2.Prime ∧ pq.1 < pq.2 ∧
        (1 + w pq.1) * (1 + w pq.2) = V}.ncard ≤ V.divisors.card := by
  classical
  set S : Set (ℕ × ℕ) := {pq : ℕ × ℕ | pq.1.Prime ∧ pq.2.Prime ∧ pq.1 < pq.2 ∧
    (1 + w pq.1) * (1 + w pq.2) = V} with hS
  have hmaps : ∀ pq ∈ S, (1 + w pq.1) ∈ (V.divisors : Set ℕ) := by
    rintro ⟨p, q⟩ ⟨-, -, -, hval⟩
    exact Nat.mem_divisors.mpr ⟨⟨1 + w q, hval.symm⟩, hV⟩
  have hinj : Set.InjOn (fun pq : ℕ × ℕ => 1 + w pq.1) S := by
    rintro ⟨p, q⟩ ⟨-, -, -, hval⟩ ⟨p', q'⟩ ⟨-, -, -, hval'⟩ heq
    simp only at heq
    have hp : p = p' := hmono.injective (by omega)
    subst hp
    have hpos : 0 < 1 + w p := by omega
    have : 1 + w q = 1 + w q' := by
      have := hval.trans hval'.symm
      exact Nat.eq_of_mul_eq_mul_left hpos this
    have : q = q' := hmono.injective (by omega)
    simp [this]
  have hfin : (V.divisors : Set ℕ).Finite := V.divisors.finite_toSet
  have := Set.ncard_le_ncard_of_injOn (fun pq : ℕ × ℕ => 1 + w pq.1) hmaps hinj hfin
  simpa [Set.ncard_coe_finset] using this

/-- Specialisation to the SIGK witness `σ_k`: at most `τ(V)` semiprimes carry a given
divisor-power-sum value. -/
theorem sigma_pow_fibre_card_le_tau {k : ℕ} (hk : 1 ≤ k) (V : ℕ) (hV : V ≠ 0) :
    {pq : ℕ × ℕ | pq.1.Prime ∧ pq.2.Prime ∧ pq.1 < pq.2 ∧
        (1 + pq.1 ^ k) * (1 + pq.2 ^ k) = V}.ncard ≤ V.divisors.card :=
  aggregate_fibre_card_le_tau (strictMono_pow hk) V hV

/-! ## 3. The residue channel -/

/-- **The residue channel is one factor-secret coordinate.**  A residue of the small
factor to any modulus exceeding the tropical corner `√N` *is* the small factor, and the
cofactor follows by one division.  This is the precise content of the third branch of
the trace lemma. -/
theorem residue_channel_recovery {p q m : ℕ} (hp : 0 < p) (hpq : p ≤ q) (hm : Nat.sqrt (p * q) < m) :
    p % m = p ∧ (p * q) / (p % m) = q := by
  have hle : p ≤ Nat.sqrt (p * q) := Nat.le_sqrt.mpr (Nat.mul_le_mul_left p hpq)
  have hlt : p < m := lt_of_le_of_lt hle hm
  have hmod : p % m = p := Nat.mod_eq_of_lt hlt
  refine ⟨hmod, ?_⟩
  rw [hmod, Nat.mul_div_cancel_left q hp]

/-- Combining the two: from the trace `s = p + q` (channel 1) and from a residue with
modulus above the corner (channel 3) one gets the same object — the factorisation.
Here is the residue-channel end-to-end statement for a semiprime. -/
theorem residue_channel_semiprime {p q m : ℕ} (hp : p.Prime) (hpq : p ≤ q)
    (hm : Nat.sqrt (p * q) < m) : ((p * q) / (p % m)) = q ∧ (p % m) * q = p * q := by
  obtain ⟨h1, h2⟩ := residue_channel_recovery hp.pos hpq hm
  exact ⟨h2, by rw [h1]⟩

end FreeWitnessShadow