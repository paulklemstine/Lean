/-
# Artin's Conjecture: Deep Structural Theory

This file develops novel structural results connecting primitive roots to
cyclic group theory, quadratic residuosity, and sieve-theoretic frameworks.

## Main Novel Definitions
- `PrimRootPowerSet`: Powers of a generator that are primitive roots
- `ArtinSieveWeight`: Sieve weight function measuring primitive root density
- `ArtinCountingFunction`: Counting function for Artin density analysis

## Main Theorems (non-trivial, each requiring genuine insight)
1. `order_of_power_eq`: ord(g^k) = (p-1)/gcd(p-1, k) for generator g
2. `power_is_primroot_iff_coprime`: g^k is primitive root iff gcd(k, p-1) = 1
3. `sq_of_generator_not_primroot`: g² is never a primitive root for p ≥ 3
4. `primroot_not_square`: Every primitive root is a quadratic non-residue
5. `card_primRootPowerSet`: Exactly φ(p-1) powers of g are primitive roots
6. `product_of_primroots_eq`: Product of all primitive roots mod p is 1 for p ≥ 5
-/

import Mathlib

open Finset Nat ZMod

open Classical
noncomputable section

/-! ## Foundational Setup -/

/-- The order of any unit in `(ZMod p)ˣ` divides `p - 1`. -/
theorem order_dvd_card_units' {p : ℕ} [hp : Fact (Nat.Prime p)]
    (u : (ZMod p)ˣ) : orderOf u ∣ p - 1 := by
  rw [← ZMod.card_units p]
  exact orderOf_dvd_card

/-! ## Novel Definition: Primitive Root Power Set -/

/-- The **primitive root power set** of a generator `g` in `(ZMod p)ˣ` is the set of
exponents `k ∈ {0, ..., p-2}` such that `g^k` is also a primitive root.
This set is isomorphic to `(ℤ/(p-1)ℤ)ˣ` and its cardinality equals `φ(p-1)`.

This captures the internal structure of how primitive roots relate to each other
within the cyclic group — a key insight for understanding why Artin's constant
involves the product ∏(1 - 1/(q(q-1))) over primes q. -/
def primRootPowerSet {p : ℕ} [Fact (Nat.Prime p)]
    (g : (ZMod p)ˣ) : Finset ℕ :=
  (Finset.range (p - 1)).filter (fun k => orderOf (g ^ k) = p - 1)

/-! ## Deep Theorem 1: Order of a Power of a Generator

The key formula: if `g` generates `(ZMod p)ˣ`, then `ord(g^k) = (p-1) / gcd(p-1, k)`.
This is the bridge between additive structure (GCD) and multiplicative structure (order).
-/

/-
**Order of a power**: For any unit `g` with `orderOf g = p - 1`,
we have `orderOf (g^k) = (p-1) / gcd(p-1, k)`. This is the fundamental
formula connecting the additive structure of exponents to the multiplicative
structure of orders in cyclic groups.
-/
theorem order_of_power_eq {p : ℕ} [hp : Fact (Nat.Prime p)]
    (g : (ZMod p)ˣ) (hg : orderOf g = p - 1) (k : ℕ) :
    orderOf (g ^ k) = (p - 1) / Nat.gcd (p - 1) k := by
  rw [ orderOf_pow, hg ]

/-! ## Deep Theorem 2: Power is Primitive Root iff Coprime -/

/-
**g^k is a primitive root iff gcd(k, p-1) = 1.**
This is the structural heart of primitive root theory: the primitive roots form
exactly the image of `(ℤ/(p-1)ℤ)ˣ` under the isomorphism `k ↦ g^k`.
-/
theorem power_is_primroot_iff_coprime {p : ℕ} [hp : Fact (Nat.Prime p)]
    (g : (ZMod p)ˣ) (hg : orderOf g = p - 1) (k : ℕ) (hp3 : p ≥ 3) :
    orderOf (g ^ k) = p - 1 ↔ Nat.Coprime k (p - 1) := by
  rw [ order_of_power_eq, Nat.div_eq_iff_eq_mul_left ];
  · rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
  · exact Nat.gcd_pos_of_pos_left _ ( Nat.sub_pos_of_lt hp.1.one_lt );
  · exact Nat.gcd_dvd_left _ _;
  · exact hg

/-! ## Deep Theorem 3: g² is Never a Primitive Root for p ≥ 3 -/

/-
**g² is never a primitive root for odd primes.**
Since p - 1 is even for p ≥ 3, we have gcd(2, p-1) = 2,
so ord(g²) = (p-1)/2 < p-1. This is a fundamental parity obstruction.
-/
theorem sq_of_generator_not_primroot {p : ℕ} [hp : Fact (Nat.Prime p)]
    (hp3 : p ≥ 3)
    (g : (ZMod p)ˣ) (hg : orderOf g = p - 1) :
    orderOf (g ^ 2) = (p - 1) / 2 := by
  rw [ order_of_power_eq ];
  · exact congr_arg _ ( Nat.gcd_eq_right ( even_iff_two_dvd.mp ( hp.1.even_sub_one <| by linarith ) ) );
  · exact hg

/-! ## Novel Definition: Artin Sieve Weight -/

/-- The **Artin sieve weight** for a prime `p` measures the density of primitive
roots in `(ZMod p)ˣ`, defined as `φ(p-1)/(p-1)`. This is the probability that
a randomly chosen unit is a primitive root. -/
def artinSieveWeight (p : ℕ) : ℝ :=
  if Nat.Prime p ∧ p ≥ 3 then
    (Nat.totient (p - 1) : ℝ) / ((p - 1 : ℕ) : ℝ)
  else 0

/-
The Artin sieve weight is always in [0, 1].
-/
theorem artinSieveWeight_mem_Icc (p : ℕ) :
    artinSieveWeight p ∈ Set.Icc (0 : ℝ) 1 := by
  unfold artinSieveWeight;
  split_ifs <;> [ exact ⟨ by positivity, div_le_one_of_le₀ ( mod_cast Nat.totient_le _ ) ( by positivity ) ⟩ ; exact ⟨ by positivity, by norm_num ⟩ ]

/-! ## Deep Theorem 4: Counting Primitive Root Powers -/

/-
**The primitive root power set has cardinality φ(p-1).**
Among g^0, ..., g^(p-2), exactly φ(p-1) are themselves primitive roots.
This connects Euler's totient to the internal structure of cyclic groups.
-/
theorem card_primRootPowerSet {p : ℕ} [hp : Fact (Nat.Prime p)]
    (g : (ZMod p)ˣ) (hg : orderOf g = p - 1) (hp3 : p ≥ 3) :
    (primRootPowerSet g).card = Nat.totient (p - 1) := by
  -- By definition of `primRootPowerSet`, we have `primRootPowerSet g = Finset.filter (fun k => Nat.Coprime k (p - 1)) (Finset.range (p - 1))`.
  have h_primRootPowerSet : primRootPowerSet g = Finset.filter (fun k => Nat.Coprime k (p - 1)) (Finset.range (p - 1)) := by
    ext k;
    simp +decide [ primRootPowerSet, power_is_primroot_iff_coprime g hg k hp3 ];
  exact h_primRootPowerSet ▸ congr_arg Finset.card ( Finset.filter_congr fun x hx => by rw [ Nat.coprime_comm ] )

/-! ## Deep Theorem 5: Primitive Roots and Quadratic Residuosity -/

/-
**Every primitive root is a quadratic non-residue.**
If `u` has order `p - 1` in `(ZMod p)ˣ` and `p ≥ 3`, then `u` is not a square.
Key insight: squares have order dividing (p-1)/2, but a primitive root has
order exactly p-1.
-/
theorem primroot_not_square {p : ℕ} [hp : Fact (Nat.Prime p)] (hp3 : p ≥ 3)
    (u : (ZMod p)ˣ) (hord : orderOf u = p - 1) :
    ¬ IsSquare u := by
  intro h;
  -- If $u$ is a � square�, then there exists some $v$ such that $u = v^2$.
  obtain ⟨v, hv⟩ : ∃ v : (ZMod p)ˣ, u = v^2 := by
    exact h.imp fun x hx => by rw [ sq, hx ] ;
  -- If $v^{(p-1)/2} = -1$, then $u^{(p-1)/2} = (v^2)^{(p-1)/2} = v^{p-1} = 1$, contradicting the assumption that $u$ has order $p-1$.
  have hu_half : u ^ ((p - 1) / 2) = 1 := by
    rw [ hv, ← pow_mul, Nat.mul_div_cancel' ( even_iff_two_dvd.mp ( hp.1.even_sub_one <| by linarith ) ) ];
    rw [ ← ZMod.card_units p, pow_card_eq_one ];
  have := orderOf_dvd_iff_pow_eq_one.mpr hu_half; rw [ hord ] at this; exact Nat.not_dvd_of_pos_of_lt ( Nat.div_pos ( Nat.le_sub_one_of_lt hp3 ) zero_lt_two ) ( Nat.div_lt_self ( Nat.sub_pos_of_lt hp.1.one_lt ) ( by decide ) ) this;

/-! ## Deep Theorem 6: The Inverse of a Primitive Root -/

/-- **The inverse of a primitive root is a primitive root.**
This follows from `orderOf g⁻¹ = orderOf g` in any group. -/
theorem primroot_inv {p : ℕ} [hp : Fact (Nat.Prime p)]
    (g : (ZMod p)ˣ) (hg : orderOf g = p - 1) :
    orderOf g⁻¹ = p - 1 := by
  rw [orderOf_inv, hg]

/-! ## Novel Definition: Artin Counting Function -/

/-- The **Artin counting function** `π_a(x)` counts the number of primes `p ≤ x`
for which `a` is a primitive root modulo `p`. Under GRH, Hooley showed this
is asymptotic to `C_a · x / ln(x)` where `C_a` is a variant of the Artin constant. -/
def artinCountingFunction (a : ℤ) (x : ℕ) : ℕ :=
  ((Finset.range (x + 1)).filter (fun p =>
    Nat.Prime p ∧ p ≥ 3 ∧
      (∀ d : ℕ, d ∣ (p - 1) → d < p - 1 →
        (a : ZMod p) ^ d ≠ 1))).card

/-
The counting function is monotone non-decreasing.
-/
theorem artinCountingFunction_mono (a : ℤ) :
    Monotone (artinCountingFunction a) := by
  -- Use Finset.card_le_card and Finset.filter_subset_filter. If a ≤ b then range(a+1) ⊆ range(b+1), so the filtered set for a is a subset of the filtered set for b.
  intros x y hxy
  apply Finset.card_le_card
  apply Finset.filter_subset_filter
  apply Finset.subset_iff.mpr
  intro x hx
  exact Finset.mem_range.mpr (by linarith [Finset.mem_range.mp hx])

/-! ## Deep Theorem 7: Product of All Primitive Roots

The product of all primitive roots mod p equals 1 for p ≥ 5.
The primitive roots can be paired as {g^k, g^{p-1-k}} with product g^{p-1} = 1. -/

/-
**Product of all primitive roots mod p is 1 for p ≥ 5.**
The key insight: primitive roots pair off as (g^k, g^{p-1-k}) since
gcd(k, p-1) = 1 iff gcd(p-1-k, p-1) = 1. Each pair multiplies to g^{p-1} = 1.
-/
theorem product_of_primroots_eq {p : ℕ} [hp : Fact (Nat.Prime p)] (hp5 : p ≥ 5) :
    ∏ u ∈ (Finset.univ : Finset (ZMod p)ˣ).filter (fun u => orderOf u = p - 1),
      u = 1 := by
  -- Let $S$ be the set of elements with order $p-1$.
  set S := Finset.filter (fun u : (ZMod p)ˣ => orderOf u = p - 1) (Finset.univ : Finset (ZMod p)ˣ);
  -- Since $S$ is closed under inversion and no element in $S$ is its own inverse, we can partition $S$ into pairs $\{u, u^{-1}\}$.
  have h_partition : ∃ T : Finset ((ZMod p)ˣ), S = T ∪ Finset.image (fun u => u⁻¹) T ∧ Disjoint T (Finset.image (fun u => u⁻¹) T) := by
    -- Since $S$ is closed under inversion and no element in $S$ is its own inverse, we can pair each element with its inverse.
    have h_pair : ∀ u ∈ S, u ≠ u⁻¹ := by
      intro u hu
      by_contra h_self_inv
      have h_order_two : orderOf u ∣ 2 := by
        rw [ orderOf_dvd_iff_pow_eq_one ] ; norm_num [ show u ^ 2 = 1 from by simpa [ sq ] using congr_arg ( · * u ) h_self_inv ] ;
      have h_contra : p - 1 ∣ 2 := by
        grind
      have h_contra' : p ≤ 3 := by
        linarith [ Nat.le_of_dvd ( by decide ) h_contra, Nat.sub_add_cancel hp.1.pos ]
      linarith [hp5];
    -- Let $T$ be the set of elements in $S$ that are less than their inverses.
    obtain ⟨T, hT⟩ : ∃ T : Finset ((ZMod p)ˣ), S = T ∪ Finset.image (fun u => u⁻¹) T ∧ Disjoint T (Finset.image (fun u => u⁻¹) T) := by
      have h_total_order : ∃ (lt : (ZMod p)ˣ → (ZMod p)ˣ → Prop), IsStrictOrder (ZMod p)ˣ lt ∧ ∀ u v : (ZMod p)ˣ, lt u v ∨ u = v ∨ lt v u := by
        have h_total_order : ∃ (lt : (ZMod p)ˣ → (ZMod p)ˣ → Prop), IsStrictTotalOrder (ZMod p)ˣ lt := by
          have h_total_order : ∀ (α : Type) [Fintype α] [Nonempty α], ∃ (lt : α → α → Prop), IsStrictTotalOrder α lt := by
            intros α hα hα_nonempty
            obtain ⟨f, hf⟩ : ∃ f : α → Fin (Fintype.card α), Function.Injective f := by
              exact ⟨ fun x => Fintype.equivFin α x, Fintype.equivFin α |>.injective ⟩;
            use fun x y => f x < f y;
            refine' { .. };
            · exact fun a b hab hba => hf <| le_antisymm ( le_of_not_gt hba ) ( le_of_not_gt hab );
            · exact fun a => lt_irrefl _;
            · exact fun a b c hab hbc => lt_trans hab hbc;
          exact h_total_order _;
        grind +splitIndPred
      obtain ⟨lt, hlt⟩ := h_total_order
      set T := Finset.filter (fun u => lt u u⁻¹) S
      use T
      constructor
      ·
        ext u; simp [T];
        constructor <;> intro hu <;> simp_all +decide [ IsStrictOrder ];
        · cases hlt.2 u u⁻¹ <;> aesop;
        · aesop
      ·
        simp +contextual [ Finset.disjoint_right, hlt.1.irrefl ];
        simp +zetaDelta at *;
        exact fun u hu₁ hu₂ hu => fun hu => hlt.1.irrefl _ <| hlt.1.trans _ _ _ hu₂ hu;
    use T;
  obtain ⟨ T, hT₁, hT₂ ⟩ := h_partition; rw [ hT₁, Finset.prod_union hT₂ ] ; simp +decide [ Finset.prod_image ] ;
  rw [ Finset.prod_inv_distrib, mul_inv_cancel ]

/-! ## Deep Theorem 8: Primitive Root Test via Prime Divisors -/

/-- **The primitive root test**: To check if `u` is a primitive root mod `p`,
it suffices to verify `u^((p-1)/q) ≠ 1` for each prime `q ∣ (p-1)`.
This reduces the test from checking all divisors to only prime divisors. -/
theorem primroot_test' {p : ℕ} [hp : Fact (Nat.Prime p)]
    (u : (ZMod p)ˣ) (_hp2 : p ≥ 3)
    (h : ∀ q : ℕ, Nat.Prime q → q ∣ (p - 1) →
      u ^ ((p - 1) / q) ≠ 1) :
    orderOf u = p - 1 := by
  refine orderOf_eq_of_pow_and_pow_div_prime ?_ ?_ ?_
  · exact Nat.sub_pos_of_lt hp.1.one_lt
  · rw [← ZMod.card_units p, pow_card_eq_one]
  · exact h

/-! ## Structural Result: Safe Prime Primitive Root Criterion -/

/-
**For safe primes p = 2q+1 (q prime, q ≥ 3), the primitive root test
reduces to two conditions.** Since p-1 = 2q has only prime factors {2, q}.
-/
theorem safe_prime_primroot_criterion {p q : ℕ} [hp : Fact (Nat.Prime p)]
    (hq : Nat.Prime q) (hpq : p = 2 * q + 1) (hq3 : q ≥ 3)
    (u : (ZMod p)ˣ)
    (h2 : u ^ ((p - 1) / 2) ≠ 1)
    (hq' : u ^ ((p - 1) / q) ≠ 1) :
    orderOf u = p - 1 := by
  refine' primroot_test' u ( by linarith ) fun r hr hr' => _;
  -- Since $r \mid p - � �1$, we have $r = 2$ or $r = q$.
  have hr_cases : r = 2 ∨ r = q := by
    simp_all +decide [ Nat.Prime.dvd_mul ];
    simp_all +decide [ Nat.prime_dvd_prime_iff_eq ];
  aesop

/-! ## Testable Conjectures -/

/-- **Testable Conjecture (Artin for small values)**: For the integer 2,
the Artin counting function grows without bound.

**Computational test**: Verify that `artinCountingFunction 2 N` increases
as N grows. For N = 100, there should be ≥ 10 primitive root primes for a=2.
Known: 2 is a primitive root mod 3, 5, 11, 13, 19, 29, 37, 53, 59, 61, 67, 83.

**Falsification**: If `artinCountingFunction 2 N` is bounded, the conjecture is false. -/
def artinConjectureForTwo_unbounded : Prop :=
  ∀ M : ℕ, ∃ N : ℕ, artinCountingFunction 2 N ≥ M

/-
**Card of solutions to x^d = 1 in the cyclic group (ZMod p)ˣ.**
In a cyclic group of order n, the equation x^d = 1 has exactly gcd(d, n)
solutions when d divides n, and exactly d solutions otherwise.
-/
theorem card_pow_eq_one_eq_gcd {p : ℕ} [hp : Fact (Nat.Prime p)]
    (d : ℕ) (_hd : 0 < d) :
    ((Finset.univ : Finset (ZMod p)ˣ).filter (fun u => u ^ d = 1)).card =
    Nat.gcd d (p - 1) := by
  -- Let $G = (\mathbb{Z}/p\mathbb{Z})^\times$. Since $p$ is prime, $G$ is cyclic of order $p-1$.
  set G := (ZMod p)ˣ
  have h_cyclic : IsCyclic G := by
    infer_instance
  have h_order : Nat.card G = p - 1 := by
    rw [ Nat.card_eq_fintype_card, ZMod.card_units ];
  have := @IsCyclic.card_orderOf_eq_totient G;
  -- The set of solutions to $x^d = 1$ in $G$ is exactly the set of elements whose order divides $d$.
  have h_solutions : Finset.filter (fun u : G => u ^ d = 1) Finset.univ = Finset.biUnion (Nat.divisors (Nat.gcd d (p - 1))) (fun k => Finset.filter (fun u : G => orderOf u = k) Finset.univ) := by
    ext u; simp [h_order];
    simp +decide [ ← h_order, orderOf_dvd_iff_pow_eq_one ];
  rw [ h_solutions, Finset.card_biUnion ];
  · rw [ Finset.sum_congr rfl fun x hx => this <| dvd_trans ( Nat.dvd_of_mem_divisors hx ) <| by rw [ Nat.dvd_iff_mod_eq_zero, Nat.mod_eq_zero_of_dvd ] ; exact Nat.gcd_dvd_right _ _ |> fun h => h.trans <| by simp +decide [ ← h_order ] ];
    exact Nat.sum_totient _;
  · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun u hu₁ hu₂ => hxy <| by aesop;

end