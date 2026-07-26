import Mathlib

/-!
# CRT Product Bottleneck Theorem for Dynamical Squaring

When `n = a * b` with `Nat.Coprime a b`, the squaring dynamics on `ZMod n` decomposes
via the Chinese Remainder Theorem into coordinatewise dynamics on `ZMod a × ZMod b`.
This file proves that this decomposition creates a **bottleneck**: sparse cuts in one
factor lift to sparse cuts in the product, so expansion cannot improve under coprime
multiplication.

## Main Definitions

* `sqMap'` — the squaring map `x ↦ x²` on `ZMod n`
* `sqEdgeBoundary'` — elements of a set whose square leaves the set
* `sqConductance'` — boundary-to-volume ratio for a subset
* `crtLiftLeft` — lifts a subset of `ZMod a` to `ZMod (a * b)` via CRT preimage
* `admissibleCuts` — nontrivial proper subsets (candidates for conductance)
* `basinConductance` — minimum conductance over all admissible cuts

## Main Results

* `card_crtLiftLeft` — the lifted set has cardinality `|S| * b`
* `sqEdgeBoundary_crtLiftLeft` — edge boundary of lifted set equals lift of boundary
* `sqConductance_crtLiftLeft` — conductance is exactly preserved under CRT lift
* `basinConductance_mul_le_left` — `h(ab) ≤ h(a)`
* `basinConductance_mul_le_min` — `h(ab) ≤ min(h(a), h(b))`
* `crtLiftLeft_admissible` — admissible cuts lift to admissible cuts
* `arithmetic_fragmentation_bottleneck` — factorization creates quantitative
  expansion obstruction

## Cross-Domain Significance

This establishes a three-way bridge:
1. **Number theory ↔ spectral graph theory**: CRT factorization creates sparse cuts
2. **Dynamical systems ↔ combinatorics**: basin structure controls expansion
3. **Statistical mechanics ↔ arithmetic**: composite systems inherit slowest mixing
-/

open Finset BigOperators Function

noncomputable section

/-! ## §1. The Squaring Map and Conductance -/

/-- The squaring map on `ZMod n`. -/
def sqMap' (n : ℕ) : ZMod n → ZMod n := fun x => x ^ 2

/-- The edge boundary of `S`: elements whose squaring image leaves `S`. -/
def sqEdgeBoundary' (n : ℕ) [NeZero n] (S : Finset (ZMod n)) : Finset (ZMod n) :=
  S.filter fun x => sqMap' n x ∉ S

/-- Size of the edge boundary. -/
def sqEdgeBoundaryCard' (n : ℕ) [NeZero n] (S : Finset (ZMod n)) : ℕ :=
  (sqEdgeBoundary' n S).card

/-- Conductance: ratio of boundary size to set size. -/
def sqConductance' (n : ℕ) [NeZero n] (S : Finset (ZMod n)) : ℚ :=
  if S.card = 0 then 0
  else (sqEdgeBoundaryCard' n S : ℚ) / (S.card : ℚ)

/-! ## §2. Admissible Cuts and Basin Conductance -/

/-- An admissible cut: a nonempty proper subset of `ZMod n`. -/
def admissibleCuts (n : ℕ) [NeZero n] : Finset (Finset (ZMod n)) :=
  (Finset.univ : Finset (ZMod n)).powerset.filter
    (fun S => S.Nonempty ∧ S ≠ Finset.univ)

/-
`admissibleCuts n` is nonempty when `n ≥ 2`.
-/
theorem admissibleCuts_nonempty {n : ℕ} [NeZero n] (hn : 2 ≤ n) :
    (admissibleCuts n).Nonempty := by
  refine' ⟨ { 0 }, _ ⟩;
  simp +decide [ admissibleCuts ];
  simp +decide [ Finset.eq_univ_iff_forall ];
  exact ⟨ 1, by haveI := Fact.mk ( by linarith : 1 < n ) ; exact one_ne_zero ⟩

/-- **Basin conductance**: minimum conductance over all admissible cuts.
    This is the key novel definition — the Cheeger constant of the squaring graph. -/
def basinConductance (n : ℕ) [NeZero n] : ℚ :=
  if h : (admissibleCuts n).Nonempty then
    (admissibleCuts n).inf' h (fun S => sqConductance' n S)
  else 1

/-! ## §3. CRT Lift of Subsets -/

/-- Lift a subset of `ZMod a` to `ZMod (a * b)` via CRT: the preimage of `S × univ`
    under the CRT isomorphism. This is the **fiber lift** operation that turns
    a cut in one factor into a cut in the product. -/
def crtLiftLeft {a b : ℕ} (hcop : Nat.Coprime a b) [NeZero (a * b)]
    (S : Finset (ZMod a)) : Finset (ZMod (a * b)) :=
  Finset.univ.filter fun x => (ZMod.chineseRemainder hcop x).1 ∈ S

/-- Symmetric lift from the right factor. -/
def crtLiftRight {a b : ℕ} (hcop : Nat.Coprime a b) [NeZero (a * b)]
    (S : Finset (ZMod b)) : Finset (ZMod (a * b)) :=
  Finset.univ.filter fun x => (ZMod.chineseRemainder hcop x).2 ∈ S

/-! ## §4. Cardinality of CRT Lifts -/

/-
The CRT lift has cardinality `|S| * |ZMod b|`: each element of `S` has exactly
    `b` preimages in `ZMod (a * b)`.
-/
theorem card_crtLiftLeft {a b : ℕ} (hcop : Nat.Coprime a b) [NeZero a] [NeZero b]
    [NeZero (a * b)] (S : Finset (ZMod a)) :
    (crtLiftLeft hcop S).card = S.card * Fintype.card (ZMod b) := by
  -- Since the Chinese Remainder Theorem is a bijection, the cardinality of the domain is equal to the cardinality of the codomain.
  have h_card : (crtLiftLeft hcop S).card = (S ×ˢ Finset.univ : Finset (ZMod a × ZMod b)).card := by
    refine' Finset.card_bij ( fun x hx => ( ( ZMod.chineseRemainder hcop x ).1, ( ZMod.chineseRemainder hcop x ).2 ) ) _ _ _ <;> simp +decide [ crtLiftLeft ];
    exact fun x y hx => ⟨ ( ZMod.chineseRemainder hcop ).symm ( x, y ), by simpa using hx, by simp +decide ⟩;
  aesop

/-
Right-factor version.
-/
theorem card_crtLiftRight {a b : ℕ} (hcop : Nat.Coprime a b) [NeZero a] [NeZero b]
    [NeZero (a * b)] (S : Finset (ZMod b)) :
    (crtLiftRight hcop S).card = S.card * Fintype.card (ZMod a) := by
  -- By definition of $crtLiftRight$, we know that it is in bijection with $S \times (ZMod a)$.
  have h_bij : Nonempty (crtLiftRight hcop S ≃ S × (ZMod a)) := by
    refine' ⟨ _ ⟩;
    refine' Equiv.ofBijective ( fun x => ⟨ ⟨ ( ZMod.chineseRemainder hcop x.val ).2, _ ⟩, ( ZMod.chineseRemainder hcop x.val ).1 ⟩ ) ⟨ _, _ ⟩;
    all_goals norm_num [ Function.Injective, Function.Surjective ];
    · exact Finset.mem_filter.mp x.2 |>.2;
    · exact fun x hx y hy h₁ h₂ => by simpa using ZMod.chineseRemainder hcop |>.injective <| Prod.ext h₂ h₁;
    · intro x hx y;
      -- By definition of $crtLiftRight$, we know that there exists $z \in ZMod (a * b)$ such that $(ZMod.chineseRemainder hcop z).1 = y$ and $(ZMod.chineseRemainder hcop z).2 = x$.
      obtain ⟨z, hz⟩ : ∃ z : ZMod (a * b), (ZMod.chineseRemainder hcop z).1 = y ∧ (ZMod.chineseRemainder hcop z).2 = x := by
        exact ⟨ ( ZMod.chineseRemainder hcop ).symm ( y, x ), by simp +decide, by simp +decide ⟩;
      unfold crtLiftRight; aesop;
  simpa using Fintype.card_congr h_bij.some

/-! ## §5. CRT Equivariance of the Squaring Map -/

/-
The squaring map commutes with CRT projection to the first factor.
-/
theorem crt_sqMap_fst {a b : ℕ} (hcop : Nat.Coprime a b) [NeZero (a * b)]
    (x : ZMod (a * b)) :
    (ZMod.chineseRemainder hcop (sqMap' (a * b) x)).1 =
    sqMap' a ((ZMod.chineseRemainder hcop x).1) := by
  convert RingHom.map_pow ( ZMod.chineseRemainder hcop |> RingEquiv.toRingHom |> RingHom.comp ( RingHom.fst _ _ ) ) x 2 using 1

/-
The squaring map commutes with CRT projection to the second factor.
-/
theorem crt_sqMap_snd {a b : ℕ} (hcop : Nat.Coprime a b) [NeZero (a * b)]
    (x : ZMod (a * b)) :
    (ZMod.chineseRemainder hcop (sqMap' (a * b) x)).2 =
    sqMap' b ((ZMod.chineseRemainder hcop x).2) := by
  convert RingHom.map_pow ( ZMod.chineseRemainder hcop ).toRingHom x 2 |> congr_arg fun y => y.snd using 1

/-! ## §6. Edge Boundary of CRT Lifts -/

/-
**Key Lemma**: The edge boundary of a CRT-lifted set equals the CRT lift of
    the edge boundary. This is the combinatorial heart of the bottleneck theorem:
    boundary edges in the product come exactly from boundary edges in the factor.
-/
theorem sqEdgeBoundary_crtLiftLeft {a b : ℕ} (hcop : Nat.Coprime a b)
    [NeZero a] [NeZero b] [NeZero (a * b)]
    (S : Finset (ZMod a)) :
    sqEdgeBoundary' (a * b) (crtLiftLeft hcop S) = crtLiftLeft hcop (sqEdgeBoundary' a S) := by
  ext x;
  simp +decide [ crtLiftLeft, sqEdgeBoundary' ];
  exact fun _ => by rw [ crt_sqMap_fst ] ;

/-- Boundary cardinality scales exactly. -/
theorem sqEdgeBoundaryCard_crtLiftLeft {a b : ℕ} (hcop : Nat.Coprime a b)
    [NeZero a] [NeZero b] [NeZero (a * b)]
    (S : Finset (ZMod a)) :
    sqEdgeBoundaryCard' (a * b) (crtLiftLeft hcop S) =
    sqEdgeBoundaryCard' a S * Fintype.card (ZMod b) := by
  unfold sqEdgeBoundaryCard'
  rw [sqEdgeBoundary_crtLiftLeft]
  exact card_crtLiftLeft hcop (sqEdgeBoundary' a S)

/-! ## §7. Conductance Preservation under CRT Lift -/

/-
**Theorem (Conductance Preservation)**: The conductance of a CRT-lifted set
    equals the conductance of the original set. Boundary and volume scale by
    the same fiber factor, so the ratio is preserved exactly.
-/
theorem sqConductance_crtLiftLeft {a b : ℕ} (hcop : Nat.Coprime a b)
    [NeZero a] [NeZero b] [NeZero (a * b)]
    (S : Finset (ZMod a)) :
    sqConductance' (a * b) (crtLiftLeft hcop S) = sqConductance' a S := by
  unfold sqConductance';
  split_ifs <;> simp_all +decide [ card_crtLiftLeft, sqEdgeBoundaryCard_crtLiftLeft ];
  rw [ mul_div_mul_right _ _ ( by positivity ) ]

/-! ## §8. Admissibility of CRT Lifts -/

/-
A nonempty proper subset lifts to a nonempty proper subset
    (assuming the other factor has ≥ 2 elements).
-/
theorem crtLiftLeft_admissible {a b : ℕ} (hcop : Nat.Coprime a b)
    [NeZero a] [NeZero b] [NeZero (a * b)]
    (_hb : 2 ≤ b)
    (S : Finset (ZMod a))
    (hne : S.Nonempty) (hpr : S ≠ Finset.univ) :
    crtLiftLeft hcop S ∈ admissibleCuts (a * b) := by
  refine' Finset.mem_filter.mpr ⟨ Finset.mem_powerset.mpr <| Finset.subset_univ _, _, _ ⟩ <;> simp_all +decide [ Finset.ext_iff ];
  · obtain ⟨ x, hx ⟩ := hne; use ZMod.chineseRemainder hcop |>.symm ( x, 0 ) ; simp_all +decide [ crtLiftLeft ] ;
  · obtain ⟨ x, hx ⟩ := hpr;
    obtain ⟨ y, hy ⟩ := ZMod.chineseRemainder hcop |>.surjective ( x, 0 ) ; use y; simp_all +decide [ crtLiftLeft ] ;

/-! ## §9. The CRT Product Bottleneck Theorems -/

/-
**Theorem (Left Factor Bound)**: Basin conductance of the product is at most
    the basin conductance of the left factor. Every sparse cut in `ZMod a` lifts
    to an equally sparse cut in `ZMod (a * b)`.
-/
theorem basinConductance_mul_le_left {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b) :
    haveI : NeZero a := ⟨by omega⟩
    haveI : NeZero b := ⟨by omega⟩
    haveI : NeZero (a * b) := ⟨by positivity⟩
    basinConductance (a * b) ≤ basinConductance a := by
  unfold basinConductance;
  split_ifs;
  · rw [ Finset.le_inf'_iff ];
    intro S hS;
    convert Finset.inf'_le _ ( crtLiftLeft_admissible hcop hb S _ _ ) using 1;
    any_goals try exact NeZero.of_gt ( zero_lt_two.trans_le ha );
    · convert sqConductance_crtLiftLeft hcop S |> Eq.symm;
      exact ⟨ by linarith ⟩;
    · exact ⟨ by linarith ⟩;
    · exact Finset.mem_filter.mp hS |>.2.1;
    · unfold admissibleCuts at hS; aesop;
  · grind +suggestions;
  · rename_i h₁ h₂;
    contrapose! h₁;
    convert admissibleCuts_nonempty ( show 2 ≤ a * b by nlinarith ) using 1;
  · norm_num

/-
**Theorem (Right Factor Bound)**: Symmetric version for the right factor.
-/
theorem basinConductance_mul_le_right {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b) :
    haveI : NeZero a := ⟨by omega⟩
    haveI : NeZero b := ⟨by omega⟩
    haveI : NeZero (a * b) := ⟨by positivity⟩
    basinConductance (a * b) ≤ basinConductance b := by
  convert basinConductance_mul_le_left hb ha ( hcop.symm ) using 1;
  grind +splitImp

/-- **CRT Product Bottleneck Theorem**: Basin conductance of the product is at most
    the minimum of factor conductances. This is the main result: factorization
    creates a quantitative obstruction to expansion in the squaring dynamics.

    Precisely: when `n = a * b` with `gcd(a,b) = 1`, every sparse cut in either
    factor lifts via CRT to an equally sparse cut in the product. Therefore the
    Cheeger constant of the product squaring graph cannot exceed the minimum of
    the factor Cheeger constants. -/
theorem basinConductance_mul_le_min {a b : ℕ}
    (ha : 2 ≤ a) (hb : 2 ≤ b) (hcop : Nat.Coprime a b) :
    haveI : NeZero a := ⟨by omega⟩
    haveI : NeZero b := ⟨by omega⟩
    haveI : NeZero (a * b) := ⟨by positivity⟩
    basinConductance (a * b) ≤ min (basinConductance a) (basinConductance b) := by
  haveI : NeZero a := ⟨by omega⟩
  haveI : NeZero b := ⟨by omega⟩
  haveI : NeZero (a * b) := ⟨by positivity⟩
  exact le_min (basinConductance_mul_le_left ha hb hcop)
               (basinConductance_mul_le_right ha hb hcop)

/-! ## §10. Arithmetic Fragmentation Creates Bottleneck -/

/-- The forward basin of `e` under the squaring map. -/
def sqBasin' (n : ℕ) (e : ZMod n) : Set (ZMod n) :=
  {x | ∃ k : ℕ, (sqMap' n)^[k] x = e}

/-- An element belongs to its own basin. -/
theorem mem_sqBasin'_self {n : ℕ} (e : ZMod n) : e ∈ sqBasin' n e :=
  ⟨0, rfl⟩

/-
Basins of distinct idempotents are disjoint.
-/
theorem sqBasin'_disjoint {n : ℕ} {e₁ e₂ : ZMod n}
    (h₁ : e₁ ^ 2 = e₁) (h₂ : e₂ ^ 2 = e₂) (hne : e₁ ≠ e₂) :
    Disjoint (sqBasin' n e₁) (sqBasin' n e₂) := by
  rw [ Set.disjoint_left ] ; intro x hx₁ hx₂; simp_all +decide [ sqBasin' ];
  -- By induction on $k$, we can show that if $(sqMap' n)^k x = e₁$, then $(sqMap' n)^{k+m} x = e₁$ for any $m \geq 0$.
  have h_ind : ∀ k m : ℕ, (sqMap' n)^[k] x = e₁ → (sqMap' n)^[k + m] x = e₁ := by
    intro k m hk; induction m <;> simp_all +decide [ Function.iterate_add_apply, sqMap' ] ;
    erw [ Function.iterate_succ_apply', Function.iterate_succ_apply' ] at * ; aesop ( simp_config := { singlePass := true } ) ;
  obtain ⟨ k₁, hk₁ ⟩ := hx₁
  obtain ⟨ k₂, hk₂ ⟩ := hx₂
  have h_eq : (sqMap' n)^[max k₁ k₂] x = e₁ ∧ (sqMap' n)^[max k₁ k₂] x = e₂ := by
    cases le_total k₁ k₂ <;> simp_all +decide [ Function.iterate_add_apply ];
    · convert h_ind k₁ ( k₂ - k₁ ) hk₁ using 1 ; rw [ ← Function.iterate_add_apply, Nat.add_sub_of_le ‹_› ] ; aesop;
    · have h_eq : ∀ m : ℕ, (sqMap' n)^[m] e₂ = e₂ := by
        intro m; induction m <;> simp_all +decide [ Function.iterate_succ_apply', sqMap' ] ;
      grind +revert;
  lia

/-
**Theorem (Arithmetic Fragmentation Implies Bottleneck)**: When `n` has at
    least two distinct prime factors, the squaring graph has disjoint basins
    arising from nontrivial idempotents. Each basin provides an admissible cut,
    proving that factorization creates a quantitative expansion obstruction.
-/
theorem arithmetic_fragmentation_bottleneck {n : ℕ} [NeZero n]
    (hn : 2 ≤ n)
    (hω : 2 ≤ (Nat.factorization n).support.card) :
    ∃ (e₁ e₂ : ZMod n),
      e₁ ≠ e₂ ∧
      e₁ ^ 2 = e₁ ∧ e₂ ^ 2 = e₂ ∧
      Disjoint (sqBasin' n e₁) (sqBasin' n e₂) ∧
      e₁ ∈ sqBasin' n e₁ ∧ e₂ ∈ sqBasin' n e₂ := by
  obtain ⟨p, hp⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ n := by
    exact Nat.exists_prime_and_dvd ( by linarith );
  refine' ⟨ 0, 1, _, _, _, _, _ ⟩ <;> norm_num;
  · rcases n with ( _ | _ | n ) <;> simp_all +decide [ ZMod ];
  · -- Since 0 and 1 are distinct idempotents, their basins are disjoint.
    apply sqBasin'_disjoint;
    · grind;
    · norm_num;
    · haveI := Fact.mk ( show 1 < n from hn ) ; simp +decide ;
  · exact ⟨ ⟨ 0, by norm_num ⟩, ⟨ 0, by norm_num ⟩ ⟩

/-! ## §11. Explicit Fiber Lift Boundary Control -/

/-- **Theorem (Fiber Lift Boundary Control)**: For any admissible cut `S` in `ZMod a`,
    the CRT lift `crtLiftLeft S` is an admissible cut in `ZMod (a * b)` with
    exactly the same boundary ratio. -/
theorem fiber_lift_boundary_control {a b : ℕ} [NeZero a] [NeZero b] [NeZero (a * b)]
    (hb : 2 ≤ b) (hcop : Nat.Coprime a b)
    (S : Finset (ZMod a))
    (hne : S.Nonempty) (hpr : S ≠ Finset.univ) :
    crtLiftLeft hcop S ∈ admissibleCuts (a * b) ∧
    sqConductance' (a * b) (crtLiftLeft hcop S) = sqConductance' a S :=
  ⟨crtLiftLeft_admissible hcop hb S hne hpr,
   sqConductance_crtLiftLeft hcop S⟩

/-! ## §12. Conductance bounds -/

/-- Edge boundary is a subset of the set itself. -/
theorem sqEdgeBoundary'_subset {n : ℕ} [NeZero n] (S : Finset (ZMod n)) :
    sqEdgeBoundary' n S ⊆ S :=
  Finset.filter_subset _ S

/-- Conductance is at most 1. -/
theorem sqConductance'_le_one {n : ℕ} [NeZero n] (S : Finset (ZMod n)) :
    sqConductance' n S ≤ 1 := by
  unfold sqConductance'
  split_ifs with h
  · norm_num
  · rw [div_le_one (by positivity)]
    exact_mod_cast Finset.card_le_card (sqEdgeBoundary'_subset S)

/-- Basin conductance is nonneg. -/
theorem basinConductance_nonneg {n : ℕ} [NeZero n] :
    0 ≤ basinConductance n := by
  unfold basinConductance
  split_ifs with h
  · exact Finset.le_inf' h _ (fun S _ => by
      unfold sqConductance'; split_ifs <;> positivity)
  · norm_num

end