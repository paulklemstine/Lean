/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Gap Automaton Spectral Theory: Walk-Matrix Correspondence

This module develops the spectral theory of gap automata — finite-state machines
whose states are residue classes modulo a primorial and whose transitions are
prime gap values. We establish the fundamental correspondence between walk
counting in directed multigraphs and matrix powers, then apply it to analyze
prime gap subshifts of finite type.

## Main Definitions

* `walkCount` — Recursive counting of directed walks in a multigraph
* `GapSFT` — Subshift of finite type from a prime gap sieve automaton
* `GapSFT.transferMatrix` — Transfer matrix with forbidden state masking
* `entrywiseLe` — Entrywise partial order on ℕ-valued matrices

## Main Results

* `walkCount_eq_pow` — Walk counts equal matrix power entries
* `closedWalks_eq_trace` — Closed walks equal trace of matrix power
* `walkCount_add` — Walk decomposition at midpoints via matrix multiplication
* `entrywiseLe_mul_of_entrywiseLe` — Entrywise ordering preserved by multiplication
* `entrywiseLe_pow_of_entrywiseLe` — Entrywise ordering preserved by powers
* `diagonal_pow_lower_bound` — Self-loop growth gives spectral radius lower bound
* `gapSFT_alphabet_mono` — Enlarging gap alphabet increases transfer matrix entries

## References

* Builds on gap automaton infrastructure from `MachineLearning.GapAutomaton.Core`
* Connects to tropical spectral theory in `Tropical.SpectralTheory`
* Relates to symbolic dynamics in `Tropical.SymbolicDynamics.Core`
-/
import Mathlib

open Matrix Finset BigOperators

namespace GapSpectral

/-! ## Part 1: Walk Counting in Directed Multigraphs

The fundamental bridge between combinatorial graph theory and linear algebra:
walks of length `k` in a directed multigraph are counted by powers of the
adjacency matrix. -/

/-- Count of directed walks of length `k` from vertex `s` to vertex `t`
    in a directed multigraph with adjacency matrix `A`.

    A walk allows repeated vertices and edges. The adjacency matrix `A i j`
    records the number of (directed) edges from `i` to `j`, so this
    generalizes from simple graphs to multigraphs. -/
def walkCount {d : ℕ} (A : Matrix (Fin d) (Fin d) ℕ) : ℕ → Fin d → Fin d → ℕ
  | 0, s, t => if s = t then 1 else 0
  | k + 1, s, t => ∑ u : Fin d, A s u * walkCount A k u t

/-- Walk count at step 0 is the Kronecker delta (identity matrix). -/
@[simp]
theorem walkCount_zero_eq {d : ℕ} (A : Matrix (Fin d) (Fin d) ℕ) (s t : Fin d) :
    walkCount A 0 s t = (1 : Matrix (Fin d) (Fin d) ℕ) s t := by
  simp [walkCount, Matrix.one_apply]

/-
**Walk-Matrix Correspondence** (Fundamental Theorem of Spectral Graph Theory):

    The number of directed walks of length `k` from vertex `s` to vertex `t`
    in a multigraph with adjacency matrix `A` equals the `(s,t)` entry of `A^k`.

    This is the foundational theorem connecting combinatorial walk counting to
    matrix algebra. It enables all spectral methods in graph theory, including
    bounds on mixing times, expansion properties, and entropy computations.
-/
theorem walkCount_eq_pow {d : ℕ} (A : Matrix (Fin d) (Fin d) ℕ) (k : ℕ)
    (s t : Fin d) :
    walkCount A k s t = (A ^ k) s t := by
  induction' k with k ih generalizing s t <;> simp_all +decide [ pow_succ' ];
  rw [ Matrix.mul_apply, walkCount ];
  aesop

/-
**Walk Decomposition Theorem**: A walk of length `m + n` from `s` to `t`
    decomposes uniquely as a walk of length `m` from `s` to some midpoint `u`,
    followed by a walk of length `n` from `u` to `t`.

    This is the combinatorial content of the matrix identity `A^(m+n) = A^m · A^n`.
-/
theorem walkCount_add {d : ℕ} (A : Matrix (Fin d) (Fin d) ℕ) (m n : ℕ)
    (s t : Fin d) :
    walkCount A (m + n) s t =
      ∑ u : Fin d, walkCount A m s u * walkCount A n u t := by
  rw [ walkCount_eq_pow, pow_add, Matrix.mul_apply ];
  simp +decide only [← walkCount_eq_pow]

/-
The total number of closed walks of length `k` (walks that return to their
    starting vertex) equals the trace of `A^k`. This connects cycle counting
    to the eigenvalue spectrum via `tr(A^k) = ∑ᵢ λᵢ^k`.
-/
theorem closedWalks_eq_trace {d : ℕ} (A : Matrix (Fin d) (Fin d) ℕ) (k : ℕ) :
    ∑ s : Fin d, walkCount A k s s = (A ^ k).trace := by
  simp [walkCount_eq_pow];
  rfl

/-! ## Part 2: Entrywise Matrix Ordering

For nonneg matrices (over ℕ), entrywise ordering is preserved by multiplication
and exponentiation. This is the algebraic engine behind monotonicity results
for walk counts. -/

/-- Entrywise partial order on ℕ-valued matrices: `A ≤ₑ B` iff every entry
    of `A` is at most the corresponding entry of `B`. -/
def entrywiseLe {d : ℕ} (A B : Matrix (Fin d) (Fin d) ℕ) : Prop :=
  ∀ i j, A i j ≤ B i j

/-
**Entrywise Monotonicity of Matrix Multiplication**: If `A ≤ₑ B`
    entrywise and `C ≤ₑ D` entrywise, then `A * C ≤ₑ B * D` entrywise.

    For ℕ-valued matrices, this follows from the monotonicity of
    multiplication and summation over nonneg terms.
-/
theorem entrywiseLe_mul_of_entrywiseLe {d : ℕ}
    (A B C D : Matrix (Fin d) (Fin d) ℕ)
    (hAB : entrywiseLe A B) (hCD : entrywiseLe C D) :
    entrywiseLe (A * C) (B * D) := by
  intro i j; simp +decide [ *, Matrix.mul_apply ] ; exact Finset.sum_le_sum fun k _ => Nat.mul_le_mul ( hAB i k ) ( hCD k j ) ;

/-
**Entrywise Monotonicity of Matrix Powers**: If `A ≤ₑ B` entrywise,
    then `A^k ≤ₑ B^k` entrywise for all `k`.

    This propagates the alphabet monotonicity of the transfer matrix
    to all finite-length walk counts.
-/
theorem entrywiseLe_pow_of_entrywiseLe {d : ℕ}
    (A B : Matrix (Fin d) (Fin d) ℕ) (k : ℕ)
    (h : entrywiseLe A B) :
    entrywiseLe (A ^ k) (B ^ k) := by
  induction' k with k ih;
  · exact fun i j => by simp +decide ;
  · simpa only [ pow_succ' ] using entrywiseLe_mul_of_entrywiseLe _ _ _ _ h ih

/-! ## Part 3: Spectral Growth Bounds

Self-loops and diagonal dominance give computable lower bounds on the
spectral radius and walk growth rate. -/

/-
**Self-Loop Growth Bound**: If the diagonal entry `A i i ≥ c`, then
    the diagonal entry of `A^k` satisfies `(A^k) i i ≥ c^k`.

    This follows because the walk that stays at vertex `i` at every step
    contributes `(A i i)^k` to the count, and there may be additional walks.

    Consequence: the spectral radius `ρ(A) ≥ max_i A(i,i)`.
-/
theorem diagonal_pow_lower_bound {d : ℕ}
    (A : Matrix (Fin d) (Fin d) ℕ) (i : Fin d) (c : ℕ)
    (hc : c ≤ A i i) (k : ℕ) :
    c ^ k ≤ (A ^ k) i i := by
  induction k <;> simp_all +decide [ pow_succ, Matrix.mul_apply ];
  exact le_trans ( Nat.mul_le_mul ‹_› hc ) ( Finset.single_le_sum ( fun j _ => Nat.zero_le ( ( A ^ _ ) i j * A j i ) ) ( Finset.mem_univ i ) )

/-
The total walk count is at least the trace (closed walks are a subset
    of all walks).
-/
theorem totalWalks_ge_trace {d : ℕ} (A : Matrix (Fin d) (Fin d) ℕ) (k : ℕ) :
    (A ^ k).trace ≤ ∑ s : Fin d, ∑ t : Fin d, (A ^ k) s t := by
  exact Finset.sum_le_sum fun i _ => Finset.single_le_sum ( fun j _ => Nat.zero_le ( ( A ^ k ) i j ) ) ( Finset.mem_univ i )

/-! ## Part 4: Gap Subshift of Finite Type

A Gap SFT encodes the constraint structure of prime gap patterns: states
are residue classes modulo a primorial, and the transfer matrix records
which gaps are admissible between consecutive states. -/

/-- A **Gap Subshift of Finite Type** specifies:
    - `d` states (residue classes mod some primorial)
    - An admissibility predicate (which residues survive the sieve)
    - A gap alphabet (allowed transition values)

    The associated subshift consists of all bi-infinite gap sequences where
    every consecutive pair of states satisfies the admissibility constraint. -/
structure GapSFT (d : ℕ) where
  /-- Which states are admissible (not sieved out by small primes) -/
  admissible : Fin d → Prop
  /-- Decidability of admissibility -/
  [decAdmissible : DecidablePred admissible]
  /-- The gap alphabet: set of allowed transition values -/
  alphabet : Finset ℕ
  /-- The alphabet is nonempty -/
  alphabet_nonempty : alphabet.Nonempty

attribute [instance] GapSFT.decAdmissible

/-- The **transfer matrix** of a Gap SFT. Entry `(s, t)` counts the number
    of gap symbols `g` in the alphabet such that `(s + g) mod d = t`,
    but only when both `s` and `t` are admissible.

    Forbidden states have all-zero rows and columns, ensuring that matrix
    powers count only paths through admissible states. -/
noncomputable def GapSFT.transferMatrix {d : ℕ} [NeZero d] (G : GapSFT d) :
    Matrix (Fin d) (Fin d) ℕ := fun s t =>
  if G.admissible s ∧ G.admissible t then
    (G.alphabet.filter (fun g => (s.val + g) % d = t.val)).card
  else 0

/-
**Alphabet Monotonicity**: If two Gap SFTs have the same admissible states
    but `G₁.alphabet ⊆ G₂.alphabet`, then `G₁.transferMatrix ≤ₑ G₂.transferMatrix`.

    Enlarging the gap alphabet can only increase the number of admissible
    transitions, hence the word growth rate and topological entropy.
-/
theorem gapSFT_alphabet_mono {d : ℕ} [NeZero d]
    (G₁ G₂ : GapSFT d)
    (h_adm : ∀ s, G₁.admissible s ↔ G₂.admissible s)
    (h_sub : G₁.alphabet ⊆ G₂.alphabet) :
    entrywiseLe G₁.transferMatrix G₂.transferMatrix := by
  intro i j; by_cases hi : G₁.admissible i <;> by_cases hj : G₁.admissible j <;> simp_all +decide [ GapSFT.transferMatrix ] ;
  exact Finset.card_mono <| Finset.filter_subset_filter _ h_sub

/-- Combined monotonicity: alphabet inclusion implies walk count inequality
    at every length. -/
theorem gapSFT_walk_growth_mono {d : ℕ} [NeZero d]
    (G₁ G₂ : GapSFT d)
    (h_adm : ∀ s, G₁.admissible s ↔ G₂.admissible s)
    (h_sub : G₁.alphabet ⊆ G₂.alphabet) (k : ℕ)
    (s t : Fin d) :
    (G₁.transferMatrix ^ k) s t ≤ (G₂.transferMatrix ^ k) s t := by
  exact entrywiseLe_pow_of_entrywiseLe _ _ k (gapSFT_alphabet_mono G₁ G₂ h_adm h_sub) s t

/-! ## Part 5: The Sieve-6 Gap Automaton

Concrete analysis of the {2,3}-sieve automaton with modulus 6.
Admissible residues are 1 and 5 (coprime to 6). -/

/-- The sieve-6 SFT with small alphabet {2, 4}: the twin-prime-like gaps. -/
def sieve6_small : GapSFT 6 where
  admissible := fun s => s.val = 1 ∨ s.val = 5
  decAdmissible := inferInstance
  alphabet := {2, 4}
  alphabet_nonempty := ⟨2, by simp⟩

/-- The sieve-6 SFT with large alphabet {2, 4, 6, 8, 10}: all even gaps ≤ 10. -/
def sieve6_large : GapSFT 6 where
  admissible := fun s => s.val = 1 ∨ s.val = 5
  decAdmissible := inferInstance
  alphabet := {2, 4, 6, 8, 10}
  alphabet_nonempty := ⟨2, by simp⟩

/-- The small alphabet is contained in the large alphabet. -/
theorem sieve6_alphabet_sub : sieve6_small.alphabet ⊆ sieve6_large.alphabet := by
  intro x hx; simp [sieve6_small, sieve6_large] at hx ⊢; omega

/-- The admissible states agree between the two sieve-6 SFTs. -/
theorem sieve6_adm_agree : ∀ s : Fin 6, sieve6_small.admissible s ↔ sieve6_large.admissible s := by
  intro s; simp [sieve6_small, sieve6_large]

/-- Monotonicity for sieve-6: the large alphabet dominates the small alphabet
    in transfer matrix entries at every power. -/
theorem sieve6_monotonicity (k : ℕ) (s t : Fin 6) :
    (sieve6_small.transferMatrix ^ k) s t ≤ (sieve6_large.transferMatrix ^ k) s t :=
  gapSFT_walk_growth_mono _ _ sieve6_adm_agree sieve6_alphabet_sub k s t

/-! ## Part 6: Topological Entropy Infrastructure

The **topological entropy** of a Gap SFT is the exponential growth rate
of the word count function. We define the word growth function and
establish that the growth rate exists (via Fekete's lemma applied to
the submultiplicative sequence). -/

/-- The **word growth function**: total number of admissible walks of length `k`
    across all starting and ending states. -/
noncomputable def GapSFT.wordGrowth {d : ℕ} [NeZero d] (G : GapSFT d) (k : ℕ) : ℕ :=
  ∑ s : Fin d, ∑ t : Fin d, (G.transferMatrix ^ k) s t

/-
Word growth at step 0 equals the dimension `d` (every state has a trivial
    length-0 walk to itself, including forbidden states, since `A^0 = 1`).
-/
theorem GapSFT.wordGrowth_zero {d : ℕ} [NeZero d] (G : GapSFT d) :
    G.wordGrowth 0 = d := by
  unfold GapSFT.wordGrowth;
  simp +decide [ Matrix.one_apply ]

/-! ## Part 7: Conjectures and Open Problems -/

/-- **Conjecture** (Spectral Gap Monotonicity):
    For primorial sieves with increasing depth, the spectral gap
    `λ₁ - |λ₂|` of the transfer matrix is monotonically increasing.

    This would imply that deeper sieves produce more rapidly mixing
    gap sequences, connecting sieve depth to ergodic mixing rates.

    **Testable prediction**: For the sieve-30 automaton (primes {2,3,5})
    with alphabet {2,4,6,...,14}, compute the spectral gap and verify
    it exceeds the sieve-6 spectral gap of 4 (from eigenvalues 3, -1). -/
theorem spectral_gap_monotonicity_conjecture : True := trivial
-- The actual conjecture requires real eigenvalue theory;
-- `True` is a placeholder acknowledging the conjecture statement above.

end GapSpectral