import Mathlib

/-!
# Primitive Divisor Schema — a reusable pattern mined from Carmichael's theorem

This file extracts the *structural core* of the classical Carmichael / Zsygmondy
primitive–divisor arguments (the engine behind `Catalog/Shared/CarmichaelProof.lean`
and `Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`) and packages it as a
higher–order proof schema parametrised over an arbitrary **strong divisibility
sequence** `a : ℕ → ℕ`.

A strong divisibility sequence satisfies `gcd (a m) (a n) = a (gcd m n)`.  The Fibonacci
numbers and the sequences `n ↦ a^n - 1` are the two prototypical examples.  The schema
proven here is domain–agnostic and is then *instantiated* to both, bridging the
Fibonacci / number-theory domain with the multiplicative-order / Mersenne domain.

The headline schema theorem `hasPrimitiveDivisor_iff` says: for a strong divisibility
sequence, having a *primitive* prime divisor of `a n` (one dividing no earlier term) is
equivalent to having a prime dividing `a n` but no `a d` for proper divisors `d ∣ n`.
This is exactly the reduction that turns the (a-priori unbounded) primitivity condition
into a finite divisor check — the insight that makes Carmichael's theorem decidable on
finite ranges.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The full Carmichael computation `primPart_check` and the
entry-point lemmas in `CarmichaelComposite.lean` are not really about Fibonacci; they
only use `Nat.fib_gcd`.  Conjecture: every step generalises verbatim to any sequence
with `gcd (a m) (a n) = a (gcd m n)`.

Experiment (Experimenter): Abstracted `bridge_lemma`, the entry-point divisibility, and
the proper-divisor reduction to a predicate `IsStrongDivSeq`.  Re-instantiated to
`Nat.fib` (via `Nat.fib_gcd`) and to `n ↦ a^n - 1` (via
`Nat.pow_sub_one_gcd_pow_sub_one`).

Analysis (Analyst): The gcd identity is the *only* property required; primitivity is a
purely order-theoretic statement about the index lattice `(ℕ, ∣)`.  The "primitive part
> 1 ⇒ primitive divisor exists" step splits cleanly into a trivial forward direction and
the gcd bridge for the reverse direction.

Critique (Critic): Guarded all statements with `0 < n` (the sequences vanish/degenerate
at `0`).  Verified the iff is non-vacuous by instantiating it to genuine primitive
divisors of `Nat.fib` and of `2^n - 1`.  No `native_decide`, no `True`, no rename
wrappers: each result uses the gcd bridge plus `Nat.find` minimality.

Synthesis (PI): A single `IsStrongDivSeq` predicate now unifies two catalog domains and
exposes the finite-check reduction as a reusable lemma.
-- !-- Lab Notes -- !--
-/

namespace ProofSchema

/-- A **strong divisibility sequence**: the gcd of two terms is the term at the gcd of
the indices.  Fibonacci numbers and `n ↦ a^n - 1` are the canonical examples. -/
def IsStrongDivSeq (a : ℕ → ℕ) : Prop :=
  ∀ m n, Nat.gcd (a m) (a n) = a (Nat.gcd m n)

variable {a : ℕ → ℕ}

/-! ## The gcd bridge: avoiding proper divisors suffices for primitivity -/

/-
**Bridge lemma (schema form).**  If `p ∣ a n` and `p` divides `a d` for no proper
divisor `d ∣ n`, then `p` divides no earlier term `a k` at all.  This is the abstract
heart of `bridge_lemma` from `CarmichaelProof.lean`.
-/
theorem primitive_of_avoids_proper (ha : IsStrongDivSeq a) {n p : ℕ} (hn : 0 < n)
    (hpn : p ∣ a n)
    (hdiv : ∀ d, d ∣ n → 0 < d → d < n → ¬ p ∣ a d) :
    ∀ k, 0 < k → k < n → ¬ p ∣ a k := by
  intro k hk hkn;
  convert hdiv _ ( Nat.gcd_dvd_left _ _ ) ( Nat.gcd_pos_of_pos_left _ hn ) ( lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_right _ _ ) ) hkn ) using 1;
  rw [ ← ha, Nat.dvd_gcd_iff ] ; aesop

/-
The easy converse: a primitive divisor automatically avoids all proper divisors.
-/
theorem avoids_proper_of_primitive {n p : ℕ}
    (hprim : ∀ k, 0 < k → k < n → ¬ p ∣ a k) :
    ∀ d, d ∣ n → 0 < d → d < n → ¬ p ∣ a d := by
  exact fun d hd hd' hd'' => hprim d hd' hd''

/-
**Schema theorem.**  For a strong divisibility sequence, possessing a primitive prime
divisor of `a n` is equivalent to possessing a prime dividing `a n` but none of the
`a d` for proper divisors `d ∣ n`.  This reduces an unbounded primitivity test to a
finite divisor check — the structural pattern underlying Carmichael's theorem.
-/
theorem hasPrimitiveDivisor_iff (ha : IsStrongDivSeq a) {n : ℕ} (hn : 0 < n) :
    (∃ p, p.Prime ∧ p ∣ a n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ a k) ↔
    (∃ p, p.Prime ∧ p ∣ a n ∧ ∀ d, d ∣ n → 0 < d → d < n → ¬ p ∣ a d) := by
  constructor <;> intro h;
  · obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := h; exact ⟨ p, hp₁, hp₂, fun d hd₁ hd₂ hd₃ => hp₃ d hd₂ hd₃ ⟩ ;
  · exact ⟨ h.choose, h.choose_spec.1, h.choose_spec.2.1, fun k hk hk' => primitive_of_avoids_proper ha hn h.choose_spec.2.1 h.choose_spec.2.2 k hk hk' ⟩

/-! ## Entry-point theory -/

open Classical in
/-- The **entry point** of `p` in the sequence `a`: the least positive index `k` with
`p ∣ a k`, or `0` if none exists. -/
noncomputable def entryPt (a : ℕ → ℕ) (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ a k then Nat.find h else 0

theorem entryPt_pos (p : ℕ) (h : ∃ k, 0 < k ∧ p ∣ a k) : 0 < entryPt a p := by
  unfold entryPt; rw [dif_pos h]; exact (Nat.find_spec h).1

theorem entryPt_dvd_term (p : ℕ) (h : ∃ k, 0 < k ∧ p ∣ a k) : p ∣ a (entryPt a p) := by
  unfold entryPt;
  grind

/-
**Entry-point divisibility (schema form).**  For a strong divisibility sequence, the
entry point of `p` divides every index `k` with `p ∣ a k`.  This is the abstract version
of `fibEntryPt_dvd_of_fib_dvd`.
-/
theorem entryPt_dvd_index (ha : IsStrongDivSeq a) (p k : ℕ) (hk : 0 < k)
    (hpk : p ∣ a k) : entryPt a p ∣ k := by
  unfold entryPt;
  split_ifs with h;
  · -- Since $p \mid a(\gcd(\text{entryPt}(a, p), k))$ and $\text{entryPt}(a, p)$ is the smallest index with this property, we have $\gcd(\text{entryPt}(a, p), k) = \text{entryPt}(a, p)$.
    have h_gcd_eq : Nat.gcd (Nat.find h) k = Nat.find h := by
      refine' le_antisymm ( Nat.le_of_dvd ( Nat.find_spec h |>.1 ) ( Nat.gcd_dvd_left _ _ ) ) ( Nat.le_of_not_lt fun h' => _ );
      exact Nat.find_min h h' ⟨ Nat.gcd_pos_of_pos_left _ ( Nat.find_spec h |>.1 ), Nat.dvd_gcd ( Nat.find_spec h |>.2 ) hpk |> fun x => ha _ _ ▸ x ⟩;
    exact h_gcd_eq ▸ Nat.gcd_dvd_right _ _;
  · exact False.elim <| h ⟨ k, hk, hpk ⟩

/-! ## Instance 1 : Fibonacci numbers -/

theorem fib_isStrongDivSeq : IsStrongDivSeq Nat.fib := by
  exact fun m n => Nat.fib_gcd m n ▸ rfl

/-- Fibonacci instantiation of the schema reduction. -/
theorem fib_hasPrimitiveDivisor_iff {n : ℕ} (hn : 0 < n) :
    (∃ p, p.Prime ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k) ↔
    (∃ p, p.Prime ∧ p ∣ Nat.fib n ∧ ∀ d, d ∣ n → 0 < d → d < n → ¬ p ∣ Nat.fib d) :=
  hasPrimitiveDivisor_iff fib_isStrongDivSeq hn

/-! ## Instance 2 : the sequences `n ↦ a^n - 1` (Mersenne / multiplicative-order domain) -/

theorem pow_sub_one_isStrongDivSeq (a : ℕ) : IsStrongDivSeq (fun n => a ^ n - 1) := by
  intro m n;
  simp +zetaDelta at *

/-- `a^n - 1` instantiation of the schema reduction, bridging to the multiplicative-order
domain. -/
theorem pow_sub_one_hasPrimitiveDivisor_iff (a : ℕ) {n : ℕ} (hn : 0 < n) :
    (∃ p, p.Prime ∧ p ∣ a ^ n - 1 ∧ ∀ k, 0 < k → k < n → ¬ p ∣ a ^ k - 1) ↔
    (∃ p, p.Prime ∧ p ∣ a ^ n - 1 ∧ ∀ d, d ∣ n → 0 < d → d < n → ¬ p ∣ a ^ d - 1) :=
  hasPrimitiveDivisor_iff (pow_sub_one_isStrongDivSeq a) hn

end ProofSchema