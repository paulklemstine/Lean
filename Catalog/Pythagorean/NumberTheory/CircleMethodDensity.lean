import Mathlib

/-!
# Circle Method Density Heuristics for Sums of Three Cubes

This file formalizes the local density framework underlying the Hardy–Littlewood
circle method prediction for the Diophantine equation x³ + y³ + z³ = k.

## Overview

We define:
- `threeCubeResidueSet k n` — solutions to x³+y³+z³ ≡ k (mod n) in (ZMod n)³
- `threeCubeResidueCount k n` — the cardinality of that set
- `threeCubeLocalDensity k n` — the normalized density count / n²
- `truncatedSingularSeries k P` — the Euler product proxy ∏_{p∈P} δ_k(p)

## Main Results

1. Global representability implies every local residue count (and density) is positive.
2. The residue count is multiplicative over coprime moduli (CRT).
3. The local density is multiplicative over coprime moduli.
4. The truncated singular series is positive whenever k is globally representable.
5. The local density relates to the uniform probability by a factor of n.

These results create the first formal bridge from local-global arithmetic to
circle-method-style density predictions for the three cubes problem.
-/

open Finset

/-! ## Core Definitions -/

/-- An integer `k` is representable as a sum of three cubes. -/
def SumThreeCubesRep (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k

/-- The set of triples (a,b,c) ∈ (ℤ/nℤ)³ satisfying a³+b³+c³ ≡ k (mod n). -/
def threeCubeResidueSet (k : ℤ) (n : ℕ) [NeZero n] :
    Finset (ZMod n × ZMod n × ZMod n) :=
  Finset.univ.filter fun ⟨a, b, c⟩ => a ^ 3 + b ^ 3 + c ^ 3 = (k : ZMod n)

/-- The number of solutions to x³+y³+z³ ≡ k (mod n). -/
def threeCubeResidueCount (k : ℤ) (n : ℕ) [NeZero n] : ℕ :=
  (threeCubeResidueSet k n).card

/-- The local density: normalized count of solutions divided by n².
    This is the standard normalization in the circle method for a
    codimension-1 variety in 3 variables. -/
noncomputable def threeCubeLocalDensity (k : ℤ) (n : ℕ) [NeZero n] : ℚ :=
  (threeCubeResidueCount k n : ℚ) / ((n : ℚ) ^ 2)

/-- Local admissibility: the congruence x³+y³+z³ ≡ k (mod n) is solvable. -/
def ThreeCubeLocalAdmissible (n : ℕ) [NeZero n] (a : ZMod n) : Prop :=
  ∃ x y z : ZMod n, x ^ 3 + y ^ 3 + z ^ 3 = a

/-- The squarefree local factor at a prime p. -/
noncomputable def localSigmaSqFree (k : ℤ) (p : ℕ) [NeZero p] : ℚ :=
  threeCubeLocalDensity k p

/-- Truncated singular series: product of local densities over a finite set of primes. -/
noncomputable def truncatedSingularSeries (k : ℤ) (P : Finset ℕ) : ℚ :=
  ∏ p ∈ P, if h : p ≠ 0 then @threeCubeLocalDensity k p ⟨h⟩ else 0

/-- The uniform probability that a random triple in (ℤ/nℤ)³ solves
    x³+y³+z³ ≡ k (mod n). This divides by n³ (the size of the sample space). -/
noncomputable def uniformThreeCubeProb (k : ℤ) (n : ℕ) [NeZero n] : ℚ :=
  (threeCubeResidueCount k n : ℚ) / ((n : ℚ) ^ 3)

/-! ## Basic Properties -/

/-- The local density is nonnegative. -/
theorem threeCubeLocalDensity_nonneg (k : ℤ) (n : ℕ) [NeZero n] :
    0 ≤ threeCubeLocalDensity k n :=
  div_nonneg (Nat.cast_nonneg _) (sq_nonneg _)

/-- The truncated singular series is nonnegative. -/
theorem truncatedSingularSeries_nonneg (k : ℤ) (P : Finset ℕ) :
    0 ≤ truncatedSingularSeries k P := by
  apply Finset.prod_nonneg
  intro p _
  split_ifs with h
  · exact @threeCubeLocalDensity_nonneg k p ⟨h⟩
  · exact le_refl _

/-- The truncated singular series equals the product of residue count ratios. -/
theorem truncatedSingularSeries_spec
    (k : ℤ) (P : Finset ℕ) (hP : ∀ p ∈ P, Nat.Prime p) :
    truncatedSingularSeries k P
      = ∏ p ∈ P, if h : p ≠ 0 then
          ((@threeCubeResidueCount k p ⟨h⟩ : ℚ) / ((p : ℚ) ^ 2)) else 0 :=
  rfl

/-! ## Theorem 1: Global Representation Implies Positive Local Counts -/

/-
Helper: global representation gives a concrete solution modulo n.
-/
theorem threeCubeRep_implies_residueCount_pos
    (k : ℤ)
    (hrep : SumThreeCubesRep k)
    (n : ℕ) [NeZero n] :
    0 < threeCubeResidueCount k n := by
  obtain ⟨ x, y, z, hxyz ⟩ := hrep; use Finset.card_pos.mpr ⟨ ( ( x : ZMod n ), ( y : ZMod n ), ( z : ZMod n ) ), ?_ ⟩ ; simp_all +decide [ ← eq_sub_iff_add_eq' ] ;
  simp +decide [ threeCubeResidueSet, hxyz ];
  norm_cast; rw [ hxyz ] ; ring;

/-
If k is a sum of three cubes, then for every modulus n,
the local density δ_k(n) is positive.
-/
theorem threeCubeRep_implies_localDensity_pos
    (k : ℤ)
    (hrep : SumThreeCubesRep k)
    (n : ℕ) [NeZero n] :
    0 < threeCubeLocalDensity k n := by
  exact div_pos ( Nat.cast_pos.mpr ( threeCubeRep_implies_residueCount_pos k hrep n ) ) ( sq_pos_of_pos ( Nat.cast_pos.mpr ( NeZero.pos n ) ) )

/-! ## Theorem 2: Multiplicativity of Residue Counts (CRT) -/

/-
The residue count is multiplicative over coprime moduli.
This is the algebraic engine behind the Euler product structure
of the singular series. Uses CRT: ZMod(mn) ≃+* ZMod(m) × ZMod(n).
-/
theorem threeCubeResidueCount_mul_of_coprime
    (k : ℤ) {m n : ℕ} [NeZero m] [NeZero n]
    (hcop : Nat.Coprime m n) :
    threeCubeResidueCount k (m * n)
      = threeCubeResidueCount k m * threeCubeResidueCount k n := by
  have h_crt_iso : Nonempty (ZMod (m * n) ≃+* ZMod m × ZMod n) := by
    exact ⟨ ZMod.chineseRemainder hcop ⟩;
  obtain ⟨ f ⟩ := h_crt_iso;
  have h_crt_iso : threeCubeResidueSet k (m * n) = Finset.image (fun p : (ZMod m × ZMod m × ZMod m) × (ZMod n × ZMod n × ZMod n) => (f.symm (p.1.1, p.2.1), f.symm (p.1.2.1, p.2.2.1), f.symm (p.1.2.2, p.2.2.2))) (threeCubeResidueSet k m ×ˢ threeCubeResidueSet k n) := by
    ext ⟨a, b, c⟩; simp [threeCubeResidueSet];
    constructor;
    · intro h
      use f a |>.1, f b |>.1, f c |>.1, f a |>.2, f b |>.2, f c |>.2;
      replace h := congr_arg ( fun x => ( f x |>.1, f x |>.2 ) ) h ; aesop;
    · rintro ⟨ a, b, c, d, e, f, h, rfl, rfl, rfl ⟩;
      rename_i g;
      rw [ ← g.injective.eq_iff ] ; aesop;
  simp_all +decide [ threeCubeResidueCount ];
  rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
  grind

/-
The local density is multiplicative over coprime moduli.
-/
theorem threeCubeLocalDensity_mul_of_coprime
    (k : ℤ) {m n : ℕ} [NeZero m] [NeZero n]
    (hcop : Nat.Coprime m n) :
    threeCubeLocalDensity k (m * n)
      = threeCubeLocalDensity k m * threeCubeLocalDensity k n := by
  convert congr_arg ( fun x : ℕ => ( x : ℚ ) / ( m * n ) ^ 2 ) ( threeCubeResidueCount_mul_of_coprime k hcop ) using 1 ; ring;
  · unfold threeCubeLocalDensity; ring;
    grind;
  · unfold threeCubeLocalDensity; push_cast; ring;

/-! ## Theorem 3: Positivity of the Truncated Singular Series -/

/-
If k is a sum of three cubes, the truncated singular series
is positive for every finite set of primes.
-/
theorem truncatedSingularSeries_pos_of_rep
    (k : ℤ)
    (hrep : SumThreeCubesRep k)
    (P : Finset ℕ) (hP : ∀ p ∈ P, Nat.Prime p) :
    0 < truncatedSingularSeries k P := by
  refine' Finset.prod_pos fun p hp => _;
  split_ifs <;> simp_all +decide [ threeCubeRep_implies_localDensity_pos ];
  exact Nat.not_prime_zero ( hP _ hp )

/-! ## Theorem 5: Probability Bridge -/

/-
The local density relates to the uniform probability by a factor of n:
    δ_k(n) = n · Pr[x³+y³+z³ ≡ k (mod n)].
    This bridges the analytic number theory normalization (by n²) to the
    probabilistic normalization (by n³).
-/
theorem threeCubeLocalDensity_eq_n_mul_prob
    (k : ℤ) (n : ℕ) [NeZero n] :
    threeCubeLocalDensity k n = (n : ℚ) * uniformThreeCubeProb k n := by
  repeat grind +locals

/-! ## Mod 9 Obstruction -/

/-
When k ≡ 4 or 5 (mod 9), the local density at n=9 vanishes.
-/
theorem threeCubeLocalDensity_zero_mod9
    (k : ℤ) (hk : (k : ZMod 9) = 4 ∨ (k : ZMod 9) = 5) :
    @threeCubeLocalDensity k 9 ⟨by omega⟩ = 0 := by
  convert threeCubeLocalDensity_eq_n_mul_prob k 9;
  unfold uniformThreeCubeProb;
  unfold threeCubeResidueCount; norm_num;
  -- By examining all possible combinations of $x^3$, $y^3$, and $z^3$ modulo 9, we can see that there are no solutions to $x^3 + y^3 + z^3 \equiv 4$ or $5 \pmod{9}$.
  have h_cases : ∀ x y z : ZMod 9, x^3 + y^3 + z^3 ≠ 4 ∧ x^3 + y^3 + z^3 ≠ 5 := by
    decide;
  exact Finset.eq_empty_of_forall_notMem fun x hx => by rcases hk with ( hk | hk ) <;> have := h_cases x.1 x.2.1 x.2.2 <;> simp_all +decide [ threeCubeResidueSet ] ;

/-
When k ≡ 4 or 5 (mod 9), the residue count at 9 is zero.
-/
theorem threeCubeResidueCount_zero_mod9
    (k : ℤ) (hk : (k : ZMod 9) = 4 ∨ (k : ZMod 9) = 5) :
    @threeCubeResidueCount k 9 ⟨by omega⟩ = 0 := by
  convert threeCubeLocalDensity_zero_mod9 k hk;
  unfold threeCubeLocalDensity; aesop;