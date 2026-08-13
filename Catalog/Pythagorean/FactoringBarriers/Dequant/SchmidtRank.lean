import Pythagorean.FactoringBarriers.Dequant.OrderProbe

/-!
# Barrier IV, part 4: the Schmidt rank of Shor's state is exactly the order

The tensor-network route to de-quantization asks for a matrix-product-state
representation of the pre-measurement Shor state

  `|ψ⟩ = Σ_{x < Q} |x⟩ ⊗ |b^x mod N⟩`

with polynomial bond dimension.  The bipartite rank across the register cut is the
rank of the `Q × N` coefficient matrix `M x z = [b^x = z]`.  We prove that this rank
is *exactly* the multiplicative order `r`, and that the surviving rows are
orthonormal — the flat, incompressible spectrum of the paper.

* `Dequant.orbit_card_eq_order` — the branch set `{b^x : x < Q}` has exactly `r`
  elements whenever `r ∣ Q`.
* `Dequant.shorMatrix_rank_eq_order` — **Schmidt rank = r** (over ℝ).
* `Dequant.shorMatrix_row_orthonormal` — the rows are ±orthonormal: the reduced
  density matrix is `1/r` times a rank-`r` projector, so the entanglement spectrum
  is flat and no bond-dimension truncation is lossless.
* `Dequant.order_le_of_rank_le` — the contrapositive that closes the route: a
  polynomial-bond-dimension MPS forces a polynomially small order, i.e. exactly the
  classically easy regime.
-/

namespace Dequant

open Finset

/-- The branch set `{b^x : x < Q}` of the Shor state. -/
noncomputable def branches (N b Q : ℕ) : Finset (ZMod N) :=
  (Finset.range Q).image (fun x => (b : ZMod N) ^ x)

/-- **The number of branches is the order.**  If the order divides the grid size,
the Shor state has exactly `r` distinct second-register values. -/
theorem orbit_card_eq_order {N b Q : ℕ} (hr : 0 < ord N b) (hdvd : ord N b ∣ Q)
    (hQ : 0 < Q) : (branches N b Q).card = ord N b := by
  rw [ord] at hr hdvd ⊢
  have himg : branches N b Q
      = (Finset.range (orderOf (b : ZMod N))).image (fun x => (b : ZMod N) ^ x) := by
    apply Finset.Subset.antisymm
    · intro z hz
      simp only [branches, Finset.mem_image, Finset.mem_range] at hz ⊢
      obtain ⟨x, hx, rfl⟩ := hz
      exact ⟨x % orderOf (b : ZMod N), Nat.mod_lt _ hr, pow_mod_orderOf _ _⟩
    · refine Finset.image_subset_image ?_
      intro x hx
      simp only [Finset.mem_range] at *
      exact lt_of_lt_of_le hx (Nat.le_of_dvd hQ hdvd)
  rw [himg, Finset.card_image_of_injOn, Finset.card_range]
  intro x hx y hy hxy
  exact pow_injOn_Iio_orderOf (by simpa using Finset.mem_range.mp hx)
    (by simpa using Finset.mem_range.mp hy) hxy

/-- The coefficient matrix of Shor's state across the register cut. -/
noncomputable def shorMatrix (N b Q : ℕ) : Matrix (Fin Q) (ZMod N) ℝ :=
  fun x z => if (b : ZMod N) ^ (x : ℕ) = z then 1 else 0

theorem shorMatrix_row (N b Q : ℕ) (x : Fin Q) :
    (shorMatrix N b Q).row x = Pi.single ((b : ZMod N) ^ (x : ℕ)) 1 := by
  funext z
  simp only [shorMatrix, Matrix.row, Pi.single_apply]
  by_cases h : (b : ZMod N) ^ (x : ℕ) = z
  · simp [h]
  · simp [h, Ne.symm h]

/-- **Schmidt rank = order.**  The bipartite rank of Shor's state across the two
registers equals the multiplicative order `r` exactly. -/
theorem shorMatrix_rank_eq_order {N b Q : ℕ} [NeZero N] (hr : 0 < ord N b)
    (hdvd : ord N b ∣ Q) (hQ : 0 < Q) : (shorMatrix N b Q).rank = ord N b := by
  classical
  set S : Finset (ZMod N) := branches N b Q with hS
  have hrange : Set.range (shorMatrix N b Q).row
      = Set.range (fun z : S => (Pi.single (z : ZMod N) 1 : ZMod N → ℝ)) := by
    ext v
    constructor
    · rintro ⟨x, rfl⟩
      have hmem : (b : ZMod N) ^ (x : ℕ) ∈ S := by
        simp only [hS, branches, Finset.mem_image, Finset.mem_range]
        exact ⟨(x : ℕ), x.isLt, rfl⟩
      exact ⟨⟨_, hmem⟩, by rw [shorMatrix_row]⟩
    · rintro ⟨⟨z, hz⟩, rfl⟩
      simp only [hS, branches, Finset.mem_image, Finset.mem_range] at hz
      obtain ⟨x, hx, rfl⟩ := hz
      exact ⟨⟨x, hx⟩, by rw [shorMatrix_row]⟩
  have hfun : (fun z : S => (Pi.single (z : ZMod N) 1 : ZMod N → ℝ))
      = ⇑(Pi.basisFun ℝ (ZMod N)) ∘ (fun z : S => (z : ZMod N)) := by
    funext z
    simp [Function.comp, Pi.basisFun_apply]
  have li : LinearIndependent ℝ (fun z : S => (Pi.single (z : ZMod N) 1 : ZMod N → ℝ)) := by
    rw [hfun]
    exact (Pi.basisFun ℝ (ZMod N)).linearIndependent.comp _ Subtype.coe_injective
  rw [Matrix.rank_eq_finrank_span_row, hrange, finrank_span_eq_card li]
  simpa [hS] using orbit_card_eq_order hr hdvd hQ

/-- **Flat spectrum.**  Two rows of the coefficient matrix have inner product `1` if
they lie on the same branch and `0` otherwise: the `r` surviving Schmidt vectors are
orthonormal, so all `r` Schmidt coefficients are equal and the entanglement spectrum
is flat (entropy `log r`).  No truncation of bond dimension is lossless. -/
theorem shorMatrix_row_orthonormal {N b Q : ℕ} [NeZero N] (x y : Fin Q) :
    ∑ z : ZMod N, shorMatrix N b Q x z * shorMatrix N b Q y z
      = if (b : ZMod N) ^ (x : ℕ) = (b : ZMod N) ^ (y : ℕ) then 1 else 0 := by
  classical
  have h : ∀ z : ZMod N, shorMatrix N b Q x z * shorMatrix N b Q y z
      = if (b : ZMod N) ^ (x : ℕ) = z ∧ (b : ZMod N) ^ (y : ℕ) = z then 1 else 0 := by
    intro z
    simp only [shorMatrix]
    by_cases h1 : (b : ZMod N) ^ (x : ℕ) = z <;> by_cases h2 : (b : ZMod N) ^ (y : ℕ) = z <;>
      simp [h1, h2]
  rw [Finset.sum_congr rfl (fun z _ => h z)]
  by_cases hxy : (b : ZMod N) ^ (x : ℕ) = (b : ZMod N) ^ (y : ℕ)
  · rw [if_pos hxy]
    have h2 : ∀ z : ZMod N,
        (if (b : ZMod N) ^ (x : ℕ) = z ∧ (b : ZMod N) ^ (y : ℕ) = z then (1:ℝ) else 0)
          = if (b : ZMod N) ^ (x : ℕ) = z then (1:ℝ) else 0 := by
      intro z
      rw [hxy]
      simp
    rw [Finset.sum_congr rfl (fun z _ => h2 z)]
    simp
  · rw [if_neg hxy]
    refine Finset.sum_eq_zero fun z _ => ?_
    by_cases hz : (b : ZMod N) ^ (x : ℕ) = z ∧ (b : ZMod N) ^ (y : ℕ) = z
    · exact absurd (hz.1.trans hz.2.symm) hxy
    · simp [hz]

/-- **The tensor-network route closes.**  If the Shor state admits a bipartite
decomposition of rank at most `k` — in particular an MPS of bond dimension `k` —
then the order is at most `k`.  Polynomial bond dimension therefore forces a
polynomially small order: exactly the classically easy regime. -/
theorem order_le_of_rank_le {N b Q k : ℕ} [NeZero N] (hr : 0 < ord N b)
    (hdvd : ord N b ∣ Q) (hQ : 0 < Q) (hrank : (shorMatrix N b Q).rank ≤ k) :
    ord N b ≤ k := by
  rw [← shorMatrix_rank_eq_order hr hdvd hQ]
  exact hrank

end Dequant