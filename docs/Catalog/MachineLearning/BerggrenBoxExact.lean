import MachineLearning.BerggrenBoxDensity

/-!
# Cycle 3: an exact lattice-point formula for the box count

The `Θ(H)` bounds of `MachineLearning.BerggrenBoxDensity` come from two one-sided
injections.  This file upgrades them to an **exact identity**: the Berggren-generated
triples inside the cube `[1,H]³` are in bijection with the *visible lattice points of
opposite parity inside the quarter disc of radius `√H`*,

`euclidBox H = {(m,n) : 0 < n < m,  m + n odd,  gcd(m,n) = 1,  m² + n² ≤ H}`,

the bijection being Euclid's map `(m,n) ↦ (m² - n², 2mn, m² + n²)`.  Note that the cube
condition on all three coordinates collapses to the single condition `m² + n² ≤ H` on the
hypotenuse: the legs never obstruct.

Consequently the Berggren counting function is exactly a Gauss circle problem for a
coprimality-and-parity-restricted lattice, whose main term is `(1/2π)·H`; the numerics in
`ComputationalEvidence.md` confirm the ratio `#(boxNode H)/H → 0.1591…`.
-/

namespace BerggrenStars

open Finset

/-- Visible lattice points of opposite parity in the quarter disc of radius `√H`. -/
def euclidBox (H : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.Icc 1 H ×ˢ Finset.Icc 1 H).filter fun p =>
    p.2 < p.1 ∧ (p.1 + p.2) % 2 = 1 ∧ Nat.gcd p.1 p.2 = 1 ∧ p.1 * p.1 + p.2 * p.2 ≤ H

theorem mem_euclidBox {H : ℕ} {p : ℕ × ℕ} :
    p ∈ euclidBox H ↔ 1 ≤ p.2 ∧ p.2 < p.1 ∧ (p.1 + p.2) % 2 = 1 ∧
      Nat.gcd p.1 p.2 = 1 ∧ p.1 * p.1 + p.2 * p.2 ≤ H := by
  simp only [euclidBox, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  constructor
  · rintro ⟨⟨⟨-, -⟩, h3, -⟩, h5, h6, h7, h8⟩
    exact ⟨h3, h5, h6, h7, h8⟩
  · rintro ⟨h1, h2, h3, h4, h5⟩
    have hm : p.1 ≤ H := by nlinarith
    have hn : p.2 ≤ H := by nlinarith
    exact ⟨⟨⟨by omega, hm⟩, h1, hn⟩, h2, h3, h4, h5⟩

/-- **Exact lattice-point formula.**  Euclid's map is a bijection from the visible
opposite-parity lattice points of the quarter disc of radius `√H` onto the
Berggren-generated triples of the cube `[1,H]³`. -/
theorem card_euclidBox_eq_card_boxNode (H : ℕ) : (euclidBox H).card = (boxNode H).card := by
  refine Finset.card_bij (fun p _ => euclidTriple (p.1 : ℤ) (p.2 : ℤ)) ?_ ?_ ?_
  · -- well defined
    intro p hp
    obtain ⟨h1, h2, h3, h4, h5⟩ := mem_euclidBox.mp hp
    have hn : (0 : ℤ) < (p.2 : ℤ) := by exact_mod_cast h1
    have hnm : ((p.2 : ℤ)) < (p.1 : ℤ) := by exact_mod_cast h2
    have hpar : IsParam (p.1 : ℤ) (p.2 : ℤ) := by
      refine ⟨hn, hnm, by simpa using h4, ?_⟩
      rw [Int.odd_iff]
      omega
    have hbound : (p.1 : ℤ) ^ 2 + (p.2 : ℤ) ^ 2 ≤ (H : ℤ) := by
      have : ((p.1 * p.1 + p.2 * p.2 : ℕ) : ℤ) ≤ (H : ℤ) := by exact_mod_cast h5
      push_cast at this
      nlinarith [this]
    rw [mem_boxNode]
    refine ⟨?_, param_isNode hpar⟩
    rw [mem_box]
    simp only [euclidTriple]
    exact ⟨⟨by nlinarith, by nlinarith⟩, ⟨by nlinarith, by nlinarith⟩,
      ⟨by nlinarith, by nlinarith⟩⟩
  · -- injective
    intro p hp q hq hpq
    obtain ⟨h1, h2, -, -, -⟩ := mem_euclidBox.mp hp
    obtain ⟨g1, g2, -, -, -⟩ := mem_euclidBox.mp hq
    have hm : (0 : ℤ) < (p.1 : ℤ) := by exact_mod_cast Nat.lt_of_lt_of_le h1 (le_of_lt h2)
    have hn : (0 : ℤ) < (p.2 : ℤ) := by exact_mod_cast h1
    have hm' : (0 : ℤ) < (q.1 : ℤ) := by exact_mod_cast Nat.lt_of_lt_of_le g1 (le_of_lt g2)
    have hn' : (0 : ℤ) < (q.2 : ℤ) := by exact_mod_cast g1
    obtain ⟨e1, e2⟩ := euclidTriple_injective hm hn hm' hn' hpq
    exact Prod.ext (by exact_mod_cast e1) (by exact_mod_cast e2)
  · -- surjective
    intro v hv
    obtain ⟨hbox, hnode⟩ := mem_boxNode.mp hv
    obtain ⟨m, n, hpar, rfl⟩ := isNode_param hnode
    have hm := hpar.mpos
    have hn := hpar.npos
    have hnm := hpar.lt
    have hcH : (euclidTriple m n).2.2 ≤ (H : ℤ) := (mem_box.mp hbox).2.2.2
    simp only [euclidTriple] at hcH
    refine ⟨(m.toNat, n.toNat), ?_, ?_⟩
    · rw [mem_euclidBox]
      refine ⟨by omega, by omega, ?_, ?_, ?_⟩
      · have := hpar.par
        rw [Int.odd_iff] at this
        omega
      · have hg : Int.gcd m n = 1 := hpar.cop
        have hmt : ((m.toNat : ℤ)) = m := Int.toNat_of_nonneg hm.le
        have hnt : ((n.toNat : ℤ)) = n := Int.toNat_of_nonneg hn.le
        have h' : Int.gcd ((m.toNat : ℤ)) ((n.toNat : ℤ)) = 1 := by rw [hmt, hnt]; exact hg
        rwa [Int.gcd_natCast_natCast] at h'
      · have hmt : ((m.toNat : ℤ)) = m := Int.toNat_of_nonneg hm.le
        have hnt : ((n.toNat : ℤ)) = n := Int.toNat_of_nonneg hn.le
        have hcast : ((m.toNat * m.toNat + n.toNat * n.toNat : ℕ) : ℤ) = m ^ 2 + n ^ 2 := by
          push_cast [hmt, hnt]; ring
        have : ((m.toNat * m.toNat + n.toNat * n.toNat : ℕ) : ℤ) ≤ (H : ℤ) := by
          rw [hcast]; exact hcH
        exact_mod_cast this
    · have hmt : ((m.toNat : ℤ)) = m := Int.toNat_of_nonneg hm.le
      have hnt : ((n.toNat : ℤ)) = n := Int.toNat_of_nonneg hn.le
      simp only [hmt, hnt]

/-- The `Θ(H)` estimate, restated for the lattice-point count. -/
theorem card_euclidBox_theta (H : ℕ) (hH : 32 ≤ H) :
    H ≤ 128 * (euclidBox H).card ∧ (euclidBox H).card ≤ H := by
  rw [card_euclidBox_eq_card_boxNode]
  exact boxNode_card_theta H hH

end BerggrenStars