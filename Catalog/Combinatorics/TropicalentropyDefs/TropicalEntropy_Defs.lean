import Mathlib

/-!
# Tropical entropy: definitions

This module previously contained only a stray relative path pointing at a
non-existent file `Shared/TropicalEntropy/Defs.lean`.  It is reconstructed here as
a self-contained development of the **zero-temperature (tropical) free energy** of
a finite system: the min-plus analogue of the partition function.

For a finite non-empty configuration set `s` with energies `f`, the tropical
partition function is `⨅_{i ∈ s} f i`, the ground-state energy.  It obeys exactly
the semiring laws of the min-plus (tropical) semiring: `min` for addition and `+`
for multiplication.

Main results:

* `TropicalEntropy.tropSum_le` / `le_tropSum` — the universal property;
* `TropicalEntropy.tropSum_shift` — additivity of a constant energy shift;
* `TropicalEntropy.tropSum_product` — **factorization over products**: the ground
  state energy of a composite system is the sum of the ground state energies of its
  parts;
* `TropicalEntropy.tropSum_square` — extensivity of the tropical free energy;
* `TropicalEntropy.tropSum_antitone` — enlarging the configuration space can only
  lower the ground state energy.
-/

namespace TropicalEntropy

open Finset

variable {ι κ : Type*}

/-- The **tropical partition function** (ground-state energy) of the energy
function `f` on the finite non-empty configuration set `s`. -/
noncomputable def tropSum (s : Finset ι) (hs : s.Nonempty) (f : ι → ℝ) : ℝ := s.inf' hs f

theorem tropSum_le {s : Finset ι} (hs : s.Nonempty) (f : ι → ℝ) {i : ι} (hi : i ∈ s) :
    tropSum s hs f ≤ f i := Finset.inf'_le f hi

theorem le_tropSum {s : Finset ι} (hs : s.Nonempty) (f : ι → ℝ) {c : ℝ}
    (h : ∀ i ∈ s, c ≤ f i) : c ≤ tropSum s hs f := Finset.le_inf' hs f h

theorem exists_ground_state {s : Finset ι} (hs : s.Nonempty) (f : ι → ℝ) :
    ∃ i ∈ s, tropSum s hs f = f i := by
  obtain ⟨i, hi, hval⟩ := Finset.exists_mem_eq_inf' hs f
  exact ⟨i, hi, hval⟩

/-- **Energy shift.**  Adding a constant to every energy shifts the ground state
energy by the same constant — tropical multiplication by a scalar. -/
theorem tropSum_shift {s : Finset ι} (hs : s.Nonempty) (f : ι → ℝ) (c : ℝ) :
    tropSum s hs (fun i => f i + c) = tropSum s hs f + c := by
  refine le_antisymm ?_ ?_
  · obtain ⟨i, hi, hval⟩ := exists_ground_state hs f
    calc tropSum s hs (fun i => f i + c) ≤ f i + c := tropSum_le hs _ hi
      _ = tropSum s hs f + c := by rw [hval]
  · refine le_tropSum hs _ fun i hi => ?_
    linarith [tropSum_le hs f hi]

/-- **Factorization over products.**  The ground state energy of a system whose
energy is a sum of independent contributions is the sum of the ground state
energies.  This is the tropical analogue of `Z(A ⊗ B) = Z(A) · Z(B)`. -/
theorem tropSum_product {s : Finset ι} {t : Finset κ} (hs : s.Nonempty) (ht : t.Nonempty)
    (f : ι → ℝ) (g : κ → ℝ) :
    tropSum (s ×ˢ t) (hs.product ht) (fun p => f p.1 + g p.2)
      = tropSum s hs f + tropSum t ht g := by
  refine le_antisymm ?_ ?_
  · obtain ⟨i, hi, hfi⟩ := exists_ground_state hs f
    obtain ⟨j, hj, hgj⟩ := exists_ground_state ht g
    have hmem : (i, j) ∈ s ×ˢ t := Finset.mem_product.mpr ⟨hi, hj⟩
    calc tropSum (s ×ˢ t) (hs.product ht) (fun p => f p.1 + g p.2)
        ≤ f i + g j := tropSum_le (hs.product ht) _ hmem
      _ = tropSum s hs f + tropSum t ht g := by rw [hfi, hgj]
  · refine le_tropSum (hs.product ht) _ fun p hp => ?_
    obtain ⟨hp1, hp2⟩ := Finset.mem_product.mp hp
    exact add_le_add (tropSum_le hs f hp1) (tropSum_le ht g hp2)

/-- **Extensivity.**  Two independent identical subsystems have exactly twice the
ground state energy of one. -/
theorem tropSum_square {s : Finset ι} (hs : s.Nonempty) (f : ι → ℝ) :
    tropSum (s ×ˢ s) (hs.product hs) (fun p => f p.1 + f p.2) = 2 * tropSum s hs f := by
  rw [tropSum_product hs hs f f]
  ring

/-- **Monotonicity.**  A larger configuration space has a lower (or equal) ground
state energy. -/
theorem tropSum_antitone {s t : Finset ι} (hs : s.Nonempty) (ht : t.Nonempty)
    (hst : s ⊆ t) (f : ι → ℝ) : tropSum t ht f ≤ tropSum s hs f := by
  refine le_tropSum hs f fun i hi => tropSum_le ht f (hst hi)

/-- **The tropical Fubini law.**  Minimizing over a product can be done in either
order. -/
theorem tropSum_comm {s : Finset ι} {t : Finset κ} (hs : s.Nonempty) (ht : t.Nonempty)
    (F : ι → κ → ℝ) :
    tropSum s hs (fun i => tropSum t ht (fun j => F i j))
      = tropSum t ht (fun j => tropSum s hs (fun i => F i j)) := by
  refine le_antisymm ?_ ?_
  · refine le_tropSum ht _ fun j hj => ?_
    refine le_tropSum hs _ fun i hi => ?_
    exact le_trans (tropSum_le hs _ hi) (tropSum_le ht _ hj)
  · refine le_tropSum hs _ fun i hi => ?_
    refine le_tropSum ht _ fun j hj => ?_
    exact le_trans (tropSum_le ht _ hj) (tropSum_le hs _ hi)

end TropicalEntropy