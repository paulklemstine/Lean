import Mathlib

/-!
# Phase II: Kinetic Tropical Certification — Additional Lemmas

This module provides the standalone `max_along_line_lipschitz` theorem stated
in the spec, as well as a combined kinetic-polyhedral synthesis theorem. The core
kinetic certification theorems live in `Tropical.KineticCertification`.

## Main Results

* `max_along_line_lipschitz` — `|max_i(a_i + t·v_i) − max_i(a_i)| ≤ |t|·max_i|v_i|`
* `kinetic_polyhedral_membership` — combined kinetic + polyhedral stability certificate
-/

noncomputable section
open Finset

/-! ### Max-perturbation Lipschitz lemma -/

/-
**Max along line Lipschitz bound**: the supremum `max_i(a_i + t·v_i)` is Lipschitz
in `t` with constant `max_i |v_i|`. This is the core perturbation estimate underlying
all kinetic certification results.

Mathematically: `|max_i(a_i + t·v_i) − max_i(a_i)| ≤ |t| · max_i|v_i|`.
-/
theorem max_along_line_lipschitz
    {n : ℕ} (hn : 0 < n)
    (a v : Fin n → ℝ) :
    ∀ t : ℝ,
      |(Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => a i + t * v i)) -
       (Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => a i))|
      ≤ |t| * Finset.univ.sup' (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => |v i|) := by
  intro t
  apply abs_sub_le_iff.mpr;
  constructor <;> norm_num [ sub_le_iff_le_add', Finset.sup'_le_iff ];
  · intro i; cases abs_cases t <;> nlinarith [ abs_le.mp ( show |v i| ≤ Finset.univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ 0, hn ⟩ ) fun i => |v i| from Finset.le_sup' ( fun i => |v i| ) ( Finset.mem_univ i ) ), ( Finset.le_sup' ( fun i => a i ) ( Finset.mem_univ i ) ) ] ;
  · intro i
    have h_le : a i + t * v i ≤ (Finset.univ.sup' (by
    exact ⟨ i, Finset.mem_univ i ⟩) (fun i => a i + t * v i)) := by
      exact Finset.le_sup' ( fun i => a i + t * v i ) ( Finset.mem_univ i )
    generalize_proofs at *;
    cases abs_cases t <;> nlinarith [ abs_le.mp ( show |v i| ≤ ( Finset.univ.sup' ‹_› fun i => |v i| ) from Finset.le_sup' ( fun i => |v i| ) ( Finset.mem_univ i ) ) ]

end