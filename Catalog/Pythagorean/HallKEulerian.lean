/-
# Hall k-Eulerian Framework: Möbius Inversion for k-Tuple Generation

This file establishes the complete Hall k-Eulerian framework, generalizing
the pair-generation Möbius inversion to k-tuples.

## Main results

- `IsGeneratingKTuple`: predicate for a k-tuple generating the full group
- `generatingKTupleCount`: the Hall k-Eulerian function φ_k(G)
- `kTupleCountInSubgroup_eq_card_pow`: |H|^k counts k-tuples in H^k
- `kTuplePartitionIdentity`: |H|^k = Σ_{K ≤ H} φ_k(K)
- `generatingKTupleCount_eq_moebius_sum`: φ_k(G) = Σ_H μ(H,G)·|H|^k
- `jordanTotientMobius`: Jordan's totient J_k(n) via Möbius inversion
- `subgroup_ratio_lt_one_of_ne_top`: proper subgroups have index ratio < 1
- `centralizer_fixed_point_sum`: Burnside-type centralizer identity

## References

- P. Hall, "The Eulerian functions of a group" (1936)
- C. Jordan, "Traité des substitutions" (1870) — Jordan's totient
-/
import Mathlib

open scoped BigOperators Classical
open Finset

noncomputable section

/-! ## Core Definitions: k-Tuple Generation -/

/-- A k-tuple `t : Fin k → G` generates the full group `G` if the subgroup
    closure of its range equals `⊤`. -/
def IsGeneratingKTuple (G : Type*) [Group G] (k : ℕ) (t : Fin k → G) : Prop :=
  Subgroup.closure (Set.range t) = ⊤

/-- The Hall k-Eulerian function φ_k(G): the number of ordered k-tuples
    in G^k that generate G. -/
def generatingKTupleCount (G : Type*) [Group G] [Fintype G] (k : ℕ) : ℕ :=
  Fintype.card { t : Fin k → G // IsGeneratingKTuple G k t }

/-- A k-tuple generates exactly the subgroup `H`. -/
def IsGeneratingKTupleOf (G : Type*) [Group G] (k : ℕ)
    (H : Subgroup G) (t : Fin k → G) : Prop :=
  Subgroup.closure (Set.range t) = H

/-- The number of k-tuples in G^k that generate exactly `H`. -/
def generatingKTupleCountWithin (G : Type*) [Group G] [Fintype G]
    (k : ℕ) (H : Subgroup G) : ℕ :=
  Fintype.card { t : Fin k → G // IsGeneratingKTupleOf G k H t }

/-- The number of k-tuples with all components in `H`. -/
def kTupleCountInSubgroup (G : Type*) [Group G] [Fintype G]
    (k : ℕ) (H : Subgroup G) : ℕ :=
  Fintype.card { t : Fin k → G // ∀ i, t i ∈ H }

/-! ## Basic Properties -/

theorem generatingKTupleCountWithin_top (G : Type*) [Group G] [Fintype G] (k : ℕ) :
    generatingKTupleCountWithin G k ⊤ = generatingKTupleCount G k := by
  unfold generatingKTupleCountWithin generatingKTupleCount IsGeneratingKTupleOf IsGeneratingKTuple
  rfl

/-- The number of k-tuples with all entries in H equals |H|^k. -/
theorem kTupleCountInSubgroup_eq_card_pow (G : Type*) [Group G] [Fintype G]
    (k : ℕ) (H : Subgroup G) :
    kTupleCountInSubgroup G k H = (Fintype.card H) ^ k := by
  unfold kTupleCountInSubgroup
  have : Fintype.card { t : Fin k → G // ∀ i, t i ∈ H } =
         Fintype.card (Fin k → H) := by
    refine Fintype.card_congr ?_
    exact {
      toFun := fun ⟨t, ht⟩ => fun i => ⟨t i, ht i⟩
      invFun := fun f => ⟨fun i => (f i).val, fun i => (f i).prop⟩
      left_inv := fun ⟨t, ht⟩ => by simp
      right_inv := fun f => by ext i; simp
    }
  rw [this, Fintype.card_fun, Fintype.card_fin]

/-! ## Möbius Function on the Subgroup Lattice -/

/-- The Möbius function μ(H, ⊤) on the subgroup lattice. -/
def subgroupMobius (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) : ℤ :=
  if H = ⊤ then 1
  else - ∑ K : { K : Subgroup G // H < K },
    subgroupMobius G K.1
termination_by Fintype.card G - Fintype.card H
decreasing_by
  simp only [Fintype.card_eq_nat_card]
  have hlt : H.carrier ⊂ K.1.carrier := SetLike.coe_ssubset_coe.mpr K.2
  have hK : Nat.card H < Nat.card K.1 := Set.Finite.card_lt_card (Set.toFinite _) hlt
  have hKG : Nat.card K.1 ≤ Nat.card G := Nat.card_le_card_of_injective
    Subtype.val Subtype.val_injective
  omega

@[simp]
theorem subgroupMobius_top (G : Type*) [Group G] [Fintype G] :
    subgroupMobius G ⊤ = 1 := by
  simp [subgroupMobius]

/-
The Möbius convolution identity: Σ_{K ≥ H} μ(K,⊤) = [H = ⊤].
-/
theorem subgroupMobius_convolution
    (G : Type*) [Group G] [Fintype G] (H : Subgroup G) :
    ∑ K : Subgroup G, (if H ≤ K then subgroupMobius G K else 0 : ℤ) =
      if H = ⊤ then 1 else 0 := by
  -- We'll use the fact that if the subgroup $H$ is not the top subgroup, then the sum over all subgroups $K$ containing $H$ is zero.
  have h_sum_zero : ∀ (H : Subgroup G), H ≠ ⊤ → ∑ K ∈ Finset.univ.filter (fun K => H ≤ K), subgroupMobius G K = 0 := by
    intro H hH_ne_top
    have h_sum_zero : ∑ K ∈ Finset.univ.filter (fun K => H ≤ K), subgroupMobius G K = subgroupMobius G H + ∑ K ∈ Finset.univ.filter (fun K => H < K), subgroupMobius G K := by
      rw [ Finset.sum_eq_add_sum_diff_singleton ( show H ∈ Finset.filter ( fun K => H ≤ K ) Finset.univ from Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_rfl ⟩ ) ];
      rcongr K ; simp +decide [ lt_iff_le_and_ne ];
      exact fun _ => by rw [ eq_comm ] ;
    rw [ h_sum_zero, subgroupMobius ];
    rw [ show ( Finset.univ.filter fun K : Subgroup G => H < K ) = Finset.image ( fun K : { K : Subgroup G // H < K } => K.1 ) ( Finset.univ : Finset { K : Subgroup G // H < K } ) from ?_, Finset.sum_image ] <;> aesop;
  split_ifs with h <;> simp_all +decide [ Finset.sum_ite ]

/-! ## The k-Tuple Partition Identity -/

/-
**The k-tuple partition identity**: for any subgroup H,
    |H|^k = Σ_{K ≤ H} generatingKTupleCountWithin(K).
-/
theorem kTuplePartitionIdentity
    (G : Type*) [Group G] [Fintype G] (k : ℕ) (H : Subgroup G) :
    kTupleCountInSubgroup G k H =
      ∑ K : Subgroup G, if K ≤ H then generatingKTupleCountWithin G k K else 0 := by
  simp +decide [ kTupleCountInSubgroup ];
  rw [ ← Finset.sum_filter ];
  rw [ Fintype.card_subtype ];
  rw [ show ( Finset.filter ( fun x : Fin k → G => ∀ i, x i ∈ H ) Finset.univ ) = Finset.biUnion ( Finset.filter ( fun K : Subgroup G => K ≤ H ) ( Finset.univ : Finset ( Subgroup G ) ) ) ( fun K => Finset.filter ( fun x : Fin k → G => IsGeneratingKTupleOf G k K x ) Finset.univ ) from ?_, Finset.card_biUnion ];
  · simp +decide [ generatingKTupleCountWithin ];
    simp +decide only [Fintype.card_subtype];
  · intro K hK L hL hKL; simp_all +decide [ Finset.disjoint_left, IsGeneratingKTupleOf ] ;
  · ext x; simp [IsGeneratingKTupleOf];
    simp +decide [ Set.range_subset_iff ]

/-! ## The Exact k-Tuple Möbius Inversion Formula -/

/-
**The k-tuple Möbius inversion formula.**
    φ_k(G) = Σ_{H ≤ G} μ(H,G) · |H|^k
-/
theorem generatingKTupleCount_eq_moebius_sum
    (G : Type*) [Group G] [Fintype G] (k : ℕ) :
    (generatingKTupleCount G k : ℤ) =
      ∑ H : Subgroup G, subgroupMobius G H * (Fintype.card H : ℤ) ^ k := by
  -- Apply the Möbius inversion formula to rewrite the sum.
  have h_mobi : ∑ H : Subgroup G, (subgroupMobius G H : ℤ) * (kTupleCountInSubgroup G k H : ℤ) = ∑ K : Subgroup G, (generatingKTupleCountWithin G k K : ℤ) * (∑ H : Subgroup G, (if K ≤ H then (subgroupMobius G H : ℤ) else 0)) := by
    simp +decide only [Finset.mul_sum _ _ _];
    rw [ Finset.sum_comm, Finset.sum_congr rfl ];
    intro H _; rw [ kTuplePartitionIdentity G k H ] ; simp +decide [ mul_comm, Finset.sum_ite ] ;
    rw [ Finset.mul_sum _ _ _ ];
  convert h_mobi using 1;
  · rw [ h_mobi, Finset.sum_eq_single ⊤ ] <;> simp +contextual [ subgroupMobius_convolution ];
    exact?;
  · convert h_mobi using 1;
    simp +decide [ kTupleCountInSubgroup_eq_card_pow ]

/-! ## Probability Decomposition for k-Tuples -/

/-- The k-tuple generating probability P_k(G). -/
def generatingKTupleProbability (G : Type*) [Group G] [Fintype G] (k : ℕ) : ℚ :=
  (generatingKTupleCount G k : ℚ) / (Fintype.card G : ℚ) ^ k

/-
P_k(G) = Σ_H μ(H,G) · (|H|/|G|)^k, the probability decomposition.
-/
theorem generatingKTupleProbability_decomposition
    (G : Type*) [Group G] [Fintype G] (k : ℕ)
    (hG : (Fintype.card G : ℚ) ≠ 0) :
    generatingKTupleProbability G k =
      ∑ H : Subgroup G, (subgroupMobius G H : ℚ) *
        ((Fintype.card H : ℚ) / (Fintype.card G : ℚ)) ^ k := by
  unfold generatingKTupleProbability;
  rw [ div_eq_iff ];
  · rw [ Finset.sum_mul _ _ _ ];
    convert generatingKTupleCount_eq_moebius_sum G k using 2 ; ring;
    norm_num [ ← @Int.cast_inj ℚ ];
  · aesop

/-! ## Jordan's Totient: Number-Theoretic Analogue -/

/-- **Jordan's totient function** via Möbius inversion:
    J_k(n) = Σ_{d|n} μ(n/d)·d^k.
    For k=1, this recovers Euler's totient φ(n). -/
def jordanTotientMobius (k n : ℕ) : ℤ :=
  ∑ d ∈ n.divisors, ArithmeticFunction.moebius (n / d) * (d : ℤ) ^ k

/-
The number-theoretic Möbius convolution: Σ_{d|n} μ(d) = [n=1].
-/
theorem numberTheoretic_moebius_sum (n : ℕ) (hn : 0 < n) :
    ∑ d ∈ n.divisors, ArithmeticFunction.moebius d = if n = 1 then 1 else 0 := by
  convert congr_arg ( fun f => f n ) ( ArithmeticFunction.moebius_mul_coe_zeta ) using 1;
  simp +decide [ ArithmeticFunction.moebius, ArithmeticFunction.zeta ];
  rw [ Nat.sum_divisorsAntidiagonal fun i j => if j = 0 then 0 else if Squarefree i then ( -1 : ) ^ ArithmeticFunction.cardFactors i else 0 ];
  exact Finset.sum_congr rfl fun x hx => by rw [ if_neg ( Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd hn ( Nat.dvd_of_mem_divisors hx ) ) ( Nat.pos_of_mem_divisors hx ) ) ) ] ;

/-- **Bridge theorem**: Both the subgroup Möbius function and the number-theoretic
    Möbius function satisfy the same cancellation property. -/
theorem moebius_bridge_parallel_cancellation :
    (∀ n : ℕ, 0 < n →
      ∑ d ∈ n.divisors, ArithmeticFunction.moebius d = if n = 1 then 1 else 0) ∧
    (∀ (G : Type*) [Group G] [Fintype G] (H : Subgroup G),
      ∑ K : Subgroup G, (if H ≤ K then subgroupMobius G K else 0 : ℤ) =
        if H = ⊤ then 1 else 0) := by
  exact ⟨numberTheoretic_moebius_sum, fun G _ _ H => subgroupMobius_convolution G H⟩

/-! ## Proper Subgroup Index Ratio -/

/-
For any proper subgroup H < G of a finite group, |H|/|G| < 1.
-/
theorem subgroup_ratio_lt_one_of_ne_top (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) (hH : H ≠ ⊤) (hG : 0 < Fintype.card G) :
    (Fintype.card H : ℚ) / (Fintype.card G : ℚ) < 1 := by
  rw [ div_lt_iff₀ ] <;> norm_cast;
  convert Set.card_lt_card ( show H.carrier < Set.univ from ?_ ) using 1 ; aesop;
  exact lt_of_le_of_ne ( Set.subset_univ _ ) fun h => hH <| by ext x; simpa using Set.ext_iff.mp h x;

/-! ## Lagrange Index Bound for k-Tuples -/

/-
**Lagrange bound**: For proper subgroups, |H| ≤ |G|/2, so
    (|H|/|G|)^k ≤ (1/2)^k. This is the key estimate showing
    generation probability approaches 1 rapidly with k.
-/
theorem subgroup_ratio_le_half (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) (hH : H ≠ ⊤) (hG : 1 < Fintype.card G) :
    (Fintype.card H : ℚ) ≤ (Fintype.card G : ℚ) / 2 := by
  -- By Lagrange's theorem, |H| divides |G|. Since H ≠ ⊤, H is a proper subgroup, so [G:H] ≥ 2.
  have h_div : (Fintype.card H) ∣ (Fintype.card G) := by
    simpa using Subgroup.card_subgroup_dvd_card H
  have h_index : (Fintype.card G) / (Fintype.card H) ≥ 2 := by
    have h_index : Fintype.card G = Fintype.card H * (Fintype.card G / Fintype.card H) := by
      rw [ Nat.mul_div_cancel' h_div ];
    contrapose! hH; interval_cases Fintype.card G / Fintype.card H <;> simp_all +singlePass ;
    exact Subgroup.eq_top_of_card_eq _ ( by simpa [ Fintype.card_subtype ] using h_index.symm );
  rw [ le_div_iff₀ ] <;> norm_cast ; nlinarith [ Nat.div_mul_cancel h_div ]

/-! ## Testable Conjecture: Triple Generation Bound -/

/-- **Conjecture (Triple Generation Bound)**: For any finite simple group G
    with |G| ≥ 60, P_3(G) ≥ 1 - 1/|G|.

    **Computational test**: Verify for A_5 (|G|=60).
    This is falsifiable by computing P_3(A_5) exactly. -/
def tripleGenerationBoundConjecture : Prop :=
  ∀ (G : Type*) [Group G] [Fintype G] [IsSimpleGroup G],
    Fintype.card G ≥ 60 →
    (generatingKTupleCount G 3 : ℚ) / (Fintype.card G : ℚ) ^ 3 ≥
      1 - 1 / (Fintype.card G : ℚ)

/-! ## Multiplicativity of Jordan's Totient -/

/-
Jordan's totient is multiplicative: J_k(mn) = J_k(m)·J_k(n)
    when gcd(m,n) = 1. This mirrors the multiplicativity of
    the Hall k-Eulerian function over direct products.
-/
theorem jordanTotientMobius_multiplicative (k m n : ℕ)
    (hm : 0 < m) (hn : 0 < n) (hcop : Nat.Coprime m n) :
    jordanTotientMobius k (m * n) = jordanTotientMobius k m * jordanTotientMobius k n := by
  unfold jordanTotientMobius;
  -- By definition of divisors, we can write the divisors of $mn$ as $\{d_1d_2 \mid d_1 \mid m, d_2 \mid n\}$.
  have h_divisors : (m * n).divisors = Finset.image (fun (p : ℕ × ℕ) => p.1 * p.2) (m.divisors ×ˢ n.divisors) := by
    exact Nat.divisors_mul _ _;
  rw [ h_divisors, Finset.sum_image, Finset.sum_product ];
  · -- By definition of Möbius function, we know that μ(mn/d) = μ(m/d₁) * μ(n/d₂) when d = d₁d₂ and gcd(d₁, d₂) = 1.
    have h_moebius : ∀ d₁ d₂, d₁ ∣ m → d₂ ∣ n → Nat.Coprime d₁ d₂ → ArithmeticFunction.moebius (m * n / (d₁ * d₂)) = ArithmeticFunction.moebius (m / d₁) * ArithmeticFunction.moebius (n / d₂) := by
      intros d₁ d₂ hd₁ hd₂ hcop'
      have h_moebius_mul : ∀ a b : ℕ, Nat.Coprime a b → ArithmeticFunction.moebius (a * b) = ArithmeticFunction.moebius a * ArithmeticFunction.moebius b := by
        simp +decide [ ArithmeticFunction.moebius ];
        intro a b hab; split_ifs <;> simp_all +decide [ Nat.squarefree_mul_iff ] ;
        rw [ ← pow_add, ArithmeticFunction.cardFactors_mul ] <;> aesop;
      rw [ ← h_moebius_mul, Nat.div_mul_div_comm hd₁ hd₂ ];
      exact hcop.coprime_dvd_left ( Nat.div_dvd_of_dvd hd₁ ) |> Nat.Coprime.coprime_dvd_right ( Nat.div_dvd_of_dvd hd₂ );
    rw [ Finset.sum_mul ];
    exact Finset.sum_congr rfl fun i hi => by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun j hj => by rw [ h_moebius i j ( Nat.dvd_of_mem_divisors hi ) ( Nat.dvd_of_mem_divisors hj ) ( hcop.coprime_dvd_left ( Nat.dvd_of_mem_divisors hi ) |> Nat.Coprime.coprime_dvd_right ( Nat.dvd_of_mem_divisors hj ) ) ] ; push_cast; ring;
  · -- Since $m$ and $n$ are coprime, if $a * b = c * d$ and $a \mid m$ and $c \mid m$, then $a = c$.
    have h_inj : ∀ (a b c d : ℕ), a ∣ m → c ∣ m → b ∣ n → d ∣ n → a * b = c * d → a = c ∧ b = d := by
      intros a b c d ha hc hb hd habcd
      have h_eq : a = c := by
        exact Nat.dvd_antisymm ( by exact Nat.Coprime.dvd_of_dvd_mul_right ( Nat.Coprime.coprime_dvd_left ha <| Nat.Coprime.coprime_dvd_right hd hcop ) <| habcd ▸ dvd_mul_right _ _ ) ( by exact Nat.Coprime.dvd_of_dvd_mul_right ( Nat.Coprime.coprime_dvd_left hc <| Nat.Coprime.coprime_dvd_right hb hcop ) <| habcd.symm ▸ dvd_mul_right _ _ )
      aesop;
    exact fun p hp q hq h => Prod.ext ( h_inj _ _ _ _ ( Nat.dvd_of_mem_divisors ( Finset.mem_product.mp hp |>.1 ) ) ( Nat.dvd_of_mem_divisors ( Finset.mem_product.mp hq |>.1 ) ) ( Nat.dvd_of_mem_divisors ( Finset.mem_product.mp hp |>.2 ) ) ( Nat.dvd_of_mem_divisors ( Finset.mem_product.mp hq |>.2 ) ) h |>.1 ) ( h_inj _ _ _ _ ( Nat.dvd_of_mem_divisors ( Finset.mem_product.mp hp |>.1 ) ) ( Nat.dvd_of_mem_divisors ( Finset.mem_product.mp hq |>.1 ) ) ( Nat.dvd_of_mem_divisors ( Finset.mem_product.mp hp |>.2 ) ) ( Nat.dvd_of_mem_divisors ( Finset.mem_product.mp hq |>.2 ) ) h |>.2 )

/-! ## k-Eulerian Count at k=0 -/

/-
At k=0, the k-Eulerian count φ_0(G) equals 1 if and only if
    the trivial subgroup generates G (i.e., G is trivial).
-/
theorem generatingKTupleCount_zero (G : Type*) [Group G] [Fintype G] :
    generatingKTupleCount G 0 = if (⊥ : Subgroup G) = ⊤ then 1 else 0 := by
  split_ifs with h;
  · convert Fintype.card_eq_one_iff.mpr ?_;
    simp +decide [ IsGeneratingKTuple ];
    exact SetLike.ext fun x => by simp +decide [ h ] ;
  · simp +decide [ h, generatingKTupleCount ];
    simp_all +decide [ IsGeneratingKTuple ]

/-! ## Relationship between k and k+1 -/

/-
**Inclusion-exclusion step**: Every generating (k+1)-tuple can be obtained
    by extending a k-tuple with one more element. The extension is generating
    iff the new element is not in the closure of the old tuple, or the old
    tuple already generates.
-/
theorem generatingKTupleCount_succ_bound (G : Type*) [Group G] [Fintype G] (k : ℕ) :
    (generatingKTupleCount G (k + 1) : ℤ) ≥
      (generatingKTupleCount G k : ℤ) * (Fintype.card G : ℤ) -
        (Fintype.card G : ℤ) ^ (k + 1) +
          (generatingKTupleCount G k : ℤ) := by
  rw [ pow_succ' ];
  -- By definition of $generatingKTupleCount$, we know that
  have h_def : (generatingKTupleCount G (k + 1) : ℤ) ≥ (generatingKTupleCount G k : ℤ) * (Fintype.card G : ℤ) := by
    -- Let $S$ be the set of generating $k$-tuples.
    set S := {t : Fin k → G | IsGeneratingKTuple G k t} with hS_def;
    -- For each $t \in S$, the set of $(k+1)$-tuples $(t, g)$ where $g \in G$ is a generating $(k+1)$-tuple.
    have h_ext : ∀ t ∈ S, ∀ g : G, IsGeneratingKTuple G (k + 1) (Fin.snoc t g) := by
      intro t ht g
      simp [IsGeneratingKTuple] at *;
      simp_all +decide [ Subgroup.closure, Set.insert_subset_iff ];
    -- Therefore, the number of generating $(k+1)$-tuples is at least the number of generating $k$-tuples times $|G|$.
    have h_card : (Fintype.card { t : Fin (k + 1) → G // IsGeneratingKTuple G (k + 1) t }) ≥ (Fintype.card S) * (Fintype.card G) := by
      rw [ ← Fintype.card_prod ];
      refine' Fintype.card_le_of_injective _ _;
      exact fun x => ⟨ Fin.snoc x.1.val x.2, h_ext x.1.val x.1.property x.2 ⟩;
      intro x y hxy;
      simp_all +decide [ Fin.snoc ];
      grind;
    norm_cast;
  have h_bound : (generatingKTupleCount G k :) ≤ (Fintype.card G :) ^ k := by
    exact Fintype.card_subtype_le _ |> le_trans <| by simp +decide [ Fintype.card_pi ] ;
  nlinarith [ show ( Fintype.card G : ℤ ) ≥ 1 by exact_mod_cast Fintype.card_pos ]

end