import Algebra.PGLQuotient.TwistedWeight
import Algebra.PGLQuotient.VolumeAlgebra

/-!
# The vertex volume of the standard arithmetic quotient of `PGL_d`, in arbitrary rank

This file proves the headline computation in **arbitrary rank `d`**: with the Haar measure
normalised so that a maximal compact subgroup has volume `1`, the vertex volume of the standard
nonuniform arithmetic quotient of the affine Bruhat–Tits building of `PGL_d(F_q((t^{-1})))` is

`∑_λ 1/|Aut λ| = d / (P(d) · P(d-1))`,   `P(n) = ∏_{k=1}^{n} (q^k - 1)`

(`vertexVolume_general`, and `vertexVolume_general_rank` for the `d`-indexed form), together
with its `PGL`-normalised variant `(q-1) · ∑_λ 1/|Aut λ|` (`vertexVolume_general_pgl`).

The proof is the promised cut-set recursion, run on the two-parameter twisted mass of
`Algebra.PGLQuotient.TwistedWeight`:

* `twMass_succ`: peeling the top row of a dominant coweight turns the rank-`(n+2)` twisted mass
  into a combination of two rank-`(n+1)` twisted masses (the zero-gap branch and the
  positive-gap branch, the latter summed as a geometric series in the gap);
* `twMass_eq`: solving that recursion by induction on the rank, the closed form being
  `NumV/DenV` from `Algebra.PGLQuotient.VolumeAlgebra`;
* specialising `c = j = 0` gives the vertex volume, since `NumV q n 0 0 = (n+1)·P(n)` and
  `DenV q n 0 0 = P(n+1)·P(n)·P(n)`.

For `d = 2, 3` this recovers `heightZeta_rank_two` (at `s = 0`) and `vertexVolume_rank_three`.
-/

namespace PGLQuotient

open Finset

variable {q : ℝ}

section Summability

/-- The majorant `q^{-P(g)}` of the vertex mass is summable over the dominant sector. -/
lemma summable_inv_pow_pairExp (hq : 1 < q) (n : ℕ) :
    Summable (fun g : Vertex (n + 1) => (q ^ pairExp g)⁻¹) := by
  have hlt : ∀ k : Fin (n + 1 - 1), gapRatio q (n + 1) 0 k < 1 := by
    intro k
    rcases n with _ | m
    · exact k.elim0
    · exact gapRatio_lt_one hq (by omega) (by exact_mod_cast Nat.succ_pos (m + 1)) k
  obtain ⟨hsum, -⟩ := summable_pi_geom (gapRatio q (n + 1) 0) (gapRatio_nonneg hq 0) hlt
  refine hsum.congr (fun g => ?_)
  rw [prod_gapRatio 0 g]
  simp

/-- The twisted vertex mass is summable over the whole quotient. -/
lemma summable_twWeight (hq : 1 < q) (n c j : ℕ) :
    Summable (fun g : Vertex (n + 1) => twWeight q c j g) := by
  refine Summable.of_nonneg_of_le (fun g => (twWeight_pos hq c j g).le) (fun g => ?_)
    ((summable_inv_pow_pairExp hq n).mul_left (((1 - q⁻¹) ^ (n + 1))⁻¹))
  exact le_trans (twWeight_le_vertexWeight hq c j g) (vertexWeight_le g hq)

/-- The vertex mass is summable over the whole quotient. -/
lemma summable_vertexWeight_succ (hq : 1 < q) (n : ℕ) :
    Summable (fun g : Vertex (n + 1) => vertexWeight q g) :=
  (summable_twWeight hq n 0 0).congr (fun g => twWeight_zero_zero g)

end Summability

section Recursion

/-- **The row-peeling recursion for the twisted mass.** -/
theorem twMass_succ (hq : 1 < q) (n c j : ℕ) :
    ∑' g : Vertex (n + 2), twWeight q c j g
      = (q ^ (n + 1) * (q ^ (j + 1) - 1))⁻¹ *
        (∑' g : Vertex (n + 1), twWeight q (c + 1) (j + 1) g
          + (q ^ ((n + 1) * (c + 1)) - 1)⁻¹ * ∑' g : Vertex (n + 1), twWeight q (c + 1) 0 g) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  set K : ℝ := (q ^ (n + 2 + j) * (1 - q⁻¹ ^ (1 + j)))⁻¹ with hKdef
  set M1 : ℝ := ∑' g : Vertex (n + 1), twWeight q (c + 1) (j + 1) g with hM1
  set M0 : ℝ := ∑' g : Vertex (n + 1), twWeight q (c + 1) 0 g with hM0
  have hKval : K = (q ^ (n + 1) * (q ^ (j + 1) - 1))⁻¹ := by
    rw [hKdef]
    congr 1
    have h1 : q ^ (n + 2 + j) = q ^ (n + 1) * q ^ (1 + j) := by
      rw [← pow_add]; congr 1; omega
    have h2 : q ^ (1 + j) = q ^ (j + 1) := by rw [Nat.add_comm]
    rw [h1, inv_pow, h2]
    field_simp
  -- reindex the sum over the top gap
  have hsum2 : Summable (fun g : Vertex (n + 2) => twWeight q c j g) :=
    summable_twWeight hq (n + 1) c j
  have hF : Summable (fun p : ℕ × Vertex (n + 1) => twWeight q c j (consV p.1 p.2)) :=
    (Equiv.summable_iff (Fin.consEquiv (fun _ : Fin (n + 1) => ℕ))).mpr hsum2
  have hreindex : ∑' g : Vertex (n + 2), twWeight q c j g
      = ∑' p : ℕ × Vertex (n + 1), twWeight q c j (consV p.1 p.2) :=
    ((Fin.consEquiv (fun _ : Fin (n + 1) => ℕ)).tsum_eq
      (fun g : Vertex (n + 2) => twWeight q c j g)).symm
  -- the two branches
  have hzero : ∑' g : Vertex (n + 1), twWeight q c j (consV 0 g) = K * M1 := by
    rw [tsum_congr (fun g => twWeight_cons_zero hq c j g), tsum_mul_left]
  have hsucc : ∀ a : ℕ, ∑' g : Vertex (n + 1), twWeight q c j (consV (a + 1) g)
      = K * ((q ^ ((n + 1) * (c + 1))) ^ (a + 1))⁻¹ * M0 := by
    intro a
    rw [tsum_congr (fun g => twWeight_cons_succ hq c j a g), tsum_mul_left]
  -- the geometric series in the top gap
  have hr0 : (0:ℝ) ≤ (q ^ ((n + 1) * (c + 1)))⁻¹ := by positivity
  have hrlt : (q ^ ((n + 1) * (c + 1)))⁻¹ < 1 := by
    have h1 : (1:ℝ) < q ^ ((n + 1) * (c + 1)) := one_lt_pow₀ hq (by positivity)
    rw [inv_lt_one_iff₀]
    right; exact h1
  have hgeom : ∑' a : ℕ, K * ((q ^ ((n + 1) * (c + 1))) ^ (a + 1))⁻¹ * M0
      = K * ((q ^ ((n + 1) * (c + 1)) - 1)⁻¹ * M0) := by
    have hterm : ∀ a : ℕ, K * ((q ^ ((n + 1) * (c + 1))) ^ (a + 1))⁻¹ * M0
        = (K * M0 * (q ^ ((n + 1) * (c + 1)))⁻¹) * ((q ^ ((n + 1) * (c + 1)))⁻¹) ^ a := by
      intro a
      rw [← inv_pow, pow_succ]
      ring
    rw [tsum_congr hterm, tsum_mul_left, tsum_geometric_of_lt_one hr0 hrlt]
    have hx : (1:ℝ) < q ^ ((n + 1) * (c + 1)) := one_lt_pow₀ hq (by positivity)
    have hxpos : (0:ℝ) < q ^ ((n + 1) * (c + 1)) := by positivity
    field_simp
  rw [hreindex, hF.tsum_prod' (fun a => hF.prod_factor a), Summable.tsum_eq_zero_add hF.prod,
    hzero, tsum_congr hsucc, hgeom, ← hKval]
  ring

/-- **Closed form of the twisted mass in arbitrary rank.** -/
theorem twMass_eq (hq : 1 < q) (n c j : ℕ) :
    ∑' g : Vertex (n + 1), twWeight q c j g = NumV q n c j / DenV q n c j := by
  induction n generalizing c j with
  | zero =>
      have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
      have hval : ∀ g : Vertex 1, twWeight q c j g = (q ^ (1 + j) - 1)⁻¹ := by
        intro g
        have hlam : ∀ i : ℕ, lam g i = 0 := by
          intro i
          unfold lam
          simp
        have hend : endDim g = 1 := by
          unfold endDim
          simp [hlam]
        have hsig : sigmaExp g = 0 := by
          unfold sigmaExp
          simp [hlam]
        have hfb : firstBlockSize g = 1 := by
          unfold firstBlockSize
          simp [hlam]
        have hbr : blockRank g 0 = 1 := by
          unfold blockRank
          simp [hlam, Finset.filter_singleton]
        have hbp : blockProdShift q j g = 1 - q⁻¹ ^ (1 + j) := by
          unfold blockProdShift
          rw [Finset.prod_range_one, hbr, if_pos rfl]
        unfold twWeight
        rw [hend, hsig, hfb, hbp]
        congr 1
        rw [Nat.mul_zero, Nat.add_zero, Nat.mul_one, inv_pow]
        have : q ^ (1 + j) ≠ 0 := by positivity
        field_simp
      have hsub : ∀ b : Vertex 1, b = (fun i => i.elim0) := fun b => funext (fun i => i.elim0)
      rw [tsum_eq_single (fun i => i.elim0) (fun b hb => absurd (hsub b) hb), hval]
      unfold NumV DenV
      simp [Gpoly, Jfac, Pfac, Cfac]
  | succ m ih =>
      rw [twMass_succ hq m c j, ih (c + 1) (j + 1), ih (c + 1) 0, NumDen_step hq]

end Recursion

section Volume

/-- **The vertex volume in arbitrary rank, in closed product form.** -/
theorem vertexVolume_general (hq : 1 < q) (n : ℕ) :
    ∑' g : Vertex (n + 1), vertexWeight q g = (n + 1) / (Pfac q (n + 1) * Pfac q n) := by
  have hq0 : (0:ℝ) < q := lt_trans zero_lt_one hq
  have h1 : ∑' g : Vertex (n + 1), vertexWeight q g = NumV q n 0 0 / DenV q n 0 0 := by
    rw [← twMass_eq hq n 0 0]
    exact tsum_congr (fun g => (twWeight_zero_zero g).symm)
  have hNum : NumV q n 0 0 = (n + 1) * Pfac q n := by
    rw [NumV_zero_right]
    simp [Finset.sum_const, Finset.card_range]
    ring
  have hDen : DenV q n 0 0 = Pfac q (n + 1) * Pfac q n * Pfac q n := by
    unfold DenV
    rw [Jfac_zero_right]
    congr 1
    unfold Cfac Pfac
    exact Finset.prod_congr rfl (fun k _ => by rw [Nat.zero_add])
  have hP : (0:ℝ) < Pfac q n := Pfac_pos hq n
  have hP1 : (0:ℝ) < Pfac q (n + 1) := Pfac_pos hq (n + 1)
  rw [h1, hNum, hDen]
  field_simp

/-- The vertex volume in arbitrary rank `d ≥ 1`. -/
theorem vertexVolume_general_rank (hq : 1 < q) {d : ℕ} (hd : 1 ≤ d) :
    ∑' g : Vertex d, vertexWeight q g = d / (Pfac q d * Pfac q (d - 1)) := by
  obtain ⟨n, rfl⟩ : ∃ n, d = n + 1 := ⟨d - 1, by omega⟩
  simpa using vertexVolume_general hq n

/-- The `PGL`-normalised vertex volume in arbitrary rank. -/
theorem vertexVolume_general_pgl (hq : 1 < q) (n : ℕ) :
    (q - 1) * ∑' g : Vertex (n + 1), vertexWeight q g
      = (q - 1) * (n + 1) / (Pfac q (n + 1) * Pfac q n) := by
  rw [vertexVolume_general hq n, mul_div_assoc]

end Volume

end PGLQuotient