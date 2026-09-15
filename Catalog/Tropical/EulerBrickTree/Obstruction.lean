/-
# The Euler Brick Tree, III: arithmetic obstructions to the space diagonal

Two independent layers of obstruction are proved here.

**A. Local structure of *every* Euler brick.**  Working modulo `8`, `3` and `5`
we show that a brick with an odd edge has its other two edges divisible by `4`,
that at least two edges are divisible by `3`, that some edge is divisible by
`5`, and hence that `720 ∣ xyz`.  These are unconditional structure theorems
about the brick space, proved by finite residue computations combined with
integer descent-free transfer.

**B. An infinite obstructed family inside the brick tree.**  By
`Core.brick_perfect_iff`, a brick generated from the Pythagorean triple
`(u,v,w)` is a perfect cuboid *iff* `w⁴ + 16u²v²` is a square.  Modulo `7` this
fails identically whenever `u ≡ ±v (mod 7)` and `7 ∤ u`; we exhibit an explicit
infinite family of tree nodes in this congruence class, so the space-diagonal
condition provably fails along infinitely many branches of the tree.
-/
import Mathlib
import Tropical.EulerBrickTree.Core
import Tropical.EulerBrickTree.Descent

namespace EulerBrickTree

/-! ## Finite residue computations -/

private theorem mod8_leg_aux : ∀ K Y P : ZMod 8, (2 * K + 1) ^ 2 + Y ^ 2 = P ^ 2 →
    Y = 0 ∨ Y = 4 := by decide

private theorem mod3_pair_aux : ∀ X Y P : ZMod 3, X ≠ 0 → Y ≠ 0 → X ^ 2 + Y ^ 2 ≠ P ^ 2 := by
  decide

private theorem mod5_triple_aux : ∀ X Y Z P Q R : ZMod 5, X ≠ 0 → Y ≠ 0 → Z ≠ 0 →
    X ^ 2 + Y ^ 2 = P ^ 2 → X ^ 2 + Z ^ 2 = Q ^ 2 → Y ^ 2 + Z ^ 2 = R ^ 2 → False := by decide

private theorem mod7_quartic_aux : ∀ U W S : ZMod 7, U ≠ 0 → U ^ 2 + U ^ 2 = W ^ 2 →
    W ^ 4 + 16 * U ^ 2 * U ^ 2 ≠ S ^ 2 := by decide

/-! ## A. Local structure of every Euler brick -/

/-- If one leg of an integral Pythagorean pair is odd, the other is divisible
by `4`: otherwise `x² + y² ≡ 5 (mod 8)`, which is not a square. -/
theorem four_dvd_of_odd_leg {x y p : ℤ} (hx : x % 2 = 1) (h : x ^ 2 + y ^ 2 = p ^ 2) :
    (4 : ℤ) ∣ y := by
  obtain ⟨k, rfl⟩ : ∃ k : ℤ, x = 2 * k + 1 := ⟨x / 2, by omega⟩
  have hz : (2 * (k : ZMod 8) + 1) ^ 2 + (y : ZMod 8) ^ 2 = ((p : ℤ) : ZMod 8) ^ 2 := by
    have hc := congrArg (fun t : ℤ => (t : ZMod 8)) h
    push_cast at hc
    exact hc
  rcases mod8_leg_aux _ _ _ hz with h0 | h0
  · have : (8 : ℤ) ∣ y := (ZMod.intCast_zmod_eq_zero_iff_dvd y 8).mp h0
    omega
  · have : ((y - 4 : ℤ) : ZMod 8) = 0 := by push_cast [h0]; ring
    have : (8 : ℤ) ∣ y - 4 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 8).mp this
    omega

/-- Two odd edges are impossible in an Euler brick. -/
theorem no_two_odd_legs {x y p : ℤ} (hx : x % 2 = 1) (hy : y % 2 = 1) :
    x ^ 2 + y ^ 2 ≠ p ^ 2 := by
  intro h
  have := four_dvd_of_odd_leg hx h
  omega

/-- **The 2-adic shape of a brick with an odd edge:** the two remaining edges
are divisible by `4`, hence `16 ∣ y z`. -/
theorem sixteen_dvd_of_odd_edge {x y z : ℤ} (hx : x % 2 = 1) (h : IsBrick x y z) :
    (16 : ℤ) ∣ y * z := by
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, -⟩ := h
  obtain ⟨s, rfl⟩ := four_dvd_of_odd_leg hx hp
  obtain ⟨t, rfl⟩ := four_dvd_of_odd_leg hx hq
  exact ⟨s * t, by ring⟩

/-- In a Pythagorean pair at least one leg is divisible by `3`. -/
theorem three_dvd_leg {x y p : ℤ} (h : x ^ 2 + y ^ 2 = p ^ 2) :
    (3 : ℤ) ∣ x ∨ (3 : ℤ) ∣ y := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨hx, hy⟩ := hcon
  have hX : ((x : ℤ) : ZMod 3) ≠ 0 := fun hh =>
    hx ((ZMod.intCast_zmod_eq_zero_iff_dvd x 3).mp hh)
  have hY : ((y : ℤ) : ZMod 3) ≠ 0 := fun hh =>
    hy ((ZMod.intCast_zmod_eq_zero_iff_dvd y 3).mp hh)
  have hz : ((x : ℤ) : ZMod 3) ^ 2 + ((y : ℤ) : ZMod 3) ^ 2 = ((p : ℤ) : ZMod 3) ^ 2 := by
    have hc := congrArg (fun t : ℤ => (t : ZMod 3)) h
    push_cast at hc
    exact hc
  exact mod3_pair_aux _ _ _ hX hY hz

/-- **The 3-adic shape:** at least two edges of an Euler brick are divisible by
`3`, hence `9 ∣ xyz`. -/
theorem nine_dvd_prod {x y z : ℤ} (h : IsBrick x y z) : (9 : ℤ) ∣ x * y * z := by
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, ⟨r, hr⟩⟩ := h
  rcases three_dvd_leg hp with hx | hy
  · rcases three_dvd_leg hq with hx' | hz
    · -- `3 ∣ x` twice is not enough; use the `y, z` face instead
      rcases three_dvd_leg hr with hy | hz
      · obtain ⟨a, rfl⟩ := hx; obtain ⟨b, rfl⟩ := hy
        exact ⟨a * b * z, by ring⟩
      · obtain ⟨a, rfl⟩ := hx; obtain ⟨c, rfl⟩ := hz
        exact ⟨a * y * c, by ring⟩
    · obtain ⟨a, rfl⟩ := hx; obtain ⟨c, rfl⟩ := hz
      exact ⟨a * y * c, by ring⟩
  · rcases three_dvd_leg hq with hx | hz
    · obtain ⟨b, rfl⟩ := hy; obtain ⟨a, rfl⟩ := hx
      exact ⟨a * b * z, by ring⟩
    · obtain ⟨b, rfl⟩ := hy; obtain ⟨c, rfl⟩ := hz
      exact ⟨x * b * c, by ring⟩

/-- **The 5-adic shape:** some edge of an Euler brick is divisible by `5`. -/
theorem five_dvd_prod {x y z : ℤ} (h : IsBrick x y z) : (5 : ℤ) ∣ x * y * z := by
  obtain ⟨⟨p, hp⟩, ⟨q, hq⟩, ⟨r, hr⟩⟩ := h
  by_contra hcon
  have hx : ¬ (5:ℤ) ∣ x := fun hh => hcon (Dvd.dvd.mul_right (Dvd.dvd.mul_right hh y) z)
  have hy : ¬ (5:ℤ) ∣ y := fun hh =>
    hcon (Dvd.dvd.mul_right (Dvd.dvd.mul_left hh x) z)
  have hz : ¬ (5:ℤ) ∣ z := fun hh => hcon (Dvd.dvd.mul_left hh (x * y))
  have hX : ((x : ℤ) : ZMod 5) ≠ 0 := fun hh =>
    hx ((ZMod.intCast_zmod_eq_zero_iff_dvd x 5).mp hh)
  have hY : ((y : ℤ) : ZMod 5) ≠ 0 := fun hh =>
    hy ((ZMod.intCast_zmod_eq_zero_iff_dvd y 5).mp hh)
  have hZ : ((z : ℤ) : ZMod 5) ≠ 0 := fun hh =>
    hz ((ZMod.intCast_zmod_eq_zero_iff_dvd z 5).mp hh)
  have c1 : ((x : ℤ) : ZMod 5) ^ 2 + ((y : ℤ) : ZMod 5) ^ 2 = ((p : ℤ) : ZMod 5) ^ 2 := by
    have hc := congrArg (fun t : ℤ => (t : ZMod 5)) hp; push_cast at hc; exact hc
  have c2 : ((x : ℤ) : ZMod 5) ^ 2 + ((z : ℤ) : ZMod 5) ^ 2 = ((q : ℤ) : ZMod 5) ^ 2 := by
    have hc := congrArg (fun t : ℤ => (t : ZMod 5)) hq; push_cast at hc; exact hc
  have c3 : ((y : ℤ) : ZMod 5) ^ 2 + ((z : ℤ) : ZMod 5) ^ 2 = ((r : ℤ) : ZMod 5) ^ 2 := by
    have hc := congrArg (fun t : ℤ => (t : ZMod 5)) hr; push_cast at hc; exact hc
  exact mod5_triple_aux _ _ _ _ _ _ hX hY hZ c1 c2 c3

/-- **`720 ∣ xyz` for every Euler brick with an odd edge.**  (Since a brick with
all edges even is a scaling of a smaller brick, this covers the primitive case,
where exactly one edge is odd.) -/
theorem seven_hundred_twenty_dvd {x y z : ℤ} (hx : x % 2 = 1) (h : IsBrick x y z) :
    (720 : ℤ) ∣ x * y * z := by
  have h16 : (16 : ℤ) ∣ x * y * z := by
    obtain ⟨k, hk⟩ := sixteen_dvd_of_odd_edge hx h
    exact ⟨k * x, by rw [show x * y * z = x * (y * z) by ring, hk]; ring⟩
  have h9 : (9 : ℤ) ∣ x * y * z := nine_dvd_prod h
  have h5 : (5 : ℤ) ∣ x * y * z := five_dvd_prod h
  have c169 : IsCoprime (16 : ℤ) 9 := Int.isCoprime_iff_gcd_eq_one.mpr (by norm_num)
  have h144 : (144 : ℤ) ∣ x * y * z := by
    have := c169.mul_dvd h16 h9
    norm_num at this
    exact this
  have c1445 : IsCoprime (144 : ℤ) 5 := Int.isCoprime_iff_gcd_eq_one.mpr (by norm_num)
  have := c1445.mul_dvd h144 h5
  norm_num at this
  exact this

/-- The classical brick `(117,44,240)` obeys the `720` law. -/
example : (720 : ℤ) ∣ 117 * 44 * 240 := seven_hundred_twenty_dvd (by norm_num) brick_root_isBrick

/-! ## B. An infinite obstructed family inside the brick tree -/

/-- **Mod-7 obstruction.**  If `u ≡ v (mod 7)` and `7 ∤ u`, the brick generated
by the Pythagorean triple `(u,v,w)` is *not* a perfect cuboid: the quartic
`w⁴ + 16u²v²` is congruent to `6u⁴ (mod 7)`, a quadratic nonresidue. -/
theorem brick_not_perfect_of_mod7 {u v w : ℤ} (h : IsPT u v w) (hw : w ≠ 0)
    (huv : (7 : ℤ) ∣ (u - v)) (hu : ¬ (7 : ℤ) ∣ u) :
    ¬ IsPerfectCuboid (brick u v w).1 (brick u v w).2.1 (brick u v w).2.2 := by
  intro hperf
  obtain ⟨s, hs⟩ := (brick_perfect_iff h hw).mp hperf
  have hUV : ((u : ℤ) : ZMod 7) = ((v : ℤ) : ZMod 7) := by
    have hz := (ZMod.intCast_zmod_eq_zero_iff_dvd (u - v) 7).mpr huv
    push_cast at hz
    linear_combination hz
  have hU : ((u : ℤ) : ZMod 7) ≠ 0 := fun hh =>
    hu ((ZMod.intCast_zmod_eq_zero_iff_dvd u 7).mp hh)
  have hpt7 : ((u : ℤ) : ZMod 7) ^ 2 + ((u : ℤ) : ZMod 7) ^ 2 = ((w : ℤ) : ZMod 7) ^ 2 := by
    have hc := congrArg (fun t : ℤ => (t : ZMod 7)) h
    push_cast at hc
    rw [← hUV] at hc
    exact hc
  have hs7 : ((w : ℤ) : ZMod 7) ^ 4 + 16 * ((u : ℤ) : ZMod 7) ^ 2 * ((u : ℤ) : ZMod 7) ^ 2
      = ((s : ℤ) : ZMod 7) ^ 2 := by
    have hc := congrArg (fun t : ℤ => (t : ZMod 7)) hs
    push_cast at hc
    rw [← hUV] at hc
    exact hc
  exact mod7_quartic_aux _ _ _ hU hpt7 hs7

/-- The explicit obstructed nodes: for every `j ≥ 0` the triple
`(m²-1, 2m, m²+1)` with `m = 14j+4` is a primitive Pythagorean triple with odd
first leg, i.e. a node of the Berggren tree. -/
theorem obstructed_node_isPPT {m j : ℤ} (hj : 0 ≤ j) (hm : m = 14 * j + 4) :
    IsPPT (m ^ 2 - 1) (2 * m) (m ^ 2 + 1) := by
  have hm4 : 4 ≤ m := by omega
  refine ⟨by nlinarith, by omega, by nlinarith, by unfold IsPT; ring, ?_, ?_⟩
  · refine Int.isCoprime_iff_gcd_eq_one.mp ⟨-1, 7 * j + 2, ?_⟩
    subst hm
    ring
  · have hpar : m ^ 2 - 1 = 2 * (2 * (7 * j + 2) ^ 2) - 1 := by
      subst hm; ring
    omega

/-- The `m = 14j+4` nodes satisfy the mod-7 congruence `u ≡ v (mod 7)`. -/
theorem obstructed_node_congr {m j : ℤ} (hm : m = 14 * j + 4) :
    (7 : ℤ) ∣ ((m ^ 2 - 1) - 2 * m) ∧ ¬ (7 : ℤ) ∣ (m ^ 2 - 1) := by
  constructor
  · exact ⟨28 * j ^ 2 + 12 * j + 1, by subst hm; ring⟩
  · rintro ⟨k, hk⟩
    have hk' : 196 * j ^ 2 + 112 * j + 15 = 7 * k := by
      rw [hm] at hk; linarith [hk]
    have h1 : (7 : ℤ) ∣ 1 := ⟨k - (28 * j ^ 2 + 16 * j + 2), by linarith⟩
    norm_num at h1

/-- **Obstruction along infinitely many branches.**  For every `j ≥ 0` the node
`(m²-1, 2m, m²+1)`, `m = 14j+4`, lies in the Berggren tree, its Saunderson
brick is a genuine nondegenerate Euler brick, and that brick is provably *not*
a perfect cuboid.  The third edge of the `j`-th brick exceeds `j`, so the family
is infinite and unbounded: the space-diagonal condition fails along infinitely
many distinct branches of the brick tree. -/
theorem infinite_obstructed_family {j : ℤ} (hj : 0 ≤ j) :
    ∃ a b c : ℤ, TreeReach a b c ∧
      IsBrick (brick a b c).1 (brick a b c).2.1 (brick a b c).2.2 ∧
      Nondegenerate (brick a b c).1 (brick a b c).2.1 (brick a b c).2.2 ∧
      ¬ IsPerfectCuboid (brick a b c).1 (brick a b c).2.1 (brick a b c).2.2 ∧
      j < (brick a b c).2.2 := by
  obtain ⟨ha, hb, hc, hpt, hgcd, hodd⟩ := obstructed_node_isPPT hj (m := 14 * j + 4) rfl
  obtain ⟨hdvd, hndvd⟩ := obstructed_node_congr (m := 14 * j + 4) rfl
  set m : ℤ := 14 * j + 4 with hm
  have hm4 : 4 ≤ m := by omega
  refine ⟨m ^ 2 - 1, 2 * m, m ^ 2 + 1, ppt_treeReach ⟨ha, hb, hc, hpt, hgcd, hodd⟩,
    brick_isBrick hpt, brick_nondegenerate hpt ha hb hc hgcd,
    brick_not_perfect_of_mod7 hpt (by nlinarith) hdvd hndvd, ?_⟩
  have hval : (brick (m ^ 2 - 1) (2 * m) (m ^ 2 + 1)).2.2
      = 4 * (m ^ 2 - 1) * (2 * m) * (m ^ 2 + 1) := rfl
  rw [hval]
  have hB : 15 ≤ m ^ 2 - 1 := by nlinarith
  have hC : 17 ≤ m ^ 2 + 1 := by nlinarith
  have hD : 15 * 17 ≤ (m ^ 2 - 1) * (m ^ 2 + 1) := by nlinarith
  have key : 8 * m * (15 * 17) ≤ 8 * m * ((m ^ 2 - 1) * (m ^ 2 + 1)) :=
    mul_le_mul_of_nonneg_left hD (by positivity)
  have hprod : m ≤ 4 * (m ^ 2 - 1) * (2 * m) * (m ^ 2 + 1) := by nlinarith [key]
  linarith

/-- **The perfect-cuboid question on the tree is exactly one quartic question.**
For a node `(a,b,c)` of the Berggren tree, the brick over it is a perfect cuboid
iff `c⁴ + 16a²b²` is a square. -/
theorem treeBrick_perfect_iff {a b c : ℤ} (h : TreeReach a b c) :
    IsPerfectCuboid (brick a b c).1 (brick a b c).2.1 (brick a b c).2.2 ↔
      ∃ s : ℤ, c ^ 4 + 16 * a ^ 2 * b ^ 2 = s ^ 2 := by
  obtain ⟨-, -, hc, hpt, -, -⟩ := treeReach_ppt h
  exact brick_perfect_iff hpt (by omega)

end EulerBrickTree