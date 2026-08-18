import Probability.PRNGLFSRDetection

/-!
# How many symbols certify a recovered seed?  The `2L` theorem

Berlekamp–Massey recovers a length-`L` LFSR from an observed window.  The
practical question for a seed-compressor is: **after how many observed symbols
is the recovered generator guaranteed to reproduce the rest of the file?**  This
file answers it: `2L` symbols suffice, for the whole family at once.

The proof runs through the module structure of `ℕ → K` over the polynomial ring,
with `X` acting as the shift operator:

* `shiftEnd` — the shift as a `K`-linear endomorphism of `ℕ → K`;
* `aeval_shiftEnd_apply` — the action of a polynomial is the associated linear
  recurrence operator;
* `charPolyLFSR`, `satisfiesLFSR_iff_aeval` — a stream is an order-`L` LFSR
  stream (taps `c`) exactly when its characteristic polynomial annihilates it;
* `eq_zero_of_annihilated` — a sequence annihilated by a monic polynomial of
  degree `m` and vanishing on `[0, m)` vanishes identically (rigidity);
* `aeval_mul_sub_eq_zero` — the difference of two sequences with annihilators
  `f` and `g` is annihilated by `f * g` (this is where the two *different* tap
  vectors get merged);
* `lfsr_seq_determined_by_two_L` — **the `2L` theorem**: two sequences each of
  linear complexity `≤ L` that agree on the first `2L` symbols agree forever;
* `lfsr_stream_determined_by_two_L` — the same statement for the concrete
  generators: matching `2L` output symbols certifies the recovered seed *and*
  taps for the entire, arbitrarily long, file.

The computational counterpart is the saturation observed in
`ComputationalEvidence.md`: over `GF(2)` the number of length-`n` words of
linear complexity `≤ L` is strictly increasing in `n` until `n = 2L`, and
constant afterwards.
-/

namespace Catalog.Probability.SeedRec

open Polynomial

variable {K : Type*} [CommRing K]

/-- The shift operator on sequences, as a `K`-linear endomorphism. -/
def shiftEnd (K : Type*) [CommRing K] : Module.End K (ℕ → K) where
  toFun y := fun t => y (t + 1)
  map_add' := by intros; rfl
  map_smul' := by intros; rfl

theorem shiftEnd_pow_apply (y : ℕ → K) (i t : ℕ) : ((shiftEnd K) ^ i) y t = y (t + i) := by
  induction i generalizing y t with
  | zero => simp
  | succ i ih =>
      rw [pow_succ]
      show ((shiftEnd K) ^ i) ((shiftEnd K) y) t = _
      rw [ih]
      show y (t + i + 1) = y (t + (i + 1))
      ring_nf

/-- Acting by a polynomial is applying the corresponding linear recurrence
operator to the sequence. -/
theorem aeval_shiftEnd_apply (p : K[X]) (y : ℕ → K) (t : ℕ) :
    (aeval (shiftEnd K) p) y t = ∑ i ∈ Finset.range (p.natDegree + 1), p.coeff i * y (t + i) := by
  rw [Polynomial.aeval_eq_sum_range, LinearMap.sum_apply]
  simp [shiftEnd_pow_apply]

variable {L : ℕ}

/-- The characteristic polynomial `X^L - ∑ c_j X^j` of the tap vector `c`. -/
noncomputable def charPolyLFSR (c : Fin L → K) : K[X] :=
  X ^ L - ∑ j : Fin L, C (c j) * X ^ (j : ℕ)

theorem degree_taps_lt (c : Fin L → K) :
    (∑ j : Fin L, C (c j) * X ^ (j : ℕ) : K[X]).degree < (L : ℕ) := by
  refine lt_of_le_of_lt (Polynomial.degree_sum_le _ _) ?_
  rw [Finset.sup_lt_iff (by exact_mod_cast WithBot.bot_lt_coe L)]
  intro j _
  exact lt_of_le_of_lt (Polynomial.degree_C_mul_X_pow_le _ _) (by exact_mod_cast j.isLt)

theorem charPolyLFSR_monic (c : Fin L → K) : (charPolyLFSR c).Monic :=
  Polynomial.monic_X_pow_sub (degree_taps_lt c)

theorem charPolyLFSR_natDegree [Nontrivial K] (c : Fin L → K) :
    (charPolyLFSR c).natDegree = L := by
  have h2 := Polynomial.degree_sub_eq_left_of_degree_lt
    (p := (X ^ L : K[X])) (q := ∑ j : Fin L, C (c j) * X ^ (j : ℕ))
    (by simpa using degree_taps_lt c)
  simpa [charPolyLFSR] using Polynomial.natDegree_eq_of_degree_eq h2

/-- A stream is an order-`L` LFSR stream with taps `c` exactly when its
characteristic polynomial annihilates it. -/
theorem satisfiesLFSR_iff_aeval (c : Fin L → K) (y : ℕ → K) :
    SatisfiesLFSR c y ↔ aeval (shiftEnd K) (charPolyLFSR c) y = 0 := by
  have hval : ∀ t : ℕ, (aeval (shiftEnd K) (charPolyLFSR c)) y t
      = y (t + L) - ∑ j : Fin L, c j * y (t + (j : ℕ)) := by
    intro t
    simp [charPolyLFSR, map_sub, map_sum, shiftEnd_pow_apply]
  constructor
  · intro h
    funext t
    rw [hval t, h t, sub_self]
    rfl
  · intro h t
    have := congrFun h t
    rw [hval t] at this
    have h0 : (0 : ℕ → K) t = 0 := rfl
    rw [h0] at this
    exact sub_eq_zero.mp this

/-- **Rigidity.** A sequence annihilated by a monic polynomial of degree `m`
that vanishes on `[0, m)` vanishes identically. -/
theorem eq_zero_of_annihilated (p : K[X]) (hm : p.Monic) (w : ℕ → K)
    (hw : aeval (shiftEnd K) p w = 0) (hvan : ∀ t < p.natDegree, w t = 0) : w = 0 := by
  funext t
  show w t = 0
  induction t using Nat.strong_induction_on with
  | _ t ih =>
      by_cases ht : t < p.natDegree
      · exact hvan t ht
      · obtain ⟨t', rfl⟩ : ∃ t', t = t' + p.natDegree := ⟨t - p.natDegree, by omega⟩
        have h0 : ∑ i ∈ Finset.range (p.natDegree + 1), p.coeff i * w (t' + i) = 0 := by
          have := congrFun hw t'
          rwa [aeval_shiftEnd_apply] at this
        rw [Finset.sum_range_succ, hm.coeff_natDegree, one_mul] at h0
        have hz : ∑ i ∈ Finset.range p.natDegree, p.coeff i * w (t' + i) = 0 := by
          refine Finset.sum_eq_zero ?_
          intro i hi
          rw [Finset.mem_range] at hi
          rw [ih (t' + i) (by omega), mul_zero]
        rw [hz, zero_add] at h0
        exact h0

/-- Annihilators multiply: the difference of a sequence annihilated by `f` and a
sequence annihilated by `g` is annihilated by `f * g`. -/
theorem aeval_mul_sub_eq_zero {f g : K[X]} {y z : ℕ → K}
    (hy : aeval (shiftEnd K) f y = 0) (hz : aeval (shiftEnd K) g z = 0) :
    aeval (shiftEnd K) (f * g) (y - z) = 0 := by
  have hy' : aeval (shiftEnd K) (f * g) y = 0 := by
    rw [mul_comm, map_mul]
    show (aeval (shiftEnd K) g) ((aeval (shiftEnd K) f) y) = 0
    rw [hy, map_zero]
  have hz' : aeval (shiftEnd K) (f * g) z = 0 := by
    rw [map_mul]
    show (aeval (shiftEnd K) f) ((aeval (shiftEnd K) g) z) = 0
    rw [hz, map_zero]
  rw [map_sub, hy', hz', sub_zero]

/-- **The `2L` theorem.** Two sequences, each of linear complexity at most `L`
(possibly with *different* tap vectors), that agree on their first `2L` symbols
are equal at every index. -/
theorem lfsr_seq_determined_by_two_L [Nontrivial K] (c c' : Fin L → K) (y z : ℕ → K)
    (hy : SatisfiesLFSR c y) (hz : SatisfiesLFSR c' z)
    (hagree : ∀ t < 2 * L, y t = z t) : y = z := by
  have hy' := (satisfiesLFSR_iff_aeval c y).1 hy
  have hz' := (satisfiesLFSR_iff_aeval c' z).1 hz
  have hprod : aeval (shiftEnd K) (charPolyLFSR c * charPolyLFSR c') (y - z) = 0 :=
    aeval_mul_sub_eq_zero hy' hz'
  have hmonic : (charPolyLFSR c * charPolyLFSR c').Monic :=
    (charPolyLFSR_monic c).mul (charPolyLFSR_monic c')
  have hdeg : (charPolyLFSR c * charPolyLFSR c').natDegree = 2 * L := by
    rw [(charPolyLFSR_monic c).natDegree_mul (charPolyLFSR_monic c'),
      charPolyLFSR_natDegree, charPolyLFSR_natDegree]
    ring
  have hvan : ∀ t < (charPolyLFSR c * charPolyLFSR c').natDegree, (y - z) t = 0 := by
    intro t ht
    rw [hdeg] at ht
    simp [hagree t ht]
  have := eq_zero_of_annihilated _ hmonic _ hprod hvan
  funext t
  have := congrFun this t
  simp only [Pi.sub_apply, Pi.zero_apply, sub_eq_zero] at this
  exact this

/-- **Certified seed recovery.** If two LFSR generators of order `L` — with
arbitrary taps and arbitrary seeds — produce the same first `2L` output symbols,
their streams coincide at every time.  So an order-`L` seed recovered from `2L`
observed symbols provably reproduces the rest of the file. -/
theorem lfsr_stream_determined_by_two_L [Nontrivial K] [NeZero L]
    (c c' : Fin L → K) (σ σ' : Fin L → K)
    (hagree : ∀ t < 2 * L, (lfsrPRNG c).stream σ t = (lfsrPRNG c').stream σ' t) :
    ∀ t, (lfsrPRNG c).stream σ t = (lfsrPRNG c').stream σ' t := by
  have := lfsr_seq_determined_by_two_L c c' _ _ (satisfiesLFSR_stream c σ)
    (satisfiesLFSR_stream c' σ') hagree
  exact fun t => congrFun this t

end Catalog.Probability.SeedRec