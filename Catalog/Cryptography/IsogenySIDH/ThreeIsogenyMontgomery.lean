/-
# Level three: the 3-isogeny of a Montgomery curve and its `Φ₃` certificate

The previous cycle's Conjecture 1 asked for the level-`ℓ` analogue of the
`Φ₂`-certificate proved in `ModularTwoIsogeny`: an explicit Montgomery-side
`ℓ`-isogeny formula together with a proof that the source and target
`j`-invariants are a zero of the classical modular polynomial `Φ_ℓ`.  This file
delivers the case `ℓ = 3`, which is the case used by SIDH/SIKE-style protocols
on the "3-side" of the isogeny graph.

Set-up: `E_A : y² = x³ + A x² + x` has a point of order three with abscissa `r`
exactly when `r` is a root of the three-division polynomial

  `threeDivPoly A r = 3r⁴ + 4A r³ + 6r² - 1`.

Then (Costello–Hisil) the quotient by that point is the Montgomery curve with
parameter `threeIsoParam A r = (A r - 6r² + 6) r`, and the quotient map is

  `(x,y) ↦ ( x (xr-1)²/(x-r)² , y (xr-1)(x²r - 3xr² + x + r)/(x-r)³ )`.

Results:

* `threeDivPoly_root_ne_zero` — a root of the three-division polynomial is
  automatically nonzero, so the formulas never divide by zero at `r`.
* `threeIso_mem` — **correctness of the explicit 3-isogeny**: the map above
  sends affine points of `E_A` (away from the kernel abscissa `r`) to the
  generalized Montgomery curve `r² Y² = X³ + A' X² + X`; the twist coefficient
  is exactly `r²`.  This is the level-3 analogue of `radTwoIso_mem`.
* `three_param_eq`, `three_target_eq` — the whole configuration is uniformised
  by `r`: `A = (1 - 6r² - 3r⁴)/(4r³)` and `A' = (1 + 18r² - 27r⁴)/(4r)`, so both
  curves are points of a one-parameter family.  This is what makes the modular
  identity a *univariate* rational identity.
* `mont3Source_disc`, `mont3Target_disc` — the two discriminant factors are
  `A² - 4 = (r²-1)³(9r²-1)/(16r⁶)` and `A'² - 4 = (9r²-1)³(r²-1)/(16r²)`; the
  striking exchange of exponents `3 ↔ 1` between source and target is the
  fingerprint of the degree-3 isogeny.
* `modPoly3_three_isogeny` — **the `Φ₃` certificate**: `Φ₃(j(E_A), j(E_{A'})) = 0`.
* `three_isogeny_dual_involution` — `r ↦ 1/(3r)` exchanges source and target up
  to sign, i.e. it realises the dual isogeny on the uniformising parameter.
* `three_isogeny_neighbours_card_le_four` — `Φ₃` is monic of degree four in each
  variable, so the 3-isogeny graph is at most 4-regular.
-/
import Cryptography.IsogenySIDH.MontgomeryModelFibres

set_option maxHeartbeats 2000000

namespace Cryptography.IsogenySIDH

open Polynomial

variable {K : Type*} [Field K]

/-! ## The three-division polynomial and the Costello–Hisil formulas -/

/-- The three-division polynomial of the Montgomery curve `E_A`; its roots are
the abscissae of the points of order three. -/
def threeDivPoly (A r : K) : K := 3 * r ^ 4 + 4 * A * r ^ 3 + 6 * r ^ 2 - 1

/-- The Montgomery parameter of the quotient of `E_A` by the order-three point
with abscissa `r`. -/
def threeIsoParam (A r : K) : K := (A * r - 6 * r ^ 2 + 6) * r

/-- The twist coefficient of the target model of the 3-isogeny. -/
def threeIsoTwist (r : K) : K := r ^ 2

/-- The explicit 3-isogeny of Montgomery curves. -/
def threeIsoMap (r : K) (P : K × K) : K × K :=
  (P.1 * (P.1 * r - 1) ^ 2 / (P.1 - r) ^ 2,
    P.2 * (P.1 * r - 1) * (P.1 ^ 2 * r - 3 * P.1 * r ^ 2 + P.1 + r) / (P.1 - r) ^ 3)

/-- A root of the three-division polynomial is never zero. -/
theorem threeDivPoly_root_ne_zero {A r : K} (h : threeDivPoly A r = 0) : r ≠ 0 := by
  intro hr
  rw [hr] at h
  simp only [threeDivPoly] at h
  norm_num at h

/-- **Correctness of the explicit 3-isogeny.**  If `(x,y)` is an affine point of
`E_A` and `r` is the abscissa of a point of order three, then the image point
lies on the generalized Montgomery curve with parameter `threeIsoParam A r` and
twist coefficient `r²`. -/
theorem threeIso_mem {A r x y : K} (htwo : (2 : K) ≠ 0)
    (hpsi : threeDivPoly A r = 0) (hxr : x - r ≠ 0) (hP : OnMontgomery A (x, y)) :
    genMont (threeIsoTwist r) (threeIsoParam A r) (threeIsoMap r (x, y)) := by
  have hr : r ≠ 0 := threeDivPoly_root_ne_zero hpsi
  have hP' : y ^ 2 = x ^ 3 + A * x ^ 2 + x := hP
  have hpsi' : 3 * r ^ 4 + 4 * A * r ^ 3 + 6 * r ^ 2 - 1 = 0 := hpsi
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero htwo htwo
  have h4r3 : (4 : K) * r ^ 3 ≠ 0 := mul_ne_zero hfour (pow_ne_zero 3 hr)
  have hA : A = (1 - 6 * r ^ 2 - 3 * r ^ 4) / (4 * r ^ 3) := by
    rw [eq_div_iff h4r3]
    linear_combination hpsi'
  subst hA
  simp only [genMont, threeIsoTwist, threeIsoParam, threeIsoMap]
  have h2 : (y * (x * r - 1) * (x ^ 2 * r - 3 * x * r ^ 2 + x + r) / (x - r) ^ 3) ^ 2
      = y ^ 2 * ((x * r - 1) * (x ^ 2 * r - 3 * x * r ^ 2 + x + r) / (x - r) ^ 3) ^ 2 := by
    ring
  rw [h2, hP']
  field_simp
  ring

/-! ## Uniformisation by the kernel abscissa -/

/-- The source parameter of the one-parameter family. -/
def mont3Source (r : K) : K := (1 - 6 * r ^ 2 - 3 * r ^ 4) / (4 * r ^ 3)

/-- The target parameter of the one-parameter family. -/
def mont3Target (r : K) : K := (1 + 18 * r ^ 2 - 27 * r ^ 4) / (4 * r)

theorem two_pow_ne_zero_aux (htwo : (2 : K) ≠ 0) : (4 : K) ≠ 0 := by
  have h : (4 : K) = 2 * 2 := by norm_num
  rw [h]; exact mul_ne_zero htwo htwo

/-- Every Montgomery curve with a marked point of order three is a member of the
family, with the kernel abscissa as parameter. -/
theorem three_param_eq {A r : K} (htwo : (2 : K) ≠ 0) (hpsi : threeDivPoly A r = 0) :
    A = mont3Source r := by
  have hr : r ≠ 0 := threeDivPoly_root_ne_zero hpsi
  have h4r3 : (4 : K) * r ^ 3 ≠ 0 :=
    mul_ne_zero (two_pow_ne_zero_aux htwo) (pow_ne_zero 3 hr)
  have hpsi' : 3 * r ^ 4 + 4 * A * r ^ 3 + 6 * r ^ 2 - 1 = 0 := hpsi
  rw [mont3Source, eq_div_iff h4r3]
  linear_combination hpsi'

/-- …and its 3-isogenous target is the corresponding member of the target
family. -/
theorem three_target_eq {A r : K} (htwo : (2 : K) ≠ 0) (hpsi : threeDivPoly A r = 0) :
    threeIsoParam A r = mont3Target r := by
  have hr : r ≠ 0 := threeDivPoly_root_ne_zero hpsi
  have h4r : (4 : K) * r ≠ 0 := mul_ne_zero (two_pow_ne_zero_aux htwo) hr
  have hpsi' : 3 * r ^ 4 + 4 * A * r ^ 3 + 6 * r ^ 2 - 1 = 0 := hpsi
  rw [threeIsoParam, mont3Target, eq_div_iff h4r]
  linear_combination hpsi'

/-! ## Discriminant factors -/

theorem mont3Source_disc {r : K} (htwo : (2 : K) ≠ 0) (hr : r ≠ 0) :
    (mont3Source r) ^ 2 - 4 = (r ^ 2 - 1) ^ 3 * (9 * r ^ 2 - 1) / (16 * r ^ 6) := by
  have hfour : (4 : K) ≠ 0 := two_pow_ne_zero_aux htwo
  have h16 : (16 : K) ≠ 0 := by
    have h : (16 : K) = 4 * 4 := by norm_num
    rw [h]; exact mul_ne_zero hfour hfour
  simp only [mont3Source]
  field_simp
  ring

theorem mont3Target_disc {r : K} (htwo : (2 : K) ≠ 0) (hr : r ≠ 0) :
    (mont3Target r) ^ 2 - 4 = (9 * r ^ 2 - 1) ^ 3 * (r ^ 2 - 1) / (16 * r ^ 2) := by
  have hfour : (4 : K) ≠ 0 := two_pow_ne_zero_aux htwo
  have h16 : (16 : K) ≠ 0 := by
    have h : (16 : K) = 4 * 4 := by norm_num
    rw [h]; exact mul_ne_zero hfour hfour
  simp only [mont3Target]
  field_simp
  ring

/-! ## The `j`-invariants of the family -/

/-- Numerator polynomial of the source `j`-invariant. -/
def threeNumP (r : K) : K := 9 * r ^ 8 - 12 * r ^ 6 + 30 * r ^ 4 - 12 * r ^ 2 + 1

/-- Numerator polynomial of the target `j`-invariant. -/
def threeNumQ (r : K) : K := 729 * r ^ 8 - 972 * r ^ 6 + 270 * r ^ 4 - 12 * r ^ 2 + 1

/-- The source `j`-invariant as a rational function of the kernel abscissa. -/
def jSource3 (r : K) : K := threeNumP r ^ 3 / (r ^ 12 * (r ^ 2 - 1) ^ 3 * (9 * r ^ 2 - 1))

/-- The target `j`-invariant as a rational function of the kernel abscissa. -/
def jTarget3 (r : K) : K := threeNumQ r ^ 3 / (r ^ 4 * (9 * r ^ 2 - 1) ^ 3 * (r ^ 2 - 1))

theorem jMont_mont3Source {r : K} (htwo : (2 : K) ≠ 0) (hr : r ≠ 0)
    (h1 : r ^ 2 - 1 ≠ 0) :
    jMont (mont3Source r) = jSource3 r := by
  have hfour : (4 : K) ≠ 0 := two_pow_ne_zero_aux htwo
  have h16 : (16 : K) ≠ 0 := by
    have h : (16 : K) = 4 * 4 := by norm_num
    rw [h]; exact mul_ne_zero hfour hfour
  have e3 : (mont3Source r) ^ 2 - 3 = threeNumP r / (16 * r ^ 6) := by
    simp only [mont3Source, threeNumP]; field_simp; ring
  have e4 : (mont3Source r) ^ 2 - 4 = (r ^ 2 - 1) ^ 3 * (9 * r ^ 2 - 1) / (16 * r ^ 6) :=
    mont3Source_disc htwo hr
  simp only [jMont, jSource3, e3, e4]
  field_simp
  ring

theorem jMont_mont3Target {r : K} (htwo : (2 : K) ≠ 0) (hr : r ≠ 0)
    (h1 : r ^ 2 - 1 ≠ 0) :
    jMont (mont3Target r) = jTarget3 r := by
  have hfour : (4 : K) ≠ 0 := two_pow_ne_zero_aux htwo
  have h16 : (16 : K) ≠ 0 := by
    have h : (16 : K) = 4 * 4 := by norm_num
    rw [h]; exact mul_ne_zero hfour hfour
  have e3 : (mont3Target r) ^ 2 - 3 = threeNumQ r / (16 * r ^ 2) := by
    simp only [mont3Target, threeNumQ]; field_simp; ring
  have e4 : (mont3Target r) ^ 2 - 4 = (9 * r ^ 2 - 1) ^ 3 * (r ^ 2 - 1) / (16 * r ^ 2) :=
    mont3Target_disc htwo hr
  simp only [jMont, jTarget3, e3, e4]
  field_simp
  ring

/-! ## The level-three modular polynomial -/

/-- The classical modular polynomial of level three. -/
def modPoly3 (X Y : K) : K :=
  X ^ 4 + Y ^ 4 - X ^ 3 * Y ^ 3 + 2232 * (X ^ 3 * Y ^ 2 + X ^ 2 * Y ^ 3)
    - 1069956 * (X ^ 3 * Y + X * Y ^ 3) + 36864000 * (X ^ 3 + Y ^ 3)
    + 2587918086 * (X ^ 2 * Y ^ 2) + 8900222976000 * (X ^ 2 * Y + X * Y ^ 2)
    + 452984832000000 * (X ^ 2 + Y ^ 2) - 770845966336000000 * (X * Y)
    + 1855425871872000000000 * (X + Y)

/-- `Φ₃` is symmetric: the 3-isogeny graph is undirected. -/
theorem modPoly3_symm (X Y : K) : modPoly3 X Y = modPoly3 Y X := by
  simp only [modPoly3]; ring

/-- **The core level-three identity.**  Along the one-parameter family the pair
of `j`-invariants is a zero of `Φ₃`; this is a rational identity in the single
uniformising variable `r`. -/
theorem modPoly3_jSource3_jTarget3 {r : K} (hr : r ≠ 0) (h1 : r ^ 2 - 1 ≠ 0)
    (h9 : 9 * r ^ 2 - 1 ≠ 0) : modPoly3 (jSource3 r) (jTarget3 r) = 0 := by
  simp only [modPoly3, jSource3, jTarget3, threeNumP, threeNumQ]
  field_simp
  ring

/-- **The `Φ₃` certificate for the Montgomery 3-isogeny.**  If `r` is the
abscissa of a point of order three on `E_A` and the two degenerate loci
`r² = 1`, `9r² = 1` are avoided, then the `j`-invariant of `E_A` and the
`j`-invariant of the Costello–Hisil target are a zero of the level-three modular
polynomial.  This is the level-3 analogue of `modPoly2_radical_step`. -/
theorem modPoly3_three_isogeny {A r : K} (htwo : (2 : K) ≠ 0)
    (hpsi : threeDivPoly A r = 0) (h1 : r ^ 2 - 1 ≠ 0) (h9 : 9 * r ^ 2 - 1 ≠ 0) :
    modPoly3 (jMont A) (jMont (threeIsoParam A r)) = 0 := by
  have hr : r ≠ 0 := threeDivPoly_root_ne_zero hpsi
  rw [three_target_eq htwo hpsi, three_param_eq htwo hpsi,
    jMont_mont3Source htwo hr h1, jMont_mont3Target htwo hr h1]
  exact modPoly3_jSource3_jTarget3 hr h1 h9

/-- The dual direction is certified as well. -/
theorem modPoly3_three_isogeny_dual {A r : K} (htwo : (2 : K) ≠ 0)
    (hpsi : threeDivPoly A r = 0) (h1 : r ^ 2 - 1 ≠ 0) (h9 : 9 * r ^ 2 - 1 ≠ 0) :
    modPoly3 (jMont (threeIsoParam A r)) (jMont A) = 0 := by
  rw [modPoly3_symm]
  exact modPoly3_three_isogeny htwo hpsi h1 h9

/-! ## The dual isogeny as an involution of the parameter -/

/-- **The dual 3-isogeny on the uniformising parameter.**  Replacing `r` by
`1/(3r)` exchanges the source and the target of the family (up to the sign of
the Montgomery parameter, which does not change the curve).  So the involution
`r ↦ 1/(3r)` of the parameter line realises the dual isogeny. -/
theorem three_isogeny_dual_involution {r : K} (htwo : (2 : K) ≠ 0) (hthree : (3 : K) ≠ 0)
    (hr : r ≠ 0) : mont3Source (1 / (3 * r)) = -(mont3Target r) := by
  have h3r : (3 : K) * r ≠ 0 := mul_ne_zero hthree hr
  have hfour : (4 : K) ≠ 0 := two_pow_ne_zero_aux htwo
  simp only [mont3Source, mont3Target]
  rw [div_eq_iff (by exact mul_ne_zero hfour (pow_ne_zero 3 (one_div_ne_zero h3r)))]
  field_simp
  ring

/-- Consequently the two curves of a 3-isogeny pair are exchanged by the
involution, on the level of `j`-invariants. -/
theorem jMont_dual_involution {r : K} (htwo : (2 : K) ≠ 0) (hthree : (3 : K) ≠ 0)
    (hr : r ≠ 0) : jMont (mont3Source (1 / (3 * r))) = jMont (mont3Target r) := by
  rw [three_isogeny_dual_involution htwo hthree hr, jMont_neg]

/-! ## The 3-isogeny graph is at most 4-regular -/

/-- `Φ₃(j, ·)` as an honest univariate polynomial. -/
noncomputable def modPoly3Y (j : K) : K[X] :=
  C 1 * X ^ 4 + C (-(j ^ 3) + 2232 * j ^ 2 - 1069956 * j + 36864000) * X ^ 3
    + C (2232 * j ^ 3 + 2587918086 * j ^ 2 + 8900222976000 * j + 452984832000000) * X ^ 2
    + C (-1069956 * j ^ 3 + 8900222976000 * j ^ 2 - 770845966336000000 * j
        + 1855425871872000000000) * X
    + C (j ^ 4 + 36864000 * j ^ 3 + 452984832000000 * j ^ 2
        + 1855425871872000000000 * j)

theorem modPoly3Y_eval (j y : K) : (modPoly3Y j).eval y = modPoly3 j y := by
  simp only [modPoly3Y, modPoly3, eval_add, eval_mul, eval_pow, eval_C, eval_X]
  ring

theorem modPoly3Y_natDegree (j : K) : (modPoly3Y j).natDegree = 4 := by
  unfold modPoly3Y
  compute_degree!

theorem modPoly3Y_ne_zero (j : K) : modPoly3Y j ≠ 0 := by
  intro h
  have hdeg := modPoly3Y_natDegree j
  rw [h] at hdeg
  simp at hdeg

/-- **The 3-isogeny graph is at most 4-regular.**  For a fixed `j`, at most four
values `j'` satisfy `Φ₃(j, j') = 0`; this is the branching bound for 3-isogeny
walks, the level-3 counterpart of `two_isogeny_neighbours_card_le_three`. -/
theorem three_isogeny_neighbours_card_le_four [DecidableEq K] (j : K)
    (S : Finset K) (hS : ∀ y ∈ S, modPoly3 j y = 0) : S.card ≤ 4 := by
  have hsub : S ⊆ (modPoly3Y j).roots.toFinset := by
    intro y hy
    rw [Multiset.mem_toFinset, mem_roots (modPoly3Y_ne_zero j), IsRoot, modPoly3Y_eval]
    exact hS y hy
  calc S.card ≤ (modPoly3Y j).roots.toFinset.card := Finset.card_le_card hsub
    _ ≤ Multiset.card (modPoly3Y j).roots := Multiset.toFinset_card_le _
    _ ≤ (modPoly3Y j).natDegree := card_roots' _
    _ = 4 := modPoly3Y_natDegree j

end Cryptography.IsogenySIDH