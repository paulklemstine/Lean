import Mathlib

/-!
# The Poincaré Conjecture for Data: the `n^{-1/d}` detection-threshold scaling law

This file makes rigorous the *scaling* part of the "Poincaré conjecture for data".
The informal conjecture claims that the manifold-detection ("Poincaré") threshold of a
point cloud of `n` points sampled from a `d`-dimensional object scales like

  `ε_⋆  =  C · d^{1/2} · n^{-1/d}`.

We isolate the mathematically defensible core of this statement — the `n^{-1/d}`
covering/packing exponent — and prove it **exactly** in a clean discrete model, the
Chebyshev (ℓ^∞) cube `Fin d → Fin m`.

The dictionary with the informal statement:

* the ambient object is the cube `{0, …, m-1}^d`, playing the role of a sampled manifold;
* a *point cloud* / covering set is a `Finset S` of the cube;
* the *scale* `ε` is the ℓ^∞ radius `r`;
* "`VR_ε(X)` has the homology of the object" is modelled by *`S` being an `r`-cover*:
  every point of the cube is within radius `r` of a sample. This is exactly the
  Nerve-Lemma condition under which the Vietoris–Rips / Čech complex of `S` recovers the
  homotopy type of the cube.

Main results.

* `PoincareData.covering_lower_bound` : any `r`-cover `S` of the cube satisfies
  `m ^ d ≤ S.card * (2*r+1) ^ d`  (a packing lower bound on the number of samples).
* `PoincareData.covering_radius_scaling` : the real-analytic corollary
  `(m : ℝ) ≤ (S.card) ^ (1/d) * (2*r+1)`, i.e. the covering radius obeys
  `2r+1 ≥ m · n^{-1/d}` — the `n^{-1/d}` scaling law.
* `PoincareData.exact_cover_exists` and `PoincareData.min_cover_card` : when
  `m = (2r+1)·t` the lower bound is **attained**, so the minimal number of `r`-cover
  samples is *exactly* `t ^ d = (m/(2r+1)) ^ d`. Hence the exponent `-1/d` is sharp.
-/

open Finset

namespace PoincareData

variable {d m : ℕ}

/-- Chebyshev (ℓ^∞) closeness in the discrete cube `Fin d → Fin m`:
`x` is within radius `r` of `s` in every coordinate. -/
def ChebClose (r : ℕ) (s x : Fin d → Fin m) : Prop :=
  ∀ i, ((x i : ℤ) - (s i : ℤ)).natAbs ≤ r

instance (r : ℕ) (s x : Fin d → Fin m) : Decidable (ChebClose r s x) := by
  unfold ChebClose; infer_instance

/-- The ℓ^∞ ball of radius `r` around `s`. -/
def cheBall (r : ℕ) (s : Fin d → Fin m) : Finset (Fin d → Fin m) :=
  Finset.univ.filter (fun x => ChebClose r s x)

/-
The number of one–dimensional grid points within distance `r` of a center `c`
is at most `2r+1`.
-/
lemma coord_count (m r c : ℕ) :
    (Finset.univ.filter (fun a : Fin m => ((a : ℤ) - (c : ℤ)).natAbs ≤ r)).card ≤ 2 * r + 1 := by
  -- Consider the map $a \mapsto (a : \mathbb{Z})$. If $|(a : \mathbb{Z}) - c| \leq r$, then $-(r : \mathbb{Z}) \leq (a : \mathbb{Z}) - c$ and $(a : \mathbb{Z}) - c \leq r$, hence $(a : \mathbb{Z}) \in \text{Finset.Icc}(c - r, c + r)$.
  have h_map : Finset.image (fun a : Fin m => (a : ℤ)) (Finset.filter (fun a : Fin m => (Int.natAbs ((a : ℤ) - c)) ≤ r) Finset.univ) ⊆ Finset.Icc (c - r : ℤ) (c + r) := by
    grind;
  have := Finset.card_le_card h_map; simp_all +decide ;
  rw [ Finset.card_image_of_injective _ fun a b h => by simpa [ Fin.ext_iff ] using h ] at this ; omega;

/-
The ℓ^∞ ball of radius `r` contains at most `(2r+1)^d` points.
-/
lemma cheBall_card_le (r : ℕ) (s : Fin d → Fin m) :
    (cheBall r s).card ≤ (2 * r + 1) ^ d := by
  -- By definition of `cheBall`, we know that every point in `cheBall r s` is within distance `r` of `s` in every coordinate.
  have h_cheBall_def : cheBall r s = Fintype.piFinset (fun i => Finset.univ.filter (fun a : Fin m => ((a : ℤ) - (s i : ℤ)).natAbs ≤ r)) := by
    ext; simp [cheBall, ChebClose];
  rw [ h_cheBall_def, Fintype.card_piFinset ];
  exact le_trans ( Finset.prod_le_prod' fun _ _ => coord_count m r _ ) ( by norm_num )

/-
**Packing lower bound.** To `r`-cover the `m^d` points of the discrete cube with
Chebyshev balls one needs at least `m^d / (2r+1)^d` samples:
`m ^ d ≤ S.card * (2r+1) ^ d`.
-/
theorem covering_lower_bound (r : ℕ) (S : Finset (Fin d → Fin m))
    (hcov : ∀ x : Fin d → Fin m, ∃ s ∈ S, ChebClose r s x) :
    m ^ d ≤ S.card * (2 * r + 1) ^ d := by
  -- By definition of `cheBall`, we know that every point in `cheBall r s` is within distance `r` of `s` in every coordinate. Hence, the union of all `cheBall r s` for `s ∈ S` covers the entire discrete cube.
  have h_union : (Finset.univ : Finset (Fin d → Fin m)) ⊆ Finset.biUnion S (fun s => cheBall r s) := by
    exact fun x _ => by obtain ⟨ s, hs₁, hs₂ ⟩ := hcov x; exact Finset.mem_biUnion.mpr ⟨ s, hs₁, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hs₂ ⟩ ⟩ ;
  exact le_trans ( by simp ) ( Finset.card_le_card h_union |> le_trans <| Finset.card_biUnion_le.trans <| Finset.sum_le_card_nsmul _ _ _ fun x hx => cheBall_card_le _ _ )

/-
**The `n^{-1/d}` scaling law (real form).** For a nonempty cube (`1 ≤ m`) of positive
dimension (`1 ≤ d`), any `r`-cover `S` with `n := S.card` samples has covering radius
obeying `m ≤ n^{1/d} · (2r+1)`, i.e. `2r+1 ≥ m · n^{-1/d}`.
-/
theorem covering_radius_scaling (r : ℕ) (hd : 1 ≤ d) (hm : 1 ≤ m)
    (S : Finset (Fin d → Fin m))
    (hcov : ∀ x : Fin d → Fin m, ∃ s ∈ S, ChebClose r s x) :
    (m : ℝ) ≤ (S.card : ℝ) ^ ((1 : ℝ) / d) * (2 * r + 1) := by
  convert Real.rpow_le_rpow ( by positivity ) ( show ( m : ℝ ) ^ d ≤ ( S.card * ( ( 2 * r + 1 ) ^ d ) : ℝ ) from ?_ ) ( show ( 0 : ℝ ) ≤ ( 1 : ℝ ) / d by positivity ) using 1;
  · rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ), mul_one_div_cancel ( by positivity ), Real.rpow_one ];
  · rw [ Real.mul_rpow ( by positivity ) ( by positivity ), ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ), mul_one_div_cancel ( by positivity ), Real.rpow_one ];
  · exact_mod_cast covering_lower_bound r S hcov

/-- The `k`-th admissible per-coordinate center `k·(2r+1)+r` on `Fin ((2r+1)*t)`,
indexed by `k : Fin t`. These are the block centers of the grid cover. -/
def centerFin (r t : ℕ) (k : Fin t) : Fin ((2 * r + 1) * t) :=
  ⟨(k : ℕ) * (2 * r + 1) + r, by
    have hk : (k : ℕ) < t := k.isLt
    have h1 : ((k : ℕ) + 1) * (2 * r + 1) ≤ t * (2 * r + 1) :=
      Nat.mul_le_mul_right _ (by omega)
    nlinarith [h1]⟩

/-- The block index of a coordinate value `v`, i.e. `v / (2r+1) : Fin t`. -/
def blockIdx (r t : ℕ) (v : Fin ((2 * r + 1) * t)) : Fin t :=
  ⟨(v : ℕ) / (2 * r + 1), by
    have hv : (v : ℕ) < (2 * r + 1) * t := v.isLt
    exact Nat.div_lt_of_lt_mul (by omega)⟩

/-- The block-center map is injective, so there are exactly `t` distinct centers. -/
lemma centerFin_injective (r t : ℕ) : Function.Injective (centerFin r t) := by
  intro a b h
  have hv : (a : ℕ) * (2 * r + 1) + r = (b : ℕ) * (2 * r + 1) + r := by
    simpa [centerFin] using congrArg Fin.val h
  have : (a : ℕ) = (b : ℕ) := by nlinarith [hv]
  exact Fin.ext this

/-- Every coordinate value is within Chebyshev radius `r` of its block center. -/
lemma cheb_block (r t : ℕ) (v : Fin ((2 * r + 1) * t)) :
    ((v : ℤ) - (((v : ℕ) / (2 * r + 1)) * (2 * r + 1) + r : ℕ)).natAbs ≤ r := by
  set q := (v : ℕ) / (2 * r + 1) with hq
  set md := (v : ℕ) % (2 * r + 1) with hmd
  have hdm : (2 * r + 1) * q + md = (v : ℕ) := Nat.div_add_mod (v : ℕ) (2 * r + 1)
  have hmod : md < 2 * r + 1 := Nat.mod_lt _ (by omega)
  have hdmZ : (v : ℤ) = (2 * r + 1) * (q : ℤ) + (md : ℤ) := by exact_mod_cast hdm.symm
  have hrw : ((v : ℤ) - (((q : ℕ) * (2 * r + 1) + r : ℕ))) = (md : ℤ) - (r : ℤ) := by
    push_cast [hdmZ]; ring
  rw [hrw]; omega

/-
**Sharpness (existence of an optimal cover).** When `m = (2r+1)·t` there is an
`r`-cover of the cube using exactly `t^d = (m/(2r+1))^d` samples. Take
`S = { s : Fin d → Fin m | ∀ i, s i is a block center }`, i.e. the product of the
`t` block centers in each of the `d` coordinates.
-/
theorem exact_cover_exists (r t : ℕ) :
    ∃ S : Finset (Fin d → Fin ((2 * r + 1) * t)),
      (∀ x : Fin d → Fin ((2 * r + 1) * t), ∃ s ∈ S, ChebClose r s x) ∧
      S.card = t ^ d := by
  refine' ⟨ Finset.image ( fun k : Fin d → Fin t => fun i => centerFin r t ( k i ) ) ( Finset.univ ), _, _ ⟩;
  · intro x; use fun i => centerFin r t ( blockIdx r t ( x i ) ) ; simp +decide [ ChebClose ] ;
    exact fun i => by simpa [ centerFin, blockIdx ] using cheb_block r t ( x i ) ;
  · rw [ Finset.card_image_of_injective ];
    · simp +decide;
    · intro k l hkl; funext i; exact centerFin_injective r t (congr_fun hkl i)

/-
**Minimality.** When `m = (2r+1)·t`, every `r`-cover of the cube has at least `t^d`
samples. Combined with `exact_cover_exists`, the minimal cover size is exactly `t^d`,
so the packing exponent `-1/d` is sharp.
-/
theorem min_cover_card (r t : ℕ) (S : Finset (Fin d → Fin ((2 * r + 1) * t)))
    (hcov : ∀ x : Fin d → Fin ((2 * r + 1) * t), ∃ s ∈ S, ChebClose r s x) :
    t ^ d ≤ S.card := by
  have := covering_lower_bound r S hcov;
  rw [ mul_pow ] at this ; nlinarith [ pow_pos ( by linarith : 0 < ( 2 * r + 1 ) ) d ]

end PoincareData