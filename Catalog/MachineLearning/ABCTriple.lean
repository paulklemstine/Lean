import Mathlib
import ABC.Radical

/-!
# ABC Triples and the ABC Conjecture

This file defines the core structures for the abc conjecture:
* `ABCTriple` — a pairwise coprime positive triple with `a + b = c`
* `ABCConjectureDiscrete` — a Lean-friendly discrete formulation of the abc conjecture
* `flt_radical_bound` — primitive Fermat triples have small radical relative to size
* `abc_implies_asymptotic_FLT` — the abc conjecture implies asymptotic Fermat's Last Theorem

## Mathematical background

The abc conjecture asserts that for every ε > 0 there exists K such that for all
coprime positive integers a, b with a + b = c, we have c ≤ K · rad(abc)^(1+ε).

Our discrete formulation replaces 1+ε with (m+1)/m via integer exponentiation:
for each m ≥ 1, there exists K such that c^m ≤ K · rad(abc)^(m+1).

### Asymptotic FLT from ABC

If a^n + b^n = c^n with coprime a,b, then (a^n, b^n, c^n) forms an ABC triple.
The radical rad(a^n · b^n · c^n) = rad(abc) ≤ abc < c^3.
The ABC conjecture gives c^(nm) ≤ K · rad(a^n·b^n·c^n)^(m+1) = K · rad(abc)^(m+1) ≤ K · c^(3(m+1)).
So c^(nm) ≤ K · c^(3m+3). For c ≥ 2 and nm > 3m+3, this forces c to be bounded.
Taking m=1: c^n ≤ K · c^6, so c^(n-6) ≤ K, meaning c ≤ K^(1/(n-6)) for n > 6.
For n large enough, K^(1/(n-6)) < 2, so c < 2, contradiction with c ≥ 2.
-/

open Finset Nat

/-- An ABC triple is a triple of positive natural numbers (a, b, c) with
    a + b = c and gcd(a, b) = 1. -/
structure ABCTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  ha_pos : 0 < a
  hb_pos : 0 < b
  hc_pos : 0 < c
  hab_coprime : Nat.Coprime a b
  hsum : a + b = c

/-- The radical of the product abc for an ABC triple. -/
def ABCTriple.radABC (t : ABCTriple) : ℕ := rad (t.a * t.b * t.c)

/-- A discrete formulation of the abc conjecture using integer exponents.
    For each m ≥ 1, there exists K > 0 such that c^m ≤ K · rad(abc)^(m+1). -/
def ABCConjectureDiscrete : Prop :=
  ∀ m : ℕ, 1 ≤ m →
  ∃ K : ℕ, 0 < K ∧ ∀ t : ABCTriple,
    t.c ^ m ≤ K * (t.radABC) ^ (m + 1)

/-! ## Foundational inequalities -/

/-
`rad n ≤ n` for positive `n`, since rad n divides n.
-/
theorem rad_le_of_pos {n : ℕ} (hn : 0 < n) : rad n ≤ n := by
  exact Nat.le_of_dvd hn ( rad_dvd n )

/-
If a + b = c with b > 0, then a < c.
-/
theorem lt_of_add_eq {a b c : ℕ} (hb : 0 < b) (h : a + b = c) : a < c := by
  linarith

/-
If a + b = c with a > 0, then b < c.
-/
theorem lt_of_add_eq' {a b c : ℕ} (ha : 0 < a) (h : a + b = c) : b < c := by
  linarith

/-
For positive a, b, c with a + b = c, we have a * b * c ≤ c^3.
-/
theorem abc_product_le_cube {a b c : ℕ}
    (ha : 0 < a) (hb : 0 < b) (hsum : a + b = c) :
    a * b * c ≤ c ^ 3 := by
  subst c; nlinarith [ mul_nonneg ha.le hb.le, sq_nonneg ( a - b : ℤ ), sq_nonneg ( b - 0 : ℤ ), sq_nonneg ( 0 - a : ℤ ) ] ;

/-
For an ABC triple, rad(abc) ≤ c^3.
-/
theorem rad_abc_le_cube (t : ABCTriple) : t.radABC ≤ t.c ^ 3 := by
  exact le_trans ( rad_le_of_pos ( Nat.mul_pos ( Nat.mul_pos t.ha_pos t.hb_pos ) t.hc_pos ) ) ( abc_product_le_cube t.ha_pos t.hb_pos t.hsum )

/-! ## Radical and powers -/

/-
`rad(a^n · b^n · c^n) = rad(a · b · c)` for n ≥ 1.
-/
theorem rad_pow_product {a b c n : ℕ} (hn : 1 ≤ n) :
    rad (a ^ n * b ^ n * c ^ n) = rad (a * b * c) := by
  convert rad_pow_eq_rad ( a * b * c ) ( by positivity : n ≠ 0 ) using 1;
  rw [ mul_pow, mul_pow ]

/-! ## FLT radical bound -/

/-
**FLT radical bound**: If a^n + b^n = c^n with pairwise coprime a, b, c,
    then rad(a·b·c) ≤ c^3.

    Proof sketch: Since a^n + b^n = c^n forms an abc triple (a^n, b^n, c^n),
    and rad(a^n·b^n·c^n) = rad(abc), we use rad(abc) ≤ abc ≤ c^3
    where the last inequality uses a < c and b < c.
-/
theorem flt_radical_bound
    {a b c n : ℕ}
    (hn : 1 ≤ n)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop_ab : Nat.Coprime a b)
    (hcop_ac : Nat.Coprime a c)
    (hcop_bc : Nat.Coprime b c)
    (hfermat : a ^ n + b ^ n = c ^ n) :
    rad (a * b * c) ≤ c ^ 3 := by
  -- We have rad(a*b*c) ≤ a*b*c (by rad_le_of_pos).
  have h_rad_le_abc : rad (a * b * c) ≤ a * b * c := by
    exact rad_le_of_pos ( Nat.mul_pos ( Nat.mul_pos ha hb ) hc );
  -- Since $a^n + b^n = c^n$, we have $a < c$ and $b < c$.
  have h_ac : a < c := by
    exact lt_of_not_ge fun h => by linarith [ pow_pos ha n, pow_pos hb n, pow_le_pow_left' h n ] ;
  have h_bc : b < c := by
    exact lt_of_not_ge fun h => by linarith [ pow_pos ha n, pow_pos hb n, pow_le_pow_left' h n ] ;
  exact h_rad_le_abc.trans ( by nlinarith only [ mul_lt_mul_of_pos_left h_ac hc, mul_lt_mul_of_pos_left h_bc hc, h_ac, h_bc ] )

/-! ## ABC power obstruction -/

/-
The abc power obstruction: if c^m ≤ K · rad(abc)^(m+1),
    then (K+1) · rad(abc)^(m+1) ≥ c^m.
-/
theorem abc_power_obstruction
    (m K : ℕ) (hm : 1 ≤ m) :
    ∀ t : ABCTriple,
      t.c ^ m ≤ K * (t.radABC) ^ (m + 1) →
      ¬ ((K + 1) * (t.radABC) ^ (m + 1) < t.c ^ m) := by
  grind +qlia

/-! ## Conditional Asymptotic FLT -/

/-
An ABC triple can be constructed from a Fermat equation.
    If a^n + b^n = c^n with coprime a,b then (a^n, b^n, c^n) is an ABC triple.
-/
theorem fermat_to_abc_triple
    {a b c n : ℕ}
    (hn : 1 ≤ n)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop : Nat.Coprime a b)
    (hfermat : a ^ n + b ^ n = c ^ n) :
    Nat.Coprime (a ^ n) (b ^ n) := by
  exact hcop.pow _ _

/-
Under ABCConjectureDiscrete with m=1, for ANY abc triple t,
    t.c ≤ K · t.radABC^2. For a Fermat triple (a^n, b^n, c^n),
    radABC ≤ c^3, so c^n ≤ K · c^6. This gives a UNIFORM K.
-/
theorem fermat_abc_uniform_bound
    (hABC : ABCConjectureDiscrete)
    {a b c n : ℕ}
    (hn : 1 ≤ n)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop_ab : Nat.Coprime a b)
    (hcop_ac : Nat.Coprime a c)
    (hcop_bc : Nat.Coprime b c)
    (hfermat : a ^ n + b ^ n = c ^ n)
    {K : ℕ} (hK : 0 < K)
    (hK_bound : ∀ t : ABCTriple, t.c ^ 1 ≤ K * (t.radABC) ^ 2) :
    c ^ n ≤ K * c ^ 6 := by
  -- Apply hK_bound to the Fermat triple (a^n, b^n, c^n).
  have h_fermat_triple : c ^ n ≤ K * (rad (a ^ n * b ^ n * c ^ n)) ^ 2 := by
    convert hK_bound ⟨ a ^ n, b ^ n, c ^ n, ?_, ?_, ?_, ?_, ?_ ⟩ using 1 <;> simp_all +decide [ Nat.Coprime.pow ];
    exact hcop_ab.pow _ _;
  -- Use rad_pow_product to get rad(a^n * b^n * c^n) = rad(a*b*c).
  have h_rad_pow_product : rad (a ^ n * b ^ n * c ^ n) = rad (a * b * c) := by
    exact rad_pow_product hn;
  -- Use flt_radical_bound to get rad(a*b*c) ≤ c^3.
  have h_rad_le_c3 : rad (a * b * c) ≤ c ^ 3 := by
    apply flt_radical_bound hn ha hb hc hcop_ab hcop_ac hcop_bc hfermat;
  exact h_fermat_triple.trans ( by rw [ h_rad_pow_product ] ; exact Nat.mul_le_mul_left _ ( by convert Nat.pow_le_pow_left h_rad_le_c3 2 using 1 ; ring ) )

/-
If c ≥ 2 and c^n ≤ K · c^6, then n ≤ 6 + K.
    (A crude but sufficient bound for asymptotic purposes.)
-/
theorem pow_le_of_bound {c n K : ℕ}
    (hc : 2 ≤ c)
    (hbound : c ^ n ≤ K * c ^ 6) :
    n ≤ 6 + K := by
  contrapose! hbound;
  refine' lt_of_lt_of_le _ ( pow_le_pow_right₀ ( by linarith ) hbound );
  induction' K with K ih <;> norm_num [ Nat.pow_succ', Nat.pow_add ] at *;
  · exact ⟨ pos_of_gt hc, by positivity ⟩;
  · nlinarith [ ih ( by linarith ), pow_pos ( zero_lt_two.trans_le hc ) K, pow_pos ( zero_lt_two.trans_le hc ) 6, pow_pos ( zero_lt_two.trans_le hc ) 7, mul_le_mul_left' hc ( c ^ K ), mul_le_mul_left' hc ( c ^ 6 ), mul_le_mul_left' hc ( c ^ 7 ) ]

/-
**Conditional asymptotic FLT from discrete abc**:
    Assuming ABCConjectureDiscrete, for sufficiently large n there are
    no positive pairwise coprime solutions to a^n + b^n = c^n.

    Proof idea: The ABC conjecture with m=1 gives c^n ≤ K · rad(abc)^2.
    Since rad(abc) ≤ c^3, we get c^n ≤ K · c^6.
    For c ≥ 2, this forces n ≤ some fixed bound depending on K.
    So beyond that bound, no solutions exist.
-/
theorem abc_implies_asymptotic_FLT
    (hABC : ABCConjectureDiscrete) :
    ∃ N : ℕ, ∀ n, N ≤ n → ∀ a b c : ℕ,
      0 < a → 0 < b → 0 < c →
      Nat.Coprime a b →
      Nat.Coprime a c →
      Nat.Coprime b c →
      a ^ n + b ^ n ≠ c ^ n := by
  -- By assumption, there exists a K₀ such that for any abc triple t, t.c^1 ≤ K₀ * t.radABC^2.
  obtain ⟨K₀, hK₀⟩ : ∃ K₀ : ℕ, 0 < K₀ ∧ ∀ t : ABCTriple, t.c ^ 1 ≤ K₀ * (t.radABC) ^ 2 := by
    exact hABC 1 le_rfl;
  use K₀ + 7;
  intros n hn a b c ha hb hc hab hbc hca h;
  -- By the properties of the radical and the ABC conjecture, we have $c^n \leq K₀ \cdot c^6$.
  have h_bound : c ^ n ≤ K₀ * c ^ 6 := by
    apply fermat_abc_uniform_bound hABC (by linarith) ha hb hc hab hbc hca h hK₀.left hK₀.right;
  -- Since $c \geq 2$, we can divide both sides of the inequality $c^n \leq K₀ \cdot c^6$ by $c^6$ to get $c^{n-6} \leq K₀$.
  have h_div : c ^ (n - 6) ≤ K₀ := by
    exact Nat.le_of_mul_le_mul_right ( by convert h_bound using 1; rw [ ← pow_add, Nat.sub_add_cancel ( by linarith ) ] ) ( by positivity );
  -- Since $c \geq 2$, we have $c^{n-6} \geq 2^{n-6}$.
  have h_exp : c ^ (n - 6) ≥ 2 ^ (n - 6) := by
    gcongr;
    contrapose! h; interval_cases c ; simp_all +decide ;
    grind +revert;
  -- Since $n \geq K₀ + 7$, we have $n - 6 \geq K₀ + 1$.
  have h_n_minus_6 : n - 6 ≥ K₀ + 1 := by
    omega;
  -- Since $n - 6 \geq K₀ + 1$, we have $2^{n-6} \geq 2^{K₀ + 1}$.
  have h_exp_ge : 2 ^ (n - 6) ≥ 2 ^ (K₀ + 1) := by
    exact pow_le_pow_right₀ ( by decide ) h_n_minus_6;
  -- Since $2^{K₀ + 1} > K₀$, we have a contradiction.
  have h_contradiction : 2 ^ (K₀ + 1) > K₀ := by
    exact Nat.recOn K₀ ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ' ] at ihn ⊢ ; linarith;
  linarith

/-! ## Primitive reduction -/

/-
Primitive reduction: any Fermat solution can be divided by gcd to get
    a coprime solution.
-/
theorem fermat_reduce_to_coprime
    {a b c n : ℕ}
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hn : 1 ≤ n)
    (hfermat : a ^ n + b ^ n = c ^ n) :
    ∃ a' b' c' : ℕ,
      0 < a' ∧ 0 < b' ∧ 0 < c' ∧
      Nat.Coprime a' b' ∧
      a' ^ n + b' ^ n = c' ^ n := by
  -- Let $g = \gcd(a, b)$, then $a = g a'$ and $b = g b'$ where $\gcd(a', b') = 1$.
  obtain ⟨g, a', b', ha', hb', hg⟩ : ∃ g a' b', 0 < a' ∧ 0 < b' ∧ a = g * a' ∧ b = g * b' ∧ Nat.gcd a' b' = 1 := by
    exact ⟨ Nat.gcd a b, a / Nat.gcd a b, b / Nat.gcd a b, Nat.div_pos ( Nat.le_of_dvd ha ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ha ), Nat.div_pos ( Nat.le_of_dvd hb ( Nat.gcd_dvd_right _ _ ) ) ( Nat.gcd_pos_of_pos_right _ hb ), by rw [ Nat.mul_div_cancel' ( Nat.gcd_dvd_left _ _ ) ], by rw [ Nat.mul_div_cancel' ( Nat.gcd_dvd_right _ _ ) ], by rw [ Nat.gcd_div ( Nat.gcd_dvd_left _ _ ) ( Nat.gcd_dvd_right _ _ ), Nat.div_self ( Nat.gcd_pos_of_pos_left _ ha ) ] ⟩;
  -- Then $g^n (a'^n + b'^n) = c^n$, so $a'^n + b'^n = c'^n$ for some $c'$.
  obtain ⟨c', hc'⟩ : ∃ c', c = g * c' := by
    exact Nat.pow_dvd_pow_iff ( by linarith ) |>.1 ( hfermat ▸ dvd_add ( pow_dvd_pow_of_dvd ( hg.1.symm ▸ dvd_mul_right _ _ ) _ ) ( pow_dvd_pow_of_dvd ( hg.2.1.symm ▸ dvd_mul_right _ _ ) _ ) );
  simp_all +decide [ mul_pow ];
  exact ⟨ a', ha', b', hb', c', hc, hg.2.2, by nlinarith [ pow_pos ha n ] ⟩

/-! ## Computational interface -/

/-- Decidable test for whether (a,b,c) forms a valid ABC triple. -/
def isPrimitiveABCSolution (a b c : ℕ) : Bool :=
  0 < a && 0 < b && 0 < c && a + b = c && Nat.Coprime a b

/-- Compute the radical of the abc product. -/
def abcRad (a b c : ℕ) : ℕ := rad (a * b * c)

/-- Test whether the abc quality exceeds threshold m, i.e. c^m > rad(abc)^(m+1). -/
def exceedsQuality (m a b c : ℕ) : Bool :=
  c ^ m > abcRad a b c ^ (m + 1)

/-
Soundness of the quality test.
-/
theorem exceedsQuality_sound {m a b c : ℕ} :
    exceedsQuality m a b c = true →
    abcRad a b c ^ (m + 1) < c ^ m := by
  -- Unfold the definition of exceedsQuality to extract the positivity and the inequality between c^m and rad(abc)^(m+1).
  unfold exceedsQuality at *; aesop