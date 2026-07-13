import Mathlib

/-!
# A Generalized Recursion Identity for the Mertens Function

This file formalizes **Theorem 1** of the referenced work on fast computation of the
Mertens function, with the standard split point `ν_y = ⌊√y⌋` and explicit floor
operations.

Let `μ` be the Möbius function and `M(x) = ∑_{n≤x} μ(n)` the Mertens function.
For integers `x ≥ 2` and `u` with `⌊√x⌋ < u < x`, the identity states

`M(x) = ∑_{k=1}^{⌊x/u⌋} μ(k) · S(⌊x/k⌋, u)`,

where, writing `ν_y = ⌊√y⌋` and `κ_y = ⌊y/(ν_y+1)⌋`,

`S(y,u) = 1 - ∑_{n=⌊y/u⌋+1}^{κ_y} M(⌊y/n⌋) + κ_y·M(ν_y) - ∑_{n=1}^{ν_y} ⌊y/n⌋·μ(n)`.

## Structure of the proof (a chain of results)

* `sum_mu_divisors` — `∑_{d | n} μ(d) = [n = 1]` (Möbius: divisor sums of `μ`).
* `sum_pairs_eq_sum_antidiagonal` — the fundamental reindexing of a sum over lattice
  points `{(k,j) : kj ≤ w}` by their product.
* `sum_Icc_div_eq_filter` — rewrites an iterated `∑_k ∑_{m ≤ y/k}` as a sum over the
  hyperbola region `{(k,m) : km ≤ y}`.
* `mertens_fundamental` — `∑_{k=1}^{y} M(⌊y/k⌋) = 1` for `y ≥ 1`.
* `hyperbola_split` — the asymmetric Dirichlet-hyperbola identity with split point
  `(κ_y, ν_y)`, the analytic heart of the recursion.
* `Sfun_eq` — the collapse `S(y,u) = ∑_{j=1}^{⌊y/u⌋} M(⌊y/j⌋)` for `u > ⌊√y⌋`.
* `mertens_recursion` — the main theorem.
-/

open Finset

namespace MertensRecursion

/-- The Möbius function, valued in `ℤ`. -/
def mu (n : ℕ) : ℤ := ArithmeticFunction.moebius n

/-- The Mertens function `M(x) = ∑_{n=1}^{x} μ(n)`. -/
def mertens (x : ℕ) : ℤ := ∑ n ∈ Finset.Icc 1 x, mu n

/-- The auxiliary split point `κ_y = ⌊y / (⌊√y⌋ + 1)⌋`. -/
def kappa (y : ℕ) : ℕ := y / (Nat.sqrt y + 1)

/-- The summand `S(y, u)` appearing in Theorem 1. -/
def Sfun (y u : ℕ) : ℤ :=
  1 - (∑ n ∈ Finset.Icc (y / u + 1) (kappa y), mertens (y / n))
    + (kappa y : ℤ) * mertens (Nat.sqrt y)
    - (∑ n ∈ Finset.Icc 1 (Nat.sqrt y), (y / n : ℤ) * mu n)

/-
**Möbius divisor sum.** For `n ≥ 1`, `∑_{d | n} μ(d)` is `1` if `n = 1` and `0`
otherwise.
-/
lemma sum_mu_divisors (n : ℕ) (hn : 0 < n) :
    (∑ d ∈ n.divisors, mu d) = if n = 1 then 1 else 0 := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide;
  · native_decide +revert;
  · have h_sum_mu : ∑ d ∈ Nat.divisors (n + 2), (ArithmeticFunction.moebius d) = (ArithmeticFunction.moebius * ArithmeticFunction.zeta) (n + 2) := by
      simp +decide [ ArithmeticFunction.moebius, ArithmeticFunction.zeta ];
      rw [ Nat.sum_divisorsAntidiagonal fun x y => if y = 0 then 0 else if Squarefree x then ( -1 : ℤ ) ^ ArithmeticFunction.cardFactors x else 0 ];
      exact Finset.sum_congr rfl fun x hx => by rw [ if_neg ( Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd ( Nat.succ_pos _ ) ( Nat.dvd_of_mem_divisors hx ) ) ( Nat.pos_of_mem_divisors hx ) ) ) ] ;
    aesop

/-
**Fundamental reindexing.** A sum of `h k j` over lattice points `(k, j)` with
`1 ≤ k`, `1 ≤ j`, `k·j ≤ w` can be reorganized by the product `d = k·j`.
-/
lemma sum_pairs_eq_sum_antidiagonal {A : Type*} [AddCommMonoid A]
    (w : ℕ) (h : ℕ → ℕ → A) :
    (∑ k ∈ Finset.Icc 1 w, ∑ j ∈ Finset.Icc 1 (w / k), h k j)
      = ∑ d ∈ Finset.Icc 1 w, ∑ p ∈ d.divisorsAntidiagonal, h p.1 p.2 := by
  have h_biUnion : ∑ k ∈ Finset.Icc 1 w, ∑ j ∈ Finset.Icc 1 (w / k), h k j = ∑ p ∈ Finset.filter (fun p => p.1 * p.2 ≤ w) (Finset.Icc 1 w ×ˢ Finset.Icc 1 w), h p.1 p.2 := by
    rw [ Finset.sum_sigma' ];
    refine' Finset.sum_bij ( fun p hp => ( p.1, p.2 ) ) _ _ _ _ <;> simp +contextual;
    · exact fun a ha₁ ha₂ ha₃ ha₄ => ⟨ ha₄.trans ( Nat.div_le_self _ _ ), by nlinarith [ Nat.div_mul_le_self w a.fst ] ⟩;
    · grind;
    · exact fun a b ha hw hb hw' hab => by rw [ Nat.le_div_iff_mul_le ha ] ; linarith;
  rw [ h_biUnion, show ( Finset.filter ( fun p : ℕ × ℕ => p.1 * p.2 ≤ w ) ( Finset.Icc 1 w ×ˢ Finset.Icc 1 w ) ) = Finset.biUnion ( Finset.Icc 1 w ) fun d => Finset.image ( fun p : ℕ × ℕ => p ) ( Nat.divisorsAntidiagonal d ) from ?_ ];
  · rw [ Finset.sum_biUnion ] ; aesop;
    intro d hd e he hde; simp_all +decide [ Finset.disjoint_left ] ;
  · ext ⟨x, y⟩; simp [Finset.mem_biUnion];
    exact ⟨ fun h => ⟨ ⟨ by nlinarith, h.2 ⟩, by aesop_cat, by aesop_cat ⟩, fun h => ⟨ ⟨ ⟨ Nat.pos_of_ne_zero h.2.1, by nlinarith [ Nat.pos_of_ne_zero h.2.2 ] ⟩, ⟨ Nat.pos_of_ne_zero h.2.2, by nlinarith [ Nat.pos_of_ne_zero h.2.1 ] ⟩ ⟩, h.1.2 ⟩ ⟩

/-
Rewrite an iterated sum `∑_{k ≤ a} ∑_{m ≤ y/k} f m` as a sum over the hyperbola
region `{(k,m) ∈ [1,a]×[1,y] : k·m ≤ y}`.
-/
lemma sum_Icc_div_eq_filter {A : Type*} [AddCommMonoid A] (a y : ℕ) (f : ℕ → A) :
    (∑ k ∈ Finset.Icc 1 a, ∑ m ∈ Finset.Icc 1 (y / k), f m)
      = ∑ p ∈ (Finset.Icc 1 a ×ˢ Finset.Icc 1 y).filter (fun p => p.1 * p.2 ≤ y),
          f p.2 := by
  rw [ Finset.sum_filter, Finset.sum_product ];
  refine' Finset.sum_congr rfl fun x hx => _;
  rw [ ← Finset.sum_filter ];
  refine' Finset.sum_bij ( fun m hm => m ) _ _ _ _ <;> simp_all +decide;
  · exact fun a ha₁ ha₂ => ⟨ by nlinarith [ Nat.div_mul_le_self y x ], by nlinarith [ Nat.div_mul_le_self y x ] ⟩;
  · exact fun b hb₁ hb₂ hb₃ => by rw [ Nat.le_div_iff_mul_le hx.1 ] ; linarith;

/-
**The fundamental identity of the Mertens function:** `∑_{k=1}^{y} M(⌊y/k⌋) = 1`
for `y ≥ 1`.
-/
lemma mertens_fundamental (y : ℕ) (hy : 0 < y) :
    (∑ k ∈ Finset.Icc 1 y, mertens (y / k)) = 1 := by
  -- By sum_pairs_eq_sum_antidiagonal, rewrite the sum as a sum over the hyperbola region.
  have h_sum_antidiagonal : ∑ k ∈ Finset.Icc 1 y, mertens (y / k) = ∑ d ∈ Finset.Icc 1 y, ∑ p ∈ d.divisorsAntidiagonal, mu p.2 := by
    convert sum_pairs_eq_sum_antidiagonal y ( fun k j => mu j ) using 1;
  -- For fixed $d$, $\sum_{p \in d.divisorsAntidiagonal} \mu(p.2) = \sum_{i \in d.divisors} \mu(i)$.
  have h_divisors_sum : ∀ d ∈ Finset.Icc 1 y, ∑ p ∈ d.divisorsAntidiagonal, mu p.2 = ∑ i ∈ d.divisors, mu i := by
    intro d hd;
    refine' Finset.sum_bij ( fun p hp => p.2 ) _ _ _ _ <;> simp_all +decide;
    · exact fun a b h1 h2 => h1 ▸ dvd_mul_left _ _;
    · aesop;
    · exact fun b hb _ => ⟨ d / b, Nat.div_mul_cancel hb ⟩;
  rw [ h_sum_antidiagonal, Finset.sum_congr rfl h_divisors_sum ];
  rw [ Finset.sum_congr rfl fun x hx => sum_mu_divisors x <| Finset.mem_Icc.mp hx |>.1 ] ; aesop

/-
**Asymmetric Dirichlet hyperbola identity.** With `ν = ⌊√y⌋` and `κ = ⌊y/(ν+1)⌋`,
`∑_{k=1}^{κ} M(⌊y/k⌋) + ∑_{m=1}^{ν} ⌊y/m⌋·μ(m) - κ·M(ν) = 1` for `y ≥ 1`.
This is the analytic core from which the recursion is derived.
-/
lemma hyperbola_split (y : ℕ) (hy : 0 < y) :
    (∑ k ∈ Finset.Icc 1 (kappa y), mertens (y / k))
      + (∑ m ∈ Finset.Icc 1 (Nat.sqrt y), (y / m : ℤ) * mu m)
      - (kappa y : ℤ) * mertens (Nat.sqrt y) = 1 := by
  -- Start by using the identity from `mertens_fundamental`, which states that $\sum_{k=1}^{y} M\left(\left\lfloor \frac{y}{k} \right\rfloor\right) = 1$.
  have h_identity : (∑ k ∈ Finset.Icc 1 y, mertens (y / k)) = 1 := by
    convert mertens_fundamental y hy using 1;
  -- We'll use the fact that $\sum_{k=1}^{y} M\left(\left\lfloor \frac{y}{k} \right\rfloor\right)$ can be split into two parts: one over $k \leq \kappa$ and one over $k > \kappa$.
  have h_split : ∑ k ∈ Finset.Icc 1 y, mertens (y / k) = ∑ k ∈ Finset.Icc 1 (kappa y), mertens (y / k) + ∑ k ∈ Finset.Icc (kappa y + 1) y, mertens (y / k) := by
    erw [ Finset.sum_Ico_consecutive ] <;> norm_cast <;> norm_num;
    exact Nat.div_le_self _ _;
  -- For $k > \kappa$, we have $M\left(\left\lfloor \frac{y}{k} \right\rfloor\right) = \sum_{m=1}^{\left\lfloor \frac{y}{k} \right\rfloor} \mu(m)$.
  have h_large_k : ∑ k ∈ Finset.Icc (kappa y + 1) y, mertens (y / k) = ∑ m ∈ Finset.Icc 1 (Nat.sqrt y), ∑ k ∈ Finset.Icc (kappa y + 1) y, (if k * m ≤ y then mu m else 0) := by
    rw [ Finset.sum_comm, Finset.sum_congr rfl ];
    intro k hk;
    have h_large_k : y / k ≤ Nat.sqrt y := by
      simp +zetaDelta at *;
      exact Nat.le_of_lt_succ <| Nat.div_lt_of_lt_mul <| by nlinarith! [ Nat.lt_succ_sqrt y, Nat.div_add_mod y ( Nat.sqrt y + 1 ), Nat.mod_lt y ( Nat.succ_pos ( Nat.sqrt y ) ), show kappa y = y / ( Nat.sqrt y + 1 ) from rfl ] ;
    rw [ ← Finset.sum_filter ];
    refine' Finset.sum_bij ( fun x hx => x ) _ _ _ _ <;> simp_all +decide;
    · exact fun a ha₁ ha₂ => ⟨ le_trans ha₂ h_large_k, by nlinarith [ Nat.div_mul_le_self y k ] ⟩;
    · exact fun b hb₁ hb₂ hb₃ => by rw [ Nat.le_div_iff_mul_le ( by linarith ) ] ; linarith;
  -- For $k > \kappa$, we have $\sum_{k=\kappa+1}^{y} \mathbf{1}_{k m \leq y} = \left\lfloor \frac{y}{m} \right\rfloor - \kappa$.
  have h_indicator : ∀ m ∈ Finset.Icc 1 (Nat.sqrt y), ∑ k ∈ Finset.Icc (kappa y + 1) y, (if k * m ≤ y then 1 else 0) = (y / m : ℕ) - kappa y := by
    intros m hm
    have h_indicator_eq : Finset.filter (fun k => k * m ≤ y) (Finset.Icc (kappa y + 1) y) = Finset.Icc (kappa y + 1) (y / m) := by
      ext; simp [Finset.mem_Icc];
      exact ⟨ fun h => ⟨ h.1.1, Nat.le_div_iff_mul_le ( Finset.mem_Icc.mp hm |>.1 ) |>.2 h.2 ⟩, fun h => ⟨ ⟨ h.1, Nat.le_trans h.2 ( Nat.div_le_self _ _ ) ⟩, Nat.le_div_iff_mul_le ( Finset.mem_Icc.mp hm |>.1 ) |>.1 h.2 ⟩ ⟩;
    simp_all +decide [ Finset.sum_ite ];
  -- Substitute the indicator function result into the sum.
  have h_substitute : ∑ m ∈ Finset.Icc 1 (Nat.sqrt y), ∑ k ∈ Finset.Icc (kappa y + 1) y, (if k * m ≤ y then mu m else 0) = ∑ m ∈ Finset.Icc 1 (Nat.sqrt y), ((y / m : ℕ) - kappa y) * mu m := by
    refine' Finset.sum_congr rfl fun m hm => _;
    simp_all +decide [ Finset.sum_ite ];
    exact Or.inl <| Nat.cast_sub <| Nat.le_div_iff_mul_le hm.1 |>.2 <| by nlinarith [ Nat.sqrt_le y, show kappa y * ( Nat.sqrt y + 1 ) ≤ y from Nat.div_mul_le_self _ _ ] ;
  simp_all +decide [ sub_mul, Finset.sum_sub_distrib ];
  convert h_identity using 1 ; norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mertens ] ; ring

/-
**Collapse of the summand.** For `y ≥ 1` and `u > ⌊√y⌋`, the elaborate expression
`S(y, u)` collapses to `∑_{j=1}^{⌊y/u⌋} M(⌊y/j⌋)`.
-/
lemma Sfun_eq (y u : ℕ) (hy : 0 < y) (hu : Nat.sqrt y < u) :
    Sfun y u = ∑ j ∈ Finset.Icc 1 (y / u), mertens (y / j) := by
  -- From `hu : Nat.sqrt y < u`, we get `u ≥ Nat.sqrt y + 1`, so by `Nat.div_le_div_left` (since `Nat.sqrt y + 1 > 0`), `y / u ≤ y / (Nat.sqrt y + 1) = kappa y`.
  have h_le : y / u ≤ kappa y := by
    exact Nat.div_le_div_left hu ( Nat.succ_pos _ );
  -- By hyperbola_split, ∑_{k∈Icc 1 κ} mertens (y/k) + ∑_{m∈Icc 1 ν} (y/m)*mu m - (κ)*mertens ν = 1, hence 1 + (κ)*mertens ν - ∑_{n∈Icc 1 ν} (y/n)*mu n = ∑_{k∈Icc 1 κ} mertens (y/k).
  have h_sum_split : (∑ k ∈ Finset.Icc 1 (kappa y), mertens (y / k)) = 1 + (kappa y : ℤ) * mertens (Nat.sqrt y) - (∑ n ∈ Finset.Icc 1 (Nat.sqrt y), (y / n : ℤ) * mu n) := by
    linarith [ hyperbola_split y hy ];
  convert congr_arg ( fun x : ℤ => x - ∑ n ∈ Finset.Ioc ( y / u ) ( kappa y ), mertens ( y / n ) ) h_sum_split.symm using 1;
  · unfold Sfun; ring_nf;
    rw [ show Icc ( 1 + y / u ) ( kappa y ) = Ioc ( y / u ) ( kappa y ) by ext; simp +decide ; omega ] ; ring;
  · exact eq_tsub_of_add_eq <| by erw [ Finset.sum_Ioc_consecutive ] <;> linarith!;

/-- **Main theorem (Generalized Mertens recursion identity).**
For `x ≥ 2` and `⌊√x⌋ < u < x`,
`M(x) = ∑_{k=1}^{⌊x/u⌋} μ(k) · S(⌊x/k⌋, u)`.

The hypothesis `hx : 2 ≤ x` is kept as in the source statement, but is in fact
unnecessary: the existence of `u` with `⌊√x⌋ < u < x` already forces `x ≥ 2`. -/
theorem mertens_recursion (x u : ℕ) (hx : 2 ≤ x)
    (hu1 : Nat.sqrt x < u) (hu2 : u < x) :
    mertens x = ∑ k ∈ Finset.Icc 1 (x / u), mu k * Sfun (x / k) u := by
  -- By Sfun_eq, we can rewrite Sfun (x/k) u as ∑_{j∈Icc 1 (w/k)} mertens (x/(k*j)).
  have h_sfun_eq : ∀ k ∈ Finset.Icc 1 (x / u), Sfun (x / k) u = ∑ j ∈ Finset.Icc 1 ((x / k) / u), mertens ((x / k) / j) := by
    intros k hk
    apply Sfun_eq;
    · exact Nat.div_pos ( by nlinarith [ Finset.mem_Icc.mp hk, Nat.div_mul_le_self x u ] ) ( by linarith [ Finset.mem_Icc.mp hk ] );
    · refine' lt_of_le_of_lt _ hu1;
      exact Nat.sqrt_le_sqrt ( Nat.div_le_self _ _ );
  -- Apply sum_pairs_eq_sum_antidiagonal with h k j := mu k * mertens (x/(k*j)).
  have h_sum_pairs_eq_sum_antidiagonal : ∑ k ∈ Finset.Icc 1 (x / u), ∑ j ∈ Finset.Icc 1 ((x / k) / u), mu k * mertens (x / (k * j)) = ∑ d ∈ Finset.Icc 1 (x / u), ∑ p ∈ d.divisorsAntidiagonal, mu p.1 * mertens (x / d) := by
    convert sum_pairs_eq_sum_antidiagonal ( x / u ) ( fun k j => mu k * mertens ( x / ( k * j ) ) ) using 1;
    · simp +decide only [Nat.div_div_eq_div_mul, mul_comm];
    · exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ Nat.mem_divisorsAntidiagonal ] at hj; aesop;
  -- By sum_mu_divisors, we know that ∑_{p∈d.divisorsAntidiagonal} mu p.1 = if d=1 then 1 else 0.
  have h_sum_mu_divisors : ∀ d ∈ Finset.Icc 1 (x / u), ∑ p ∈ d.divisorsAntidiagonal, mu p.1 = if d = 1 then 1 else 0 := by
    intro d hd; convert sum_mu_divisors d ( Finset.mem_Icc.mp hd |>.1 ) using 1; rw [ Nat.sum_divisorsAntidiagonal fun a b => mu a ] ;
  convert h_sum_pairs_eq_sum_antidiagonal.symm using 1;
  · rw [ Finset.sum_congr rfl fun i hi => by rw [ ← Finset.sum_mul _ _ _, h_sum_mu_divisors i hi ] ] ; norm_num [ Finset.sum_ite ];
    grind;
  · exact Finset.sum_congr rfl fun k hk => by rw [ h_sfun_eq k hk, Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun j hj => by rw [ Nat.div_div_eq_div_mul ] ;

end MertensRecursion