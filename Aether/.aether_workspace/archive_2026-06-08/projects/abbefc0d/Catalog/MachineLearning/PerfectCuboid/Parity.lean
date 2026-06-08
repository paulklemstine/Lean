/-
# Perfect Cuboid — Parity and Modular Obstructions

We prove fundamental parity constraints on perfect cuboids:
- Three odd edges cannot yield an integer space diagonal (mod 4).
- All-even edges violate primitivity.
- Exactly one even edge yields sum ≡ 2 (mod 4), not a square.
- Therefore, a primitive perfect cuboid must have exactly two even edges.
- Both even edges must be divisible by 4 (mod 8 obstruction).
- The space diagonal is always odd in the primitive case.
-/
import Mathlib

namespace PerfectCuboid

def IsSquare (n : ℕ) : Prop := ∃ k : ℕ, k ^ 2 = n

def IsEulerBrick (x y z : ℕ) : Prop :=
  IsSquare (x ^ 2 + y ^ 2) ∧
  IsSquare (x ^ 2 + z ^ 2) ∧
  IsSquare (y ^ 2 + z ^ 2)

def IsPerfectCuboid (x y z : ℕ) : Prop :=
  IsEulerBrick x y z ∧ IsSquare (x ^ 2 + y ^ 2 + z ^ 2)

def PrimitiveTriple (x y z : ℕ) : Prop :=
  Nat.gcd x (Nat.gcd y z) = 1

/-- Exactly one of three natural numbers is even. -/
def ExactlyOneEven (x y z : ℕ) : Prop :=
  (Even x ∧ Odd y ∧ Odd z) ∨
  (Odd x ∧ Even y ∧ Odd z) ∨
  (Odd x ∧ Odd y ∧ Even z)

/-- Exactly two of three natural numbers are even. -/
def ExactlyTwoEven (x y z : ℕ) : Prop :=
  (Even x ∧ Even y ∧ Odd z) ∨
  (Even x ∧ Odd y ∧ Even z) ∨
  (Odd x ∧ Even y ∧ Even z)

/-- **Mod-4 obstruction for all-odd edges.**
If all three of x, y, z are odd, then x² + y² + z² ≡ 3 (mod 4),
which cannot be a perfect square. -/
theorem not_all_odd_if_sum_square {x y z d : ℕ}
    (hx : Odd x) (hy : Odd y) (hz : Odd z)
    (hd : d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2) : False := by
  apply_fun fun n => n % 4 at hd; rcases hx with ⟨ m, rfl ⟩ ; rcases hy with ⟨ n, rfl ⟩ ; rcases hz with ⟨ o, rfl ⟩ ; rcases Nat.even_or_odd' d with ⟨ p, rfl | rfl ⟩ <;> ring_nf at hd <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at hd;

/-- **Primitivity excludes all-even.**
If all three edges are even, then gcd(x, gcd(y, z)) ≥ 2. -/
theorem not_all_even_if_primitive {x y z : ℕ}
    (hprim : PrimitiveTriple x y z)
    (hx : Even x) (hy : Even y) (hz : Even z) : False := by
  exact absurd ( hprim ▸ Nat.dvd_gcd ( even_iff_two_dvd.mp hx ) ( Nat.dvd_gcd ( even_iff_two_dvd.mp hy ) ( even_iff_two_dvd.mp hz ) ) ) ( by decide )

/-
**Mod-4 obstruction for exactly one even edge.**
If exactly one edge is even and two are odd, then x² + y² + z² ≡ 2 (mod 4),
which cannot be a perfect square.
-/
theorem not_one_even_if_sum_square {x y z d : ℕ}
    (hx : Even x) (hy : Odd y) (hz : Odd z)
    (hd : d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2) : False := by
  apply_fun fun n => n % 4 at hd; rcases hx with ⟨ m, rfl ⟩ ; rcases hy with ⟨ n, rfl ⟩ ; rcases hz with ⟨ o, rfl ⟩ ; rcases Nat.even_or_odd' d with ⟨ p, rfl | rfl ⟩ <;> ring_nf at hd <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at hd;

/-
**Parity theorem for primitive perfect cuboids.**
A nontrivial primitive perfect cuboid must have exactly two even edges
and one odd edge.

This follows from three obstructions:
- All odd: x² + y² + z² ≡ 3 (mod 4), not a square.
- All even: violates primitivity.
- Exactly one even: x² + y² + z² ≡ 2 (mod 4), not a square.
-/
theorem primitive_perfect_cuboid_exactly_two_even
    {x y z : ℕ}
    (hprim : PrimitiveTriple x y z)
    (hpc : IsPerfectCuboid x y z)
    (hpos : 0 < x ∨ 0 < y ∨ 0 < z) :
    ExactlyTwoEven x y z := by
  by_cases hx : Even x <;> by_cases hy : Even y <;> by_cases hz : Even z <;> simp_all +decide [ ExactlyTwoEven ];
  · exact absurd ( hprim ▸ Nat.dvd_gcd ( even_iff_two_dvd.mp hx ) ( Nat.dvd_gcd ( even_iff_two_dvd.mp hy ) ( even_iff_two_dvd.mp hz ) ) ) ( by norm_num );
  · obtain ⟨ a, ha ⟩ := hpc.2;
    exact absurd ( congr_arg ( · % 4 ) ha ) ( by rcases hx with ⟨ k, rfl ⟩ ; rcases hy with ⟨ l, rfl ⟩ ; rcases hz with ⟨ m, rfl ⟩ ; ring_nf; norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] ; have := Nat.mod_lt a zero_lt_four; interval_cases a % 4 <;> trivial );
  · obtain ⟨ d, hd ⟩ := hpc.2;
    exact absurd ( congr_arg ( · % 4 ) hd ) ( by rcases hx with ⟨ m, rfl ⟩ ; rcases hy with ⟨ n, rfl ⟩ ; rcases hz with ⟨ o, rfl ⟩ ; rcases Nat.even_or_odd' d with ⟨ p, rfl | rfl ⟩ <;> ring_nf <;> norm_num [ Nat.add_mod, Nat.mul_mod ] );
  · have := hpc.2; obtain ⟨ k, hk ⟩ := this; replace hk := congr_arg ( · % 4 ) hk; rcases hx with ⟨ m, rfl ⟩ ; rcases hy with ⟨ n, rfl ⟩ ; rcases hz with ⟨ o, rfl ⟩ ; rcases Nat.even_or_odd' k with ⟨ p, rfl | rfl ⟩ <;> ring_nf at hk <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at hk;
  · obtain ⟨ k, hk ⟩ := hpc.2;
    exact absurd ( congr_arg ( · % 4 ) hk ) ( by rcases hx with ⟨ m, rfl ⟩ ; rcases hy with ⟨ n, rfl ⟩ ; rcases hz with ⟨ o, rfl ⟩ ; rcases Nat.even_or_odd' k with ⟨ p, rfl | rfl ⟩ <;> ring_nf <;> norm_num )

/-- **Space diagonal oddness.** In a primitive perfect cuboid the space
diagonal is odd. -/
theorem primitive_perfect_cuboid_space_diag_odd
    {x y z : ℕ}
    (hprim : PrimitiveTriple x y z)
    (hpc : IsPerfectCuboid x y z) :
    ∃ d, d ^ 2 = x ^ 2 + y ^ 2 + z ^ 2 ∧ Odd d := by
  obtain ⟨k, hk⟩ := hpc.right;
  have hk_mod : k^2 % 4 = 1 := by
    rcases Nat.even_or_odd' x with ⟨ b, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' y with ⟨ c, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' z with ⟨ d, rfl | rfl ⟩ <;> ring_nf;
    all_goals have := congr_arg (· % 4) hk; ring_nf at this; norm_num [ Nat.add_mod, Nat.mul_mod ] at this;
    all_goals rcases Nat.even_or_odd' k with ⟨ k, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *;
    unfold PrimitiveTriple at hprim; simp_all +decide [ Nat.gcd_mul_right ] ;
  exact ⟨ k, hk, Nat.odd_iff.mpr ( show k % 2 = 1 from by rw [ ← Nat.mod_mod_of_dvd k ( by decide : 2 ∣ 4 ) ] ; rw [ Nat.pow_mod ] at hk_mod; have := Nat.mod_lt k zero_lt_four; interval_cases k % 4 <;> trivial ) ⟩

/-
**Mod-8 obstruction on even edges.**
If x is even but not divisible by 4 (i.e. x ≡ 2 mod 4), and z is odd,
then x² + z² ≡ 5 (mod 8), which is not a perfect square.
This forces even edges in a primitive perfect cuboid to be divisible by 4.
-/
theorem even_edge_mod8_obstruction {x z a : ℕ}
    (hx2 : x % 4 = 2) (hz : Odd z)
    (ha : a ^ 2 = x ^ 2 + z ^ 2) : False := by
  replace ha := congr_arg ( · % 8 ) ha ; rcases Nat.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' z with ⟨ l, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' a with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod, Nat.mul_mod ] at *;
  all_goals have := congr_arg ( · % 4 ) ha; norm_num [ Nat.add_mod, Nat.mul_mod ] at this;
  · grind +revert;
  · rcases Nat.even_or_odd' k with ⟨ k, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' l with ⟨ l, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' m with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at *;
    · have := Nat.mod_lt k zero_lt_four; interval_cases k % 4 <;> contradiction;
    · have := Nat.mod_lt k zero_lt_four; interval_cases k % 4 <;> contradiction;
    · have := Nat.mod_lt k zero_lt_four; interval_cases k % 4 <;> contradiction;
    · have := Nat.mod_lt k zero_lt_four; interval_cases k % 4 <;> contradiction;
  · exact absurd hz ( by simp +decide [ parity_simps ] )

/-
**Both even edges divisible by 4.**
In a primitive perfect cuboid with two even edges, both must be ≡ 0 (mod 4).
-/
theorem primitive_even_edges_div_4
    {x y z : ℕ}
    (hprim : PrimitiveTriple x y z)
    (hpc : IsPerfectCuboid x y z)
    (hx : Even x) (hy : Even y) (hz : Odd z) :
    4 ∣ x ∧ 4 ∣ y := by
  constructor <;> obtain ⟨ a, ha ⟩ := hpc.1.1 <;> ( obtain ⟨ b, hb ⟩ := hpc.1.2.1 ; ( obtain ⟨ c, hc ⟩ := hpc.1.2.2 ; ( ( rw [ show 4 = 2 ^ 2 by norm_num ] ; ( rw [ Nat.dvd_iff_mod_eq_zero ] ; ( obtain ⟨ m, rfl ⟩ := hx ; ( obtain ⟨ n, rfl ⟩ := hy ; ( ( norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] at * ; ) ) ) ) ) ) ) ) );
  · rcases Nat.even_or_odd' m with ⟨ k, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *;
    · ring_nf; norm_num;
    · replace hb := congr_arg ( · % 8 ) hb ; rcases Nat.even_or_odd' b with ⟨ b, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' z with ⟨ z, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Nat.add_mod, Nat.mul_mod ] at *;
      · exact absurd hz ( by simp +decide [ parity_simps ] );
      · norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] at hb; have := Nat.mod_lt b ( by decide : 0 < 8 ) ; have := Nat.mod_lt z ( by decide : 0 < 8 ) ; interval_cases b % 8 <;> interval_cases z % 8 <;> simp +decide at hb;
      · exact absurd hz ( by simp +decide [ parity_simps ] );
      · norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod ] at hb; have := Nat.mod_lt b ( by decide : 0 < 8 ) ; have := Nat.mod_lt z ( by decide : 0 < 8 ) ; interval_cases b % 8 <;> interval_cases z % 8 <;> simp +decide at hb;
  · grind +suggestions

end PerfectCuboid