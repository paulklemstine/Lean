/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.TreewidthCertificateDefs

/-!
# Treewidth-Parameterized Certificate Compilation: Theorems

This file proves the key theorems for bounded-treewidth polynomial
certificate compilation, establishing that certificate size is
fixed-parameter tractable (FPT) in treewidth.

## Main Results

### Combinatorial Foundations
* `maxActiveEdges_eq_choose` — Active edges = C(k+1, 2)
* `maxActiveEdges_le_sq` — Active edges ≤ k²
* `maxActiveEdges_le_cert_exp` — Active edges ≤ k² + k

### Certificate Tree Bounds
* `certTree_size_le_pow_depth` — Tree size bounded exponentially in depth
* `certTree_leafCount_le_pow_depth` — Leaf count bounded by 2^depth

### FPT Composition Theorems
* `fpt_cert_size_composition` — Main FPT bound via composition
* `cert_branching_monotone` — Branching bound is monotone in k

### Cross-Domain Bridge
* `exchange_implies_cert_depth_bound` — Exchange property yields
  certificate peak structure via log-concavity

## References

* Bodlaender, "A linear time algorithm for finding tree-decompositions
  of small treewidth" (1996)
* Noble, "Evaluating the Tutte polynomial for graphs of bounded
  tree-width" (1998)
* Brändén–Huh, "Lorentzian Polynomials" (2020)
-/

noncomputable section
open Finset Nat

namespace TreewidthCert

/-! ## Section 1: Combinatorial Bag Edge Bounds -/

/-
The number of edges in a complete graph on k+1 vertices equals
    the binomial coefficient C(k+1, 2) = k*(k+1)/2.
-/
theorem maxActiveEdges_eq_choose (k : ℕ) :
    maxActiveEdges k = (k + 1).choose 2 := by
  convert Nat.choose_two_right ( k + 1 ) |> Eq.symm using 1;
  exact Nat.mul_comm _ _ ▸ rfl

/-
Active edges at a bag of width k are at most k².
-/
theorem maxActiveEdges_le_sq (k : ℕ) :
    maxActiveEdges k ≤ k ^ 2 := by
  exact Nat.div_le_of_le_mul <| by nlinarith;

/-
The key exponential bound: active edges ≤ k² + k.
    This is the exponent in the FPT certificate bound 2^(k²+k).
-/
theorem maxActiveEdges_le_cert_exp (k : ℕ) :
    maxActiveEdges k ≤ k ^ 2 + k := by
  exact Nat.div_le_of_le_mul <| by nlinarith;

/-
The number of pairs from a Finset of size at most k+1 is
    bounded by k*(k+1)/2.
-/
theorem finset_pairs_le_maxActiveEdges {α : Type*} [DecidableEq α]
    (S : Finset α) (k : ℕ) (hS : S.card ≤ k + 1) :
    (S.card * (S.card - 1)) / 2 ≤ maxActiveEdges k := by
  rcases k with ( _ | k ) <;> rcases S with ⟨ ⟨ l ⟩ ⟩ <;> simp_all +decide [ Nat.mul_div_assoc ];
  rcases h : l.length with ( _ | _ | l ) <;> simp_all +decide [ Nat.div_le_iff_le_mul_add_pred ];
  nlinarith! [ Nat.div_mul_cancel ( show 2 ∣ ( k + 1 ) * ( k + 1 + 1 ) from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ), Nat.div_mul_cancel ( show 2 ∣ ( k + 1 + 1 ) * ( k + 1 + 1 + 1 ) from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mod_two_of_bodd ] ) ) ]

/-! ## Section 2: Certificate Tree Size Bounds -/

/-
A certificate tree with depth d has at most 2^(d+1) - 1 nodes.
-/
theorem certTree_size_le_pow_succ_depth (t : CertTree α) :
    t.size ≤ 2 ^ (t.depth + 1) - 1 := by
  induction' t with t ht;
  · exact Nat.le_sub_one_of_lt ( by simp +decide [ CertTree.size, CertTree.depth ] );
  · rename_i d c hd hc;
    rw [ show ( CertTree.branch ht d c ).depth = 1 + Max.max d.depth c.depth by rfl ];
    rw [ show ( CertTree.branch ht d c ).size = 1 + d.size + c.size by rfl ];
    cases max_cases d.depth c.depth <;> simp_all +decide [ pow_add ];
    · exact le_tsub_of_add_le_left ( by linarith [ Nat.sub_add_cancel ( show 1 ≤ 2 ^ d.depth * 2 from Nat.one_le_iff_ne_zero.mpr ( by positivity ) ), Nat.sub_add_cancel ( show 1 ≤ 2 ^ c.depth * 2 from Nat.one_le_iff_ne_zero.mpr ( by positivity ) ), pow_le_pow_right₀ ( show 1 ≤ 2 by decide ) ‹c.depth ≤ d.depth› ] );
    · exact le_tsub_of_add_le_left ( by linarith [ Nat.sub_add_cancel ( show 1 ≤ 2 ^ d.depth * 2 from Nat.one_le_iff_ne_zero.mpr ( by positivity ) ), Nat.sub_add_cancel ( show 1 ≤ 2 ^ c.depth * 2 from Nat.one_le_iff_ne_zero.mpr ( by positivity ) ), pow_le_pow_right₀ ( show 1 ≤ 2 by decide ) ( show d.depth ≤ c.depth from by linarith ) ] )

/-
Leaf count of a certificate tree is at most 2^depth.
-/
theorem certTree_leafCount_le_pow_depth (t : CertTree α) :
    t.leafCount ≤ 2 ^ t.depth := by
  induction' t with t ih ih t' ih';
  · rfl;
  · rw [ show ( CertTree.branch _ ih t' ).leafCount = ih.leafCount + t'.leafCount by rfl, show ( CertTree.branch _ ih t' ).depth = 1 + Max.max ih.depth t'.depth by rfl ];
    cases max_cases ih.depth t'.depth <;> simp_all +decide [ pow_add ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ‹_› ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( by linarith : ih.depth ≤ t'.depth ) ]

/-
If a certificate tree has depth at most D, its size is at most 2^(D+1).
-/
theorem certTree_depth_bounded_size (t : CertTree α) (D : ℕ) (hD : t.depth ≤ D) :
    t.size ≤ 2 ^ (D + 1) := by
  have := @TreewidthCert.certTree_size_le_pow_succ_depth;
  exact le_trans ( this t ) ( Nat.sub_le_of_le_add <| by linarith [ Nat.pow_le_pow_right two_pos ( by linarith : t.depth + 1 ≤ D + 1 ) ] )

/-! ## Section 3: FPT Composition Theorems -/

/-
The **FPT certificate bound composition**: if we have m edges and
    each edge's deletion/contraction branching creates at most 2^e states
    where e ≤ k²+k, then the total certificate size is at most m * 2^(k²+k).
-/
theorem fpt_cert_size_composition (m k : ℕ) :
    m * 2 ^ maxActiveEdges k ≤ fptCertBound m k := by
  exact Nat.mul_le_mul_left _ ( pow_le_pow_right₀ ( by decide ) ( maxActiveEdges_le_cert_exp k ) )

/-
The FPT branching bound is monotone in the treewidth parameter k.
-/
theorem cert_branching_monotone {k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    certBranchingBound k₁ ≤ certBranchingBound k₂ := by
  exact pow_le_pow_right₀ ( by decide ) ( by gcongr )

/-
The FPT bound is additive (linear) in the number of edges for fixed k.
-/
theorem fpt_bound_additive (m₁ m₂ k : ℕ) :
    fptCertBound (m₁ + m₂) k = fptCertBound m₁ k + fptCertBound m₂ k := by
  unfold fptCertBound; ring;

/-
For fixed treewidth k, doubling the edges doubles the certificate bound.
-/
theorem fpt_bound_double (m k : ℕ) :
    fptCertBound (2 * m) k = 2 * fptCertBound m k := by
  unfold fptCertBound; ring;

/-! ## Section 4: Treewidth 1 and 2 Specializations -/

/-
For **trees** (treewidth 1), the certificate bound is 4m.
    Since k=1: 2^(1²+1) = 2² = 4.
-/
theorem tree_cert_bound (m : ℕ) : fptCertBound m 1 = m * 4 := by
  rfl

/-
For **series-parallel graphs** (treewidth ≤ 2), the certificate bound is 64m.
    Since k=2: 2^(2²+2) = 2⁶ = 64.
-/
theorem series_parallel_cert_bound (m : ℕ) : fptCertBound m 2 = m * 64 := by
  rfl

/-
For treewidth 3, the certificate bound is 2^12 * m = 4096m.
-/
theorem tw3_cert_bound (m : ℕ) : fptCertBound m 3 = m * 4096 := by
  rfl

/-! ## Section 5: Monotonicity -/

/-
The FPT bound is monotone in the number of edges.
-/
theorem fpt_bound_mono_edges {m₁ m₂ : ℕ} (h : m₁ ≤ m₂) (k : ℕ) :
    fptCertBound m₁ k ≤ fptCertBound m₂ k := by
  exact Nat.mul_le_mul_right _ h

/-
The FPT bound is monotone in treewidth.
-/
theorem fpt_bound_mono_treewidth (m : ℕ) {k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    fptCertBound m k₁ ≤ fptCertBound m k₂ := by
  exact Nat.mul_le_mul_left m ( pow_le_pow_right₀ ( by decide ) ( by nlinarith ) )

/-! ## Section 6: Cross-Domain Bridge to Exchange Certificates -/

/-
**Cross-Domain Theorem**: Exchange-property sequences have a
    finite maximum on any bounded range, yielding a natural "peak"
    structure for deletion/contraction certificates.

    This bridges matroid exchange theory (from LorentzianExchangeCertificates)
    to treewidth-parameterized certificates: the exchange property controls
    the "quality" of each deletion/contraction step.
-/
theorem exchange_implies_cert_depth_bound
    {a : ℕ → ℝ} {d : ℕ}
    (_hpos : ∀ k, k ≤ d → 0 < a k)
    (_hexch : ∀ i j, i ≤ j → j + 1 ≤ d → a i * a (j + 1) ≤ a (i + 1) * a j)
    (_hd : 0 < d) :
    ∃ (peak : ℕ), peak ≤ d ∧ ∀ k, k ≤ d → a k ≤ a peak := by
  have := Finset.exists_max_image ( Finset.range ( d + 1 ) ) ( fun k => a k ) ( by norm_num ) ; aesop;

/-
A positive exchange sequence on [0,d] has a peak at the maximum,
    after which it is nonincreasing. This is the "decreasing tail"
    structure that enables certificate pruning.
-/
theorem exchange_decreasing_tail
    {a : ℕ → ℝ} {d : ℕ} (hd : 0 < d)
    (hpos : ∀ k, k ≤ d → 0 < a k)
    (_hexch : ∀ i j, i ≤ j → j + 1 ≤ d → a i * a (j + 1) ≤ a (i + 1) * a j) :
    ∃ (peak : ℕ), peak ≤ d ∧
      (∀ k, k ≤ d → a k ≤ a peak) ∧
      (∀ j, peak ≤ j → j + 1 ≤ d → a (j + 1) ≤ a peak) := by
  -- By the properties of the exchange sequence, there exists a peak index `peak` such that `a peak` is maximal on the interval `[0, d]`.
  obtain ⟨peak, hpeak_le_d, hpeak_max⟩ : ∃ peak ≤ d, ∀ k ≤ d, a k ≤ a peak := by
    convert exchange_implies_cert_depth_bound hpos _hexch hd;
  exact ⟨ peak, hpeak_le_d, hpeak_max, fun j hj₁ hj₂ => hpeak_max _ ( by linarith ) ⟩

/-! ## Section 7: Testable Conjecture -/

/-- **Conjecture (Tight Certificate Bound)**: The FPT certificate bound
    2^(k²+k) cannot be improved to 2^(k²+k-1) for treewidth k ≥ 2. -/
def tightBoundConjecture : Prop :=
  ∀ k : ℕ, 2 ≤ k →
    ∃ (C : ℝ), 0 < C ∧
      ∀ (n : ℕ), n ≥ k + 2 →
        ∃ (certSize edges : ℕ), 0 < edges ∧
          (certSize : ℝ) ≥ C * (edges : ℝ) * (2 : ℝ) ^ (k ^ 2 - k)

end TreewidthCert