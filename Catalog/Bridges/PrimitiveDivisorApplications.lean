import Mathlib
import Bridges.PrimitiveDivisorSchema

/-!
# Applications of the primitive-divisor schema

Building directly on `Catalog/Bridges/PrimitiveDivisorSchema.lean`, this file shows the
mined schema is *reusable*: a single entry-point characterisation of primitivity is proved
once for an abstract strong divisibility sequence and then instantiated to both Fibonacci
numbers and the sequences `n ↦ a^n - 1`.

The headline corollary `primitive_iff_entryPt_eq` says: for a strong divisibility
sequence, an index `n` carries a *primitive* divisor `p` (one dividing no earlier term)
**iff** `n` is the entry point of `p`.  This collapses the order-theoretic primitivity
condition to a single equation, unifying the two threads of the schema file
(`primitive_of_avoids_proper` and `entryPt_dvd_index`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Primitive index" and "entry point" should be the *same*
notion for any strong divisibility sequence; the Carmichael literature treats them
interchangeably but the equivalence is never isolated.

Experiment (Experimenter): Proved `primitive_iff_entryPt_eq` from the two schema lemmas:
forward via minimality of the entry point, backward via `entryPt_dvd_index` forcing
`n ∣ k`.  Instantiated to `Nat.fib` and `fun n => a^n - 1`.

Analysis (Analyst): The equivalence needs only `IsStrongDivSeq` plus `p ∣ a n`; it is the
clean fixed point of the schema, turning "primitive divisor existence" into "is the entry
point achieved at `n`".

Critique (Critic): Checked the existence side-condition `∃ k, 0 < k ∧ p ∣ a k` is supplied
by the witness `n` itself, so no hidden vacuity.  The instances reuse, rather than
re-prove, the abstract result — exactly the schema-reuse the mission targets.

Synthesis (PI): One abstract equivalence, two domain instantiations, zero duplicated
arguments.
-- !-- Lab Notes -- !--
-/

namespace ProofSchema

variable {a : ℕ → ℕ}

/-
**Entry-point characterisation of primitivity (schema form).**  For a strong
divisibility sequence, `n` carries a primitive divisor `p` exactly when `n` is the entry
point of `p`.
-/
theorem primitive_iff_entryPt_eq (ha : IsStrongDivSeq a) (p n : ℕ) (hn : 0 < n)
    (hpn : p ∣ a n) :
    (∀ k, 0 < k → k < n → ¬ p ∣ a k) ↔ entryPt a p = n := by
  constructor <;> intro h;
  · unfold entryPt;
    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ];
  · intro k hk hk'; have := entryPt_dvd_index ha p k hk; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
    exact fun h => by rw [ Nat.mod_eq_of_lt hk' ] at this; aesop;

/-- Fibonacci instantiation: primitive index ⇔ Fibonacci entry point. -/
theorem fib_primitive_iff_entryPt_eq (p n : ℕ) (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    (∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k) ↔ entryPt Nat.fib p = n :=
  primitive_iff_entryPt_eq fib_isStrongDivSeq p n hn hpn

/-- `a^n - 1` instantiation: primitive index ⇔ multiplicative-order entry point. -/
theorem pow_sub_one_primitive_iff_entryPt_eq (a p n : ℕ) (hn : 0 < n)
    (hpn : p ∣ a ^ n - 1) :
    (∀ k, 0 < k → k < n → ¬ p ∣ a ^ k - 1) ↔ entryPt (fun n => a ^ n - 1) p = n :=
  primitive_iff_entryPt_eq (pow_sub_one_isStrongDivSeq a) p n hn hpn

/-- **Subsumption of the catalog.**  The `bridge_lemma` of
`Catalog/Shared/CarmichaelProof.lean` is recovered verbatim as the Fibonacci instance of
the abstract schema `primitive_of_avoids_proper`, confirming the schema strictly
generalises the hand-written Carmichael argument. -/
theorem fib_bridge_lemma (n : ℕ) (hn : 0 < n) (p : ℕ)
    (hpn : p ∣ Nat.fib n)
    (hdiv : ∀ d, d ∣ n → 0 < d → d < n → ¬ (p ∣ Nat.fib d)) :
    ∀ k, 0 < k → k < n → ¬ (p ∣ Nat.fib k) :=
  primitive_of_avoids_proper fib_isStrongDivSeq hn hpn hdiv

end ProofSchema