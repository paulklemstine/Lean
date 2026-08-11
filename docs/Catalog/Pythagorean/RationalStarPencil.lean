import Cryptography.BerggrenStars.HypercycleStars

/-!
# The star at an arbitrary rational: why radial lines appear at `1/2`, `1/3`, `1/5`, …

Plotting the Berggren tree of primitive Pythagorean triples in the Poincaré upper
half-plane through the Euclid embedding `z(m,n) = (n + i)/m` produces radial lines not only
at the two ideal points `0` and `1` — the two classical *stars*, analysed in
`NumberTheory.BerggrenStarLines` and `Cryptography.BerggrenStars.HypercycleStars` — but
also, visibly, at `0.5`, `0.333…`, `0.2`, and in fact at *every* rational boundary point.

This file explains that phenomenon exactly. Fix a rational boundary point `p/q` in lowest
terms and define the **charge** of a Euclid seed at `p/q` by the integral linear form

  `chargeZ p q m n = p * m - q * n`.

## Main results

* `hpoint_on_rational_star_line` : the node `z(m,n)` satisfies
  `p/q - Re z = (charge / q) * Im z`, so the seeds of a fixed charge lie on exactly one
  Euclidean ray emanating from the ideal point `p/q`: *these rays are the visible radial
  lines*. The two known stars are the cases `charge 0 1 m n = -n` and
  `charge 1 1 m n = m - n`.
* `distVLine_charge` : that ray is a hypercycle — every node of charge `k` sits at the
  hyperbolic distance `arsinh (|k| / q)` from the complete geodesic over `p/q`.
* `charge_odd_of_odd_odd` : **parity quantisation at a general rational.** If `p` and `q`
  are both odd (equivalently `p + q` is even) then every seed has *odd* charge at `p/q`:
  half of the rays of the pencil carry no node at all. When `p + q` is odd there is no such
  obstruction (`exists_seed_charge_gt` in `Pythagorean.RationalStarRealization`).
  This unifies, and explains, the known asymmetry between the odd-charge `1`-star
  (`p = q = 1`, both odd) and the all-charge `0`-star (`p = 0`, `q = 1`).
* `charge_zero_iff_seed_eq` : **the axis of a star carries at most one node**, namely
  `(m,n) = (q,p)`, and `axis_node_iff_parity` : it carries that node precisely when `p + q`
  is odd. So a star with `p + q` even (e.g. `1/3`, `1/5`) is a fan with a *hole* along its
  axis, whereas a star with `p + q` odd (e.g. `1/2`, `1/4`, `2/5`) has a node sitting
  exactly over its centre — for `1/2` that node is the root `(2,1)` of the whole tree.
* `arsinh_inv_q_le_distVLine`, `distVLine_le_of_charge_le`, `min_gap_attained_one_half` :
  **the visibility law.** All spokes of the star at `p/q` other than the axis are at
  distance at least `arsinh (1/q)`, and the fan of charges `|k| ≤ K` is contained in the
  band of width `arsinh (K/q)`; the lower bound is attained. Since `arsinh (1/q)` decreases
  in `q`, only small denominators give visually separated rays — which is exactly what the
  picture shows at `0, 1, 1/2, 1/3, 1/5`.
* `chargeZ_seedL`, `chargeZ_seedM`, `chargeZ_seedR` : **star covariance.** Each Berggren
  move carries the star at one rational to the star at another, *preserving the charge
  exactly*: `chargeZ p q (B₁ (m,n)) = chargeZ (2p - q) p m n`,
  `chargeZ p q (B₂ (m,n)) = chargeZ (2p - q) (-p) m n`,
  `chargeZ p q (B₃ (m,n)) = chargeZ p (q - 2p) m n`. The system of rational stars is
  therefore permuted by the tree action, which is why no rational is exceptional.

## Lab notes

Charges `|k| ≤ 8` realised by seeds with `m ≤ 400` (exhaustive enumeration):

| `p/q` | `p+q` | realised charges |
|---|---|---|
| `0/1` | odd  | `-8 … -1` |
| `1/1` | even | `1,3,5,7` |
| `1/2` | odd  | `-8 … 8` (including `0`) |
| `1/3` | even | `±1, ±3, ±5, ±7` |
| `1/5` | even | `±1, ±3, ±5, ±7` |
| `2/5` | odd  | `-8 … 8` |
-/

namespace BerggrenRationalStar

open Real BerggrenHypercycleStars

/-! ## Part 1. The charge at a rational boundary point, and the radial line -/

/-- The **charge** of the integral pair `(m, n)` at the ideal point `p/q`: the integral
linear form `p m - q n`. It vanishes exactly on the vertical geodesic over `p/q`, and its
value is the (scaled) Euclidean slope parameter of the ray through the node. -/
def chargeZ (p q m n : ℤ) : ℤ := p * m - q * n

/-- The charge of a Euclid seed `(m,n) : ℕ × ℕ` at `p/q` with `q : ℕ`. -/
def charge (p : ℤ) (q m n : ℕ) : ℤ := chargeZ p q m n

@[simp] theorem charge_zero_one (m n : ℕ) : charge 0 1 m n = -(n : ℤ) := by
  simp [charge, chargeZ]

@[simp] theorem charge_one_one (m n : ℕ) : charge 1 1 m n = (m : ℤ) - n := by
  simp [charge, chargeZ]

/-- **The radial line at `p/q`.** The node `z(m,n) = (n+i)/m` lies on the Euclidean straight
line through the ideal point `p/q` whose parameter is `charge / q`; hence all seeds with a
common charge at `p/q` lie on one and the same Euclidean ray emanating from `p/q`. These
rays are the radial lines visible in the plot. -/
theorem hpoint_on_rational_star_line (p : ℤ) (q : ℕ) (hq : 0 < q) (m n : ℕ) (hm : 0 < m) :
    (p : ℝ) / q - (hpoint m n hm).re
      = ((charge p q m n : ℝ) / q) * (hpoint m n hm).im := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  simp only [hpoint_re, hpoint_im, charge, chargeZ, Int.cast_sub, Int.cast_mul,
    Int.cast_natCast]
  field_simp

/-- **The rays are hypercycles.** The hyperbolic distance from the node `z(m,n)` to the
complete geodesic over `p/q` is `arsinh (|charge| / q)`: it depends on the seed only through
the charge, so a ray of the star is a curve of constant distance from the axis of the
star, and the star is a discrete pencil of hypercycles at the levels `arsinh (k/q)`. -/
theorem distVLine_charge (p : ℤ) (q : ℕ) (hq : 0 < q) (m n : ℕ) (hm : 0 < m) :
    distVLine (hpoint m n hm) ((p : ℝ) / q)
      = Real.arsinh (|(charge p q m n : ℝ)| / q) := by
  rw [distVLine_hpoint m n hm p q hq]
  congr 2
  rw [show ((charge p q m n : ℝ)) = -((q : ℝ) * n - (p : ℝ) * m) by
    simp only [charge, chargeZ, Int.cast_sub, Int.cast_mul, Int.cast_natCast]; ring, abs_neg]

/-- Casting the absolute value of the charge. -/
theorem abs_charge_cast (p : ℤ) (q m n : ℕ) :
    |(charge p q m n : ℝ)| = ((|charge p q m n| : ℤ) : ℝ) := by
  rw [Int.cast_abs]

/-! ## Part 2. Parity quantisation at a general rational -/

/-- **Parity quantisation.** If the ideal point `p/q` has *both* `p` and `q` odd then every
Euclid seed has an odd charge at `p/q`: the rays of even charge are empty. (For `p = q = 1`
this is the classical statement that the `1`-star carries only odd parameters `u = m-n`.) -/
theorem charge_odd_of_odd_odd {p : ℤ} {q : ℕ} (hp : Odd p) (hq : Odd q) {m n : ℕ}
    (h : IsSeed m n) : Odd (charge p q m n) := by
  have hqz : Odd (q : ℤ) := by
    obtain ⟨t, ht⟩ := hq
    exact ⟨(t : ℤ), by exact_mod_cast congrArg (fun x : ℕ => (x : ℤ)) ht⟩
  have hmn : Odd ((m : ℤ) + n) := by
    have := h.parity
    refine Int.odd_iff.mpr ?_
    omega
  simp only [charge, chargeZ]
  rcases Int.even_or_odd (m : ℤ) with hme | hmo
  · have hno : Odd (n : ℤ) := by
      rcases Int.even_or_odd (n : ℤ) with hne | hno
      · exact absurd hmn (Int.not_odd_iff_even.mpr (hme.add hne))
      · exact hno
    exact (hme.mul_left p).sub_odd (hqz.mul hno)
  · have hne : Even (n : ℤ) := by
      rcases Int.even_or_odd (n : ℤ) with hne | hno
      · exact hne
      · exact absurd hmn (Int.not_odd_iff_even.mpr (hmo.add_odd hno))
    exact (hp.mul hmo).sub_even (hne.mul_left (q : ℤ))

/-- The star at `1/3` carries only odd charges: the ray of charge `2` over `1/3` is empty. -/
theorem no_seed_charge_two_at_one_third {m n : ℕ} (h : IsSeed m n) : charge 1 3 m n ≠ 2 := by
  intro hc
  have hodd := charge_odd_of_odd_odd (p := 1) (q := 3) ⟨0, by ring⟩ ⟨1, by ring⟩ h
  rw [hc] at hodd
  exact (Int.not_odd_iff_even.mpr ⟨1, by ring⟩) hodd

/-- The star at `1/5` — the visible fan at `0.2` — carries only odd charges. -/
theorem charge_odd_at_one_fifth {m n : ℕ} (h : IsSeed m n) : Odd (charge 1 5 m n) :=
  charge_odd_of_odd_odd ⟨0, by ring⟩ ⟨2, by ring⟩ h

/-! ## Part 3. The axis of a star: at most one node, and exactly when -/

/-- **The axis carries at most one node.** A seed has charge `0` at `p/q` (i.e. lies exactly
on the vertical geodesic over `p/q`) if and only if it is the seed `(q, p)` itself. -/
theorem charge_zero_iff_seed_eq {p q : ℕ} (hq : 0 < q) (hcop : Nat.Coprime p q)
    {m n : ℕ} (h : IsSeed m n) : charge (p : ℤ) q m n = 0 ↔ (m = q ∧ n = p) := by
  constructor
  · intro hc
    have key : p * m = q * n := by
      have h1 : (p : ℤ) * m - (q : ℤ) * n = 0 := hc
      have h2 : (p : ℤ) * m = (q : ℤ) * n := by linarith
      exact_mod_cast h2
    have hqm : q ∣ m :=
      Nat.Coprime.dvd_of_dvd_mul_left (Nat.Coprime.symm hcop) ⟨n, key⟩
    have hmq : m ∣ q := Nat.Coprime.dvd_of_dvd_mul_right h.cop ⟨p, by rw [← key]; ring⟩
    have hmq' : m = q := Nat.dvd_antisymm hmq hqm
    have hm0 : 0 < m := lt_trans h.pos h.lt
    have hpn : p = n := by
      have hmul : m * p = m * n := by
        calc m * p = p * m := Nat.mul_comm _ _
          _ = q * n := key
          _ = m * n := by rw [hmq']
      exact Nat.eq_of_mul_eq_mul_left hm0 hmul
    exact ⟨hmq', hpn.symm⟩
  · rintro ⟨rfl, rfl⟩
    simp only [charge, chargeZ]
    ring

/-- **When does the axis of a star carry a node?** Exactly when `p + q` is odd. So the
stars at `1/2, 1/4, 2/5, …` have a node sitting on their centre line, while those at
`1/3, 1/5, 3/5, …` (both entries odd) have an empty axis. -/
theorem axis_node_iff_parity {p q : ℕ} (hp : 0 < p) (hpq : p < q) (hcop : Nat.Coprime p q) :
    (∃ m n : ℕ, IsSeed m n ∧ charge (p : ℤ) q m n = 0) ↔ (p + q) % 2 = 1 := by
  have hq : 0 < q := lt_trans hp hpq
  constructor
  · rintro ⟨m, n, hs, hc⟩
    obtain ⟨rfl, rfl⟩ := (charge_zero_iff_seed_eq hq hcop hs).mp hc
    have := hs.parity
    omega
  · intro hpar
    refine ⟨q, p, ⟨hp, hpq, Nat.Coprime.symm hcop, by omega⟩, ?_⟩
    simp only [charge, chargeZ]
    ring

/-- The root seed `(2,1)` of the Berggren tree sits exactly on the axis of the star at
`1/2`: that is the node one sees at the centre of the fan at `0.5`. -/
theorem root_on_axis_one_half : charge 1 2 2 1 = 0 := by decide

/-! ## Part 4. The visibility law -/

/-- Every node off the axis of the star at `p/q` is at hyperbolic distance at least
`arsinh (1/q)` from that axis: the spokes of the star are quantised, with the innermost
one at level `arsinh (1/q)`. -/
theorem arsinh_inv_q_le_distVLine (p : ℤ) (q : ℕ) (hq : 0 < q) {m n : ℕ} (hm : 0 < m)
    (hc : charge p q m n ≠ 0) :
    Real.arsinh (1 / q) ≤ distVLine (hpoint m n hm) ((p : ℝ) / q) := by
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  rw [distVLine_charge p q hq m n hm, Real.arsinh_le_arsinh]
  have h1 : (1 : ℝ) ≤ |(charge p q m n : ℝ)| := by
    have hz : (1 : ℤ) ≤ |charge p q m n| := by
      rcases lt_or_gt_of_ne hc with h | h <;> · rw [Int.abs_eq_natAbs]; omega
    rw [abs_charge_cast]
    exact_mod_cast hz
  exact div_le_div_of_nonneg_right h1 hQ.le

/-- The fan of charges `|k| ≤ K` at `p/q` is confined to a band of hyperbolic width
`arsinh (K/q)` around the axis: a star with a large denominator `q` is compressed, which is
why only small denominators produce visually separated rays. -/
theorem distVLine_le_of_charge_le (p : ℤ) (q : ℕ) (hq : 0 < q) {m n : ℕ} (hm : 0 < m)
    {K : ℕ} (hc : |charge p q m n| ≤ (K : ℤ)) :
    distVLine (hpoint m n hm) ((p : ℝ) / q) ≤ Real.arsinh ((K : ℝ) / q) := by
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  rw [distVLine_charge p q hq m n hm, Real.arsinh_le_arsinh]
  have h1 : |(charge p q m n : ℝ)| ≤ (K : ℝ) := by
    rw [abs_charge_cast]
    exact_mod_cast hc
  exact div_le_div_of_nonneg_right h1 hQ.le

/-- **Sharpness of the visibility law** at `p/q = 1/2`: the seed `(3,2)` realises the
minimal off-axis distance `arsinh (1/2)`. -/
theorem min_gap_attained_one_half :
    distVLine (hpoint 3 2 (by norm_num)) (((1 : ℤ) : ℝ) / ((2 : ℕ) : ℝ))
      = Real.arsinh (1 / 2) := by
  rw [distVLine_charge 1 2 (by norm_num) 3 2 (by norm_num)]
  norm_num [charge, chargeZ]

/-- The innermost spoke level `arsinh (1/q)` is strictly decreasing in the denominator: the
star at a rational of large denominator is squeezed into a thin pencil. -/
theorem arsinh_inv_q_strictAnti {q q' : ℕ} (hq : 0 < q) (h : q < q') :
    Real.arsinh (1 / (q' : ℝ)) < Real.arsinh (1 / (q : ℝ)) := by
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hQ' : (q : ℝ) < (q' : ℝ) := by exact_mod_cast h
  rw [Real.arsinh_lt_arsinh]
  exact one_div_lt_one_div_of_lt hQ hQ'

/-! ## Part 5. Star covariance under the Berggren moves -/

/-- The Berggren move `B₁ : (m,n) ↦ (2m - n, m)` pulls the star at `p/q` back to the star at
`(2p-q)/p`, preserving the charge exactly. -/
theorem chargeZ_seedL (p q m n : ℤ) :
    chargeZ p q (2 * m - n) m = chargeZ (2 * p - q) p m n := by
  simp only [chargeZ]; ring

/-- The Berggren move `B₂ : (m,n) ↦ (2m + n, m)` pulls the star at `p/q` back to the star at
`(2p-q)/(-p)`, preserving the charge exactly. -/
theorem chargeZ_seedM (p q m n : ℤ) :
    chargeZ p q (2 * m + n) m = chargeZ (2 * p - q) (-p) m n := by
  simp only [chargeZ]; ring

/-- The Berggren move `B₃ : (m,n) ↦ (m + 2n, n)` pulls the star at `p/q` back to the star at
`p/(q - 2p)`, preserving the charge exactly. -/
theorem chargeZ_seedR (p q m n : ℤ) :
    chargeZ p q (m + 2 * n) n = chargeZ p (q - 2 * p) m n := by
  simp only [chargeZ]; ring

/-- Specialisation of covariance: `B₃` fixes the star at `0` (charge `-n` is conserved) and
`B₁` fixes the star at `1` (charge `m - n` is conserved). These are the two classical
conserved charges of the tree, recovered as the two fixed points of the covariance. -/
theorem chargeZ_conserved_zero_star (m n : ℤ) :
    chargeZ 0 1 (m + 2 * n) n = chargeZ 0 1 m n := by
  simp only [chargeZ]; ring

theorem chargeZ_conserved_one_star (m n : ℤ) :
    chargeZ 1 1 (2 * m - n) m = chargeZ 1 1 m n := by
  simp only [chargeZ]; ring

/-- The covariance is *unimodular*: the matrix of each Berggren move on the pair `(p,q)`
of star parameters has determinant `±1`, so it maps rationals in lowest terms to rationals
in lowest terms. Here is the statement for `B₃`. -/
theorem coprime_of_seedR_star {p q : ℤ} (h : IsCoprime p q) : IsCoprime p (q - 2 * p) := by
  obtain ⟨a, b, hab⟩ := h
  exact ⟨a + 2 * b, b, by linarith [hab]⟩

/-- …and for `B₁`. -/
theorem coprime_of_seedL_star {p q : ℤ} (h : IsCoprime p q) : IsCoprime (2 * p - q) p := by
  obtain ⟨a, b, hab⟩ := h
  exact ⟨-b, a + 2 * b, by linarith [hab]⟩

end BerggrenRationalStar