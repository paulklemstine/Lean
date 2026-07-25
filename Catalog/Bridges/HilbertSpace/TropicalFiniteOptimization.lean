import Mathlib

/-!
# Tropical Finite Optimization Bridge

This file establishes the first compositional bridge between proof-theoretic
complexity, tropical/idempotent aggregation, and finite combinatorial coding
bounds. The core insight: conjunction-like aggregation in proof systems and
coding systems is controlled by tropical/idempotent minima, and finite search
spaces admit certified minimizers bounded by explicit cardinality inequalities.

## Main Results

* `tropical_finset_inf_le_of_mem` — the finite infimum (tropical n-ary sum)
  is bounded above by every participating cost.
* `tropical_pair_conjunction_bound` — binary tropical conjunction bound:
  `min a b ≤ a ∧ min a b ≤ b`.
* `exists_minimizer_fintype` — every real-valued function on a nonempty finite
  type admits a global minimizer.
* `exists_minimizer_fin` — specialization to `Fin n`, interfacing with matrix
  and circuit formalisms.
* `exists_codeword_with_cost_le_average` — pigeonhole-style averaging bound:
  some element achieves cost at most the mean.
* `finset_inf'_mono` — monotonicity of tropical aggregation under pointwise
  domination.
* `exists_minimizer_add_constant` — argmin stability under additive shifts.
* `exists_matrix_entry_minimizer` — existence of a minimal entry in a matrix.

## Cross-Domain Interpretation

- **Proof Theory**: `f : α → ℝ` is proof length / cut complexity /
  verification cost. The infimum is the best proof among finitely many
  candidates. The minimizer theorem certifies existence and universal
  optimality bounds.
- **Coding Theory / Cryptography**: `α` is the key/certificate/challenge
  space; `f` is verification or decoding cost. The minimizer theorem gives
  existence of an optimal witness in finite search.
- **Tropical / Idempotent Algebra**: `min` is tropical addition; finite
  infimum is n-ary tropical sum. These theorems are the monotonicity laws
  underlying tropical dynamic programming.
- **Operator Algebra / Matrix Methods**: On `Fin n → Fin n → ℝ`, entrywise
  minima become proto-spectral selection principles.

## References

This module extends the catalog theorems:
- `tropical_and_bound` (binary tropical bound)
- `proof_theoretic_crypto_bridge` (proof-theory ↔ crypto)
- `lawvere_proof_coding_theorem` (Kraft/Lawvere coding)
- `matrix_algebra_dim_bound` (dimensional bookkeeping)
-/

open Finset

namespace TropicalFiniteOptimization

/-! ## Core Tropical Aggregation -/

/-- **Tropical Finset Infimum Bound**: The infimum of a real-valued function
over a nonempty finite set is at most the function value at any member.

This is the n-ary generalization of `min a b ≤ a`. In tropical algebra,
this says the n-ary tropical sum is bounded by every summand. In proof
theory, the best proof cost among finitely many candidates is at most
the cost of any particular candidate. -/
theorem tropical_finset_inf_le_of_mem
    {α : Type} [DecidableEq α]
    (s : Finset α) (h : s.Nonempty) (f : α → ℝ)
    {a : α} (ha : a ∈ s) :
    s.inf' h f ≤ f a := by
  exact Finset.inf'_le f ha

/-- **Tropical Pair Conjunction Bound**: The binary tropical conjunction
(minimum) is bounded above by both components.

This extends `tropical_and_bound` (which states `min a b ≤ a`) to
include both directions simultaneously. In proof-theoretic semantics,
this says a conjunction never costs more than either conjunct. -/
theorem tropical_pair_conjunction_bound
    (a b : ℝ) :
    min a b ≤ a ∧ min a b ≤ b := by
  exact ⟨min_le_left a b, min_le_right a b⟩

/-! ## Existence of Minimizers on Finite Types -/

/-
**Existence of a Global Minimizer on Finite Types**: Every real-valued
function on a nonempty finite type admits a global minimizer.

This is the fundamental finite search theorem: proof/coding/crypto
resource semantics can be globally optimized over finite spaces. In
proof theory, this gives existence of an optimal proof in a finite
candidate set. In cryptography, this gives existence of an optimal
witness/key/certificate.
-/
theorem exists_minimizer_fintype
    {α : Type} [Fintype α] [DecidableEq α] [Nonempty α]
    (f : α → ℝ) :
    ∃ a : α, ∀ b : α, f a ≤ f b := by
  simpa using Finset.exists_min_image Finset.univ f ( Finset.univ_nonempty )

/-
**Existence of a Global Minimizer on `Fin n`**: Specialization to
`Fin n`, directly interfacing with matrix, circuit, and bounded
proof-search formalisms.

The `Fin n` formulation is especially valuable because it connects
naturally to matrix entries, circuit gates, and bounded witness sets
in cryptographic protocols.
-/
theorem exists_minimizer_fin
    (n : ℕ) (h : 0 < n) (f : Fin n → ℝ) :
    ∃ a : Fin n, ∀ b : Fin n, f a ≤ f b := by
  simpa using Finset.exists_min_image Finset.univ ( fun x => f x ) ⟨ ⟨ 0, h ⟩, Finset.mem_univ _ ⟩

/-! ## Averaging and Pigeonhole Bounds -/

/-
**Existence of a Below-Average Element**: In any nonempty finite type,
some element achieves cost at most the mean. This is a pigeonhole
principle for costs, fundamental to coding theory (Shannon-style
arguments) and proof complexity (average-case bounds).
-/
theorem exists_codeword_with_cost_le_average
    {α : Type} [Fintype α] [DecidableEq α] [Nonempty α]
    (f : α → ℝ) :
    ∃ a : α, f a ≤ (∑ x : α, f x) / Fintype.card α := by
  exact Exists.elim ( exists_minimizer_fintype f ) fun a ha => ⟨ a, by rw [ le_div_iff₀ ( Nat.cast_pos.mpr <| Fintype.card_pos ) ] ; simpa [ mul_comm ] using Finset.sum_le_sum fun b ( _ : b ∈ Finset.univ ) => ha b ⟩

/-! ## Monotonicity and Stability -/

/-
**Monotonicity of Tropical Aggregation**: If `f ≤ g` pointwise on a
finite set, then the tropical aggregate of `f` is at most that of `g`.

This is the order-theoretic monotonicity law underlying tropical
dynamic programming: if every branch cost decreases, the optimal
cost decreases.
-/
theorem finset_inf'_mono
    {α : Type} [DecidableEq α]
    (s : Finset α) (h : s.Nonempty)
    {f g : α → ℝ}
    (hfg : ∀ x ∈ s, f x ≤ g x) :
    s.inf' h f ≤ s.inf' h g := by
  simp +zetaDelta at *;
  -- For any $b \in s$, we can choose $i = b$ since $f b \leq g b$ by hypothesis.
  intros b hb
  use b, hb, hfg b hb

/-
**Argmin Stability under Additive Shift**: Adding a constant to every
cost does not change which element is the minimizer.

This is a basic but important invariance principle: proof/coding costs
measured relative to a baseline yield the same optimal choice.
-/
theorem exists_minimizer_add_constant
    {α : Type} [Fintype α] [DecidableEq α] [Nonempty α]
    (f : α → ℝ) (c : ℝ) :
    ∃ a : α, ∀ b : α, f a + c ≤ f b + c := by
  -- Use the fact that there exists an element `a` such that for all `b`, `f a ≤ f b` from `exists_minimizer_fintype`.
  obtain ⟨a, ha⟩ := exists_minimizer_fintype (fun x => f x);
  use a;
  intro b; exact (by simp [ha b])

/-! ## Matrix Entry Minimizer -/

/-
**Matrix Entry Minimizer**: Every matrix over `Fin n` (with `n > 0`)
admits a minimal entry. This concretizes the bridge to operator algebra
and finite-state verification landscapes.

Interpreting `M i j` as the cost of transitioning from state `i` to
state `j`, this theorem guarantees an optimal transition exists—the
foundation for tropical matrix multiplication and shortest-path
algorithms.
-/
theorem exists_matrix_entry_minimizer
    (n : ℕ) (h : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) :
    ∃ i j, ∀ i' j', M i j ≤ M i' j' := by
  simpa using Finset.exists_min_image Finset.univ ( fun p : Fin n × Fin n => M p.1 p.2 ) ⟨ ⟨ ⟨ 0, h ⟩, ⟨ 0, h ⟩ ⟩, Finset.mem_univ _ ⟩

/-! ## Bridge Corollaries -/

/-- **Proof Search Exists Minimizer**: Alias for `exists_minimizer_fintype`
emphasizing the proof-theoretic interpretation. Given a finite set of
proof candidates with real-valued costs, an optimal proof exists. -/
theorem proof_search_exists_minimizer
    {α : Type} [Fintype α] [DecidableEq α] [Nonempty α]
    (proofCost : α → ℝ) :
    ∃ optimalProof : α, ∀ candidate : α, proofCost optimalProof ≤ proofCost candidate :=
  exists_minimizer_fintype proofCost

/-- **Crypto Witness Exists Minimal Cost**: Alias for `exists_minimizer_fin`
emphasizing the cryptographic interpretation. Given `n > 0` possible
witnesses with real-valued verification costs, an optimal witness exists. -/
theorem crypto_witness_exists_minimal_cost
    (n : ℕ) (h : 0 < n) (verifyCost : Fin n → ℝ) :
    ∃ optimalWitness : Fin n, ∀ w : Fin n, verifyCost optimalWitness ≤ verifyCost w :=
  exists_minimizer_fin n h verifyCost

/-- **Lawvere Tropical Conjunction Control**: The tropical aggregation
of enriched hom-values over a finite candidate family is controlled
by every individual hom-value. This is a finite enriched Yoneda-style
control principle.

In Lawvere's framework, costs are enriched hom-values in `([0,∞], ≥, +)`.
This theorem says the best available morphism/certificate/proof
(the infimum) is at most as costly as any specific one. -/
theorem lawvere_tropical_conjunction_control
    {α : Type} [DecidableEq α]
    (candidates : Finset α) (h : candidates.Nonempty)
    (homCost : α → ℝ) {x : α} (hx : x ∈ candidates) :
    candidates.inf' h homCost ≤ homCost x :=
  tropical_finset_inf_le_of_mem candidates h homCost hx

end TropicalFiniteOptimization