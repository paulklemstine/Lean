import Mathlib
import Catalog.Novelty.PartialCube

/-!
# The hypercube `Qₙ` is `n`-regular (catalog `DaisyCube` model)

Huang's spectral proof of the Sensitivity Conjecture studies induced subgraphs of the
`n`-dimensional hypercube `Qₙ`.  The starting structural fact about `Qₙ` is that it is
`n`-**regular**: every vertex has exactly `n` neighbours.

The companion file `SensitivitySignedAdjacency.lean` proves this *spectrally*
(`SignedAdjacency.Asign_degree`: each row of the signed adjacency matrix `Aₙ` has exactly
`n` nonzero entries).  Here we prove the same fact *combinatorially* in the catalog's own
hypercube model from `Catalog.Novelty.PartialCube`, where a vertex of `Qₙ` is a
`Finset (Fin n)` and adjacency `DaisyCube.Adj` is Hamming distance `1`
(`(A ∆ B).card = 1`).

This ties the spectral construction to the existing catalog graph model: both encodings
agree that `Qₙ` is `n`-regular, confirming that `Aₙ` really is a signed version of the
hypercube adjacency matrix.

## Main result

* `hypercube_regular` : in the `DaisyCube` model, each vertex `A` of `Qₙ` has exactly `n`
  neighbours.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the two independent encodings of `Qₙ` used across the catalog
— the `Sum`-recursive signed matrix `Aₙ` and the `Finset (Fin n)` / symmetric-difference
model of `DaisyCube` — must agree on the degree of every vertex, namely `n`.

Experiment (Experimenter): the neighbours of `A` are exactly the sets at Hamming distance
`1`, i.e. `{B : (A ∆ B).card = 1}`.  Since `(A ∆ B).card = 1 ↔ A ∆ B = {i}` for a unique
`i`, and `B = A ∆ (A ∆ B)`, the neighbour set is the injective image of `Fin n` under
`i ↦ A ∆ {i}`.  Injectivity is `symmDiff` left-cancellation; the count is then
`Fintype.card (Fin n) = n`.

Analysis (Analyst): the map `i ↦ A ∆ {i}` is the "toggle coordinate `i`" bijection between
directions and neighbours — exactly the `n` off-diagonal `±1` entries in row `A` of `Aₙ`.
This makes the correspondence between the matrix degree (`Asign_degree`) and the graph
degree (`hypercube_regular`) transparent.

Critique (Critic): the proof is not vacuous — it turns on the bijection and
`symmDiff_symmDiff_cancel_left`, not on `decide`.  Decidability of `Adj` (a `Nat`
equality) is supplied classically so the neighbour `Finset` is well-defined for all `n`.

Synthesis (PI): with both a spectral (`Asign_degree`) and a combinatorial
(`hypercube_regular`) proof of `n`-regularity in hand, the remaining gap toward the full
sensitivity bound is purely the Cauchy-interlacing step on `Aₙ`.
-/

open Finset
open scoped Classical

/-- **`n`-regularity of the hypercube** in the catalog `DaisyCube` model: every vertex `A`
of `Qₙ` has exactly `n` neighbours.  The neighbours are the images of `A` under toggling a
single coordinate, `i ↦ A ∆ {i}`, an injection from `Fin n`. -/
theorem hypercube_regular (n : ℕ) (A : Finset (Fin n)) :
    (Finset.univ.filter (fun B => DaisyCube.Adj A B)).card = n := by
  have hset : (Finset.univ.filter (fun B => DaisyCube.Adj A B))
      = Finset.univ.image (fun i : Fin n => symmDiff A {i}) := by
    ext B
    simp only [mem_filter, mem_univ, true_and, mem_image, DaisyCube.Adj, DaisyCube.hdist]
    constructor
    · intro h
      rw [Finset.card_eq_one] at h
      obtain ⟨i, hi⟩ := h
      refine ⟨i, ?_⟩
      have h2 : symmDiff A (symmDiff A B) = symmDiff A ({i} : Finset (Fin n)) := by rw [hi]
      rw [symmDiff_symmDiff_cancel_left] at h2; exact h2.symm
    · rintro ⟨i, rfl⟩
      rw [symmDiff_symmDiff_cancel_left]; simp
  rw [hset, Finset.card_image_of_injective]
  · simp
  · intro i j h
    simp only at h
    have h3 : symmDiff A (symmDiff A ({i} : Finset (Fin n)))
        = symmDiff A (symmDiff A {j}) := by rw [h]
    rw [symmDiff_symmDiff_cancel_left, symmDiff_symmDiff_cancel_left] at h3
    simpa using h3