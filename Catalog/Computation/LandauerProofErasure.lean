import Computation.ReversibleTropicalThermodynamics
import Computation.LandauerLowerBound

/-!
# Landauer's Principle for Mathematics: the Thermodynamics of Proof Erasure

Landauer's principle says that erasing one bit of information must dissipate at least
`k·T·log 2` of heat. This file applies that principle to **proof theory**, treating a
formal proof as a physical record of information.

A *proof object* of "length `n`" is modelled as a bitstring `Proof n := Fin n → Bool`
(the `2^n` distinct length-`n` derivations / certificates). The catalog's reversible
thermodynamics (`Computation.ReversibleTropicalThermodynamics`) and the deterministic
data-processing inequality (`Computation.LandauerLowerBound`) then yield precise
thermodynamic statements about proof transformation:

* **Proof normalisation is costly.** Collapsing all `2^n` length-`n` proofs of a theorem
  to a single canonical normal form erases exactly `n` bits, dissipating `k·T·n·log 2`
  heat (`proof_erasure_landauer_cost`). This is Landauer's law, read in the currency of
  proofs: *deleting derivational redundancy is thermodynamically irreversible.*

* **Lossless proof compression obeys a counting bound.** An injective (lossless) encoder
  of length-`n` proofs into `m` codewords forces `2^n ≤ m` (`lossless_proof_compression_card`).

* **No universal proof compressor exists.** There is *no* injection from the `2^n` length-`n`
  proofs into the set of *all strictly shorter* proofs, whose total count is only `2^n - 1`
  (`no_universal_proof_compressor`). This is an exact, constructive incompressibility
  theorem in the spirit of Kolmogorov complexity.

* **Reversible proof transformation is free.** A bijective rewriting of the proof space
  (a reversible derivation, e.g. an invertible renaming) dissipates *zero* heat
  (`reversible_proof_transform_free`), while *every* deterministic transformation
  dissipates a nonnegative amount (`proof_compression_nonneg_heat`).

## References
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Bennett, C.H. (1973). Logical reversibility of computation.
- Li, M. & Vitányi, P. (2008). An Introduction to Kolmogorov Complexity (incompressibility).
-/

noncomputable section

open Finset Function Real BigOperators LandauerLowerBound

namespace LandauerProofErasure

-- !-- Lab Notebook --!--
-- Hypothesis: Treating a proof as a physical bitstring record, Landauer's principle should
--   turn into exact thermodynamic statements about proof normalisation and compression:
--   normalising 2^n proofs to one canonical form must cost exactly n bits = k·T·n·log 2,
--   and there should be a hard counting obstruction to "universal" proof compression.
-- Result: Proved all four. The erasure cost is *exact* (an equality, not a bound); the
--   incompressibility theorem is constructive — it is a pure cardinality contradiction from
--   ∑_{k<n} 2^k = 2^n − 1 < 2^n, so it `decide`s on every concrete n.
-- Insight: The proof-theoretic content is entirely cardinality + the catalog's data-processing
--   inequality. "Reversible derivation = free" and "any derivation dissipates ≥ 0" are direct
--   specialisations of `landauer_lower_bound`(`_zero_of_injective`) to the proof space, showing
--   the bridge between proof transformation and heat is literally the entropy DPI.
-- Failure analysis: A first cut tried `Fintype.card_fun` inside `simp` to compute
--   card (Fin n → Bool); the lemma fired but was flagged unused. The robust route is the
--   dedicated `card_proof` lemma reused everywhere, keeping every downstream `rw` deterministic.
-- !-- end Lab Notebook --!--

/-- A formal proof object of length `n`, modelled as a length-`n` bitstring certificate.
There are `2^n` distinct such objects. -/
abbrev Proof (n : ℕ) := Fin n → Bool

-- !-- comment -- !--
-- There are exactly `2^n` distinct length-`n` proof records.
-- !-- comment -- !--
/-- There are exactly `2^n` length-`n` proofs. -/
theorem card_proof (n : ℕ) : Fintype.card (Proof n) = 2^n := by
  simp [Proof]

-- !-- comment -- !--
-- Proof normalisation = erasure: drop uniform→Dirac over 2^n proofs costs log(2^n)=n·log2.
-- !-- comment -- !--
/-- **Landauer cost of proof normalisation.** Collapsing all `2^n` length-`n` proofs of a
theorem to a single canonical normal form erases `n` bits of derivational information and
therefore dissipates exactly `k·T·n·log 2` of heat. -/
theorem proof_erasure_landauer_cost (n : ℕ) (normalForm : Proof n) (k T : ℝ) :
    k * T * (shannonEntropy (uniformDist (Proof n)) - shannonEntropy (diracDist normalForm))
      = k * T * (n * Real.log 2) := by
  have hcard : 0 < Fintype.card (Proof n) := by rw [card_proof]; exact Nat.two_pow_pos n
  rw [entropy_drop_uniform_erasure normalForm hcard, card_proof,
      show ((2 ^ n : ℕ) : ℝ) = (2 : ℝ) ^ n by push_cast; ring, Real.log_pow]

-- !-- comment -- !--
-- Lossless compression is injective, so pigeonhole forces 2^n ≤ m codewords.
-- !-- comment -- !--
/-- **Counting bound for lossless proof compression.** Any *lossless* (injective) encoding
of the `2^n` length-`n` proofs into `m` codewords must satisfy `2^n ≤ m`: you cannot
compress distinct proofs below their information content. -/
theorem lossless_proof_compression_card (n m : ℕ) (f : Proof n → Fin m)
    (hf : Function.Injective f) : 2 ^ n ≤ m := by
  have h := Fintype.card_le_of_injective f hf
  rwa [card_proof, Fintype.card_fin] at h

-- !-- comment -- !--
-- Incompressibility: the set of ALL strictly-shorter proofs has only ∑_{k<n}2^k = 2^n−1
-- elements, fewer than the 2^n length-n proofs, so no injection (compressor) can exist.
-- !-- comment -- !--
/-- **No universal proof compressor (constructive incompressibility).** There is no
injection from the `2^n` length-`n` proofs into the set of *all strictly shorter* proofs
`Σ k < n, Proof k`, because the latter has only `2^n - 1` elements. Hence no algorithm can
shorten *every* proof — a Kolmogorov-style incompressibility theorem for derivations. -/
theorem no_universal_proof_compressor (n : ℕ)
    (f : Proof n → ((k : Fin n) × Proof (k : ℕ))) (hf : Function.Injective f) : False := by
  have h := Fintype.card_le_of_injective f hf
  rw [card_proof, Fintype.card_sigma] at h
  simp only [card_proof] at h
  rw [Fin.sum_univ_eq_sum_range (fun k => 2 ^ k), Nat.geomSum_eq (by norm_num) n] at h
  have hpos : 0 < 2 ^ n := Nat.two_pow_pos n
  omega

-- !-- comment -- !--
-- Reversible derivation = free: an injective transform dissipates 0 heat (DPI equality case).
-- !-- comment -- !--
/-- **Reversible proof transformation is thermodynamically free.** A bijective (injective)
rewriting `f` of the proof space — a reversible derivation — dissipates exactly zero heat,
the equality case of Landauer's principle. -/
theorem reversible_proof_transform_free (n m : ℕ) (f : Proof n → Proof m)
    (hf : Function.Injective f) (k T : ℝ) :
    k * T * (shannonEntropy (uniformDist (Proof n))
        - shannonEntropy (pushforwardFun f (uniformDist (Proof n)))) = 0 :=
  landauer_lower_bound_zero_of_injective f (uniformDist (Proof n)) hf k T

-- !-- comment -- !--
-- Any deterministic derivation dissipates ≥ 0 heat: the data-processing inequality on the
-- uniform proof distribution.
-- !-- comment -- !--
/-- **Every deterministic proof transformation dissipates nonnegative heat.** Running any
deterministic transformation `f` on the uniform distribution over length-`n` proofs has
nonnegative Landauer cost; only the reversible ones achieve the zero boundary. -/
theorem proof_compression_nonneg_heat (n m : ℕ) (f : Proof n → Proof m)
    (k T : ℝ) (hk : 0 ≤ k) (hT : 0 ≤ T) :
    0 ≤ k * T * (shannonEntropy (uniformDist (Proof n))
        - shannonEntropy (pushforwardFun f (uniformDist (Proof n)))) := by
  apply landauer_lower_bound f (uniformDist (Proof n)) _ k T hk hT
  intro x; unfold uniformDist; positivity

end LandauerProofErasure

end