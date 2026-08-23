import Mathlib

/-!
# The Burnside Moment Hierarchy

For a finite group `G` acting on a finite type `X`, write

  `a g := |X^g| = Nat.card (MulAction.fixedBy X g)`

for the number of points fixed by `g`, and

  `S k := ∑ g : G, a g ^ k`,   `o k := #((Fin k → X) / G)`

for the `k`-th *moment* of the fixed-point statistic and the number of orbits of the
diagonal action of `G` on `k`-tuples of points of `X`.

The organising result of this file is the **moment identity**

  `S k = o k * |G|`   (`sum_fixedPoints_pow_eq_orbits_mul_card`)

valid for *every* `k`. Its instances are classical:

* `k = 0` : the single orbit on the one-point set of `0`-tuples (`orbitCount_zero`);
* `k = 1` : **Burnside's lemma** / the Cauchy–Frobenius orbit-counting theorem
  (`moment_one`);
* `k = 2` : the number of orbits on ordered pairs, i.e. the **rank** of the
  permutation action (`moment_two`).

Beyond the identity itself we develop the *hierarchy*: the sequence `k ↦ o k` inherits
strong structural properties from the fact that it is (up to the factor `|G|`) a moment
sequence of a nonnegative integer random variable:

* `orbits_pow_le_succ` : `o` is nondecreasing from `k = 1` on;
* `orbits_pow_log_convex` : `o (k+1) ^ 2 ≤ o k * o (k+2)`, i.e. the orbit-counting
  sequence is **log-convex** (a Cauchy–Schwarz / AM–GM phenomenon);
* `card_pow_le_card_group_mul_orbits` and `orbits_pow_le_card_pow` : the sandwich
  `|X| ^ k ≤ |G| * o k ≤ |G| * |X| ^ k`;
* `card_group_dvd_moment` : `|G|` divides every moment `S k`.

A bilinear refinement `sum_fixedPoints_mul_eq_orbits_prod_mul_card` computes
`∑ g, |X^g| * |Y^g|` as `|G|` times the number of orbits on `X × Y`; this is the
orbit-counting form of the inner product of two permutation characters.

All statements are phrased with `Nat.card`, so no decidability assumptions are needed.
-/

open MulAction Finset

namespace MomentHierarchy

section FixedPoints

variable {G X Y ι : Type*} [Group G] [MulAction G X] [MulAction G Y]

/-- A function `f : ι → X` is fixed by `g` for the pointwise action iff each value is. -/
theorem mem_fixedBy_pi (g : G) (f : ι → X) :
    f ∈ fixedBy (ι → X) g ↔ ∀ i, f i ∈ fixedBy X g := by
  simp [mem_fixedBy, funext_iff]

/-- The fixed points of `g` on the function space `ι → X` are exactly the functions
into the fixed points of `g` on `X`. -/
def fixedByPiEquiv (g : G) : (fixedBy (ι → X) g) ≃ (ι → fixedBy X g) where
  toFun f i := ⟨f.1 i, (mem_fixedBy_pi g f.1).1 f.2 i⟩
  invFun F := ⟨fun i => (F i).1, (mem_fixedBy_pi g _).2 fun i => (F i).2⟩
  left_inv f := by ext i; rfl
  right_inv F := by ext i; rfl

/-- `|(ι → X)^g| = |X^g| ^ |ι|`: the fixed-point count of a power action is a power. -/
theorem card_fixedBy_pi [Finite ι] (g : G) :
    Nat.card (fixedBy (ι → X) g) = Nat.card (fixedBy X g) ^ Nat.card ι := by
  rw [Nat.card_congr (fixedByPiEquiv g), Nat.card_fun]

/-- A pair is fixed by `g` iff both coordinates are. -/
theorem mem_fixedBy_prod (g : G) (p : X × Y) :
    p ∈ fixedBy (X × Y) g ↔ p.1 ∈ fixedBy X g ∧ p.2 ∈ fixedBy Y g := by
  cases p; simp [mem_fixedBy, Prod.ext_iff]

/-- The fixed points of `g` on a product action are the product of the fixed points. -/
def fixedByProdEquiv (g : G) : (fixedBy (X × Y) g) ≃ (fixedBy X g) × (fixedBy Y g) where
  toFun p := (⟨p.1.1, ((mem_fixedBy_prod g p.1).1 p.2).1⟩,
              ⟨p.1.2, ((mem_fixedBy_prod g p.1).1 p.2).2⟩)
  invFun q := ⟨(q.1.1, q.2.1), (mem_fixedBy_prod g _).2 ⟨q.1.2, q.2.2⟩⟩
  left_inv p := by ext <;> rfl
  right_inv q := by ext <;> rfl

/-- `|(X × Y)^g| = |X^g| * |Y^g|`. -/
theorem card_fixedBy_prod (g : G) :
    Nat.card (fixedBy (X × Y) g) = Nat.card (fixedBy X g) * Nat.card (fixedBy Y g) := by
  rw [Nat.card_congr (fixedByProdEquiv g), Nat.card_prod]

end FixedPoints

section Burnside

variable {G X Y : Type*} [Group G] [Fintype G] [MulAction G X] [MulAction G Y]

/-- **Burnside's lemma**, `Nat.card` form: `∑_{g ∈ G} |X^g| = #(X/G) · |G|`. -/
theorem burnside_natCard [Finite X] :
    ∑ g : G, Nat.card (fixedBy X g) = Nat.card (orbitRel.Quotient G X) * Nat.card G := by
  classical
  letI : ∀ g : G, Fintype (fixedBy X g) := fun g => Fintype.ofFinite _
  letI : Fintype (Quotient (orbitRel G X)) := Fintype.ofFinite _
  simpa [Nat.card_eq_fintype_card] using
    MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G X

/-- **The moment identity.** For every `k`, the `k`-th moment of the fixed-point
statistic equals `|G|` times the number of orbits of `G` on `k`-tuples:
`∑_{g ∈ G} |X^g|^k = #((X^k)/G) · |G|`.

`k = 1` is Burnside's lemma; `k = 2` computes the rank of the permutation action. -/
theorem sum_fixedPoints_pow_eq_orbits_mul_card [Finite X] (k : ℕ) :
    ∑ g : G, Nat.card (fixedBy X g) ^ k
      = Nat.card (orbitRel.Quotient G (Fin k → X)) * Nat.card G := by
  have h : ∀ g : G, Nat.card (fixedBy (Fin k → X) g) = Nat.card (fixedBy X g) ^ k := by
    intro g
    rw [card_fixedBy_pi g]
    congr 1
    simp
  rw [← burnside_natCard (X := Fin k → X)]
  exact Finset.sum_congr rfl fun g _ => (h g).symm

/-- **Bilinear Burnside.** `∑_{g ∈ G} |X^g| · |Y^g| = #((X × Y)/G) · |G|`; the
orbit-counting form of the inner product of two permutation characters. -/
theorem sum_fixedPoints_mul_eq_orbits_prod_mul_card [Finite X] [Finite Y] :
    ∑ g : G, Nat.card (fixedBy X g) * Nat.card (fixedBy Y g)
      = Nat.card (orbitRel.Quotient G (X × Y)) * Nat.card G := by
  rw [← burnside_natCard (X := X × Y)]
  exact (Finset.sum_congr rfl fun g _ => card_fixedBy_prod g).symm

end Burnside

section Instances

variable {G X : Type*} [Group G] [Fintype G] [MulAction G X] [Finite X]

/-- Level `k = 1`: Burnside's lemma, recovered from the moment identity. -/
theorem moment_one :
    ∑ g : G, Nat.card (fixedBy X g) = Nat.card (orbitRel.Quotient G X) * Nat.card G := by
  have h := sum_fixedPoints_pow_eq_orbits_mul_card (G := G) (X := X) 1
  simp only [pow_one] at h
  rw [h]
  congr 1
  exact Nat.card_congr (Quotient.congr (Equiv.funUnique (Fin 1) X) (by
    intro f₁ f₂
    constructor
    · rintro ⟨g, rfl⟩; exact ⟨g, rfl⟩
    · rintro ⟨g, hg⟩
      exact ⟨g, funext fun i => by
        have : f₁ 0 = g • f₂ 0 := hg.symm
        simpa [Subsingleton.elim i 0] using this.symm⟩))

/-- Level `k = 2`: the second moment of the fixed-point statistic computes the **rank**
of the permutation action, i.e. the number of orbits on ordered pairs. -/
theorem moment_two :
    ∑ g : G, Nat.card (fixedBy X g) ^ 2
      = Nat.card (orbitRel.Quotient G (X × X)) * Nat.card G := by
  rw [← sum_fixedPoints_mul_eq_orbits_prod_mul_card (X := X) (Y := X)]
  exact Finset.sum_congr rfl fun g _ => sq _

/-- The action is transitive iff the first moment is exactly `|G|`. -/
theorem pretransitive_iff_moment_one_eq [Nonempty X] :
    IsPretransitive G X ↔ ∑ g : G, Nat.card (fixedBy X g) = Nat.card G := by
  rw [moment_one, pretransitive_iff_subsingleton_quotient]
  have hpos : 0 < Nat.card G := Nat.card_pos
  have hq : 0 < Nat.card (orbitRel.Quotient G X) := by
    have : Finite (orbitRel.Quotient G X) := Quotient.finite _
    have : Nonempty (orbitRel.Quotient G X) := ⟨Quotient.mk _ (Classical.arbitrary X)⟩
    exact Nat.card_pos
  constructor
  · intro h
    have : Nat.card (orbitRel.Quotient G X) = 1 := by
      have : Finite (orbitRel.Quotient G X) := Quotient.finite _
      exact Nat.card_eq_one_iff_unique.2 ⟨h, ⟨Quotient.mk _ (Classical.arbitrary X)⟩⟩
    rw [this, one_mul]
  · intro h
    have h1 : Nat.card (orbitRel.Quotient G X) = 1 := by
      rcases Nat.lt_or_ge (Nat.card (orbitRel.Quotient G X)) 2 with hlt | hge
      · omega
      · exfalso
        have : 2 * Nat.card G ≤ Nat.card (orbitRel.Quotient G X) * Nat.card G :=
          Nat.mul_le_mul_right _ hge
        omega
    have : Finite (orbitRel.Quotient G X) := Quotient.finite _
    rw [Nat.card_eq_one_iff_unique] at h1
    exact h1.1

end Instances

section Inequalities

/-- Pointwise AM–GM in `ℕ`: `2 x^{k+1} y^{k+1} ≤ x^k y^{k+2} + y^k x^{k+2}`. -/
theorem two_mul_pow_succ_le (x y k : ℕ) :
    2 * (x ^ (k + 1) * y ^ (k + 1)) ≤ x ^ k * y ^ (k + 2) + y ^ k * x ^ (k + 2) := by
  have h : 2 * x * y ≤ x ^ 2 + y ^ 2 := two_mul_le_add_sq x y
  calc 2 * (x ^ (k + 1) * y ^ (k + 1)) = (x ^ k * y ^ k) * (2 * x * y) := by ring
    _ ≤ (x ^ k * y ^ k) * (x ^ 2 + y ^ 2) := Nat.mul_le_mul_left _ h
    _ = x ^ k * y ^ (k + 2) + y ^ k * x ^ (k + 2) := by ring

/-- Cauchy–Schwarz for the moment sequence of a nonnegative integer statistic:
`(∑ a^{k+1})^2 ≤ (∑ a^k) (∑ a^{k+2})`. Proved by symmetrising the double sum and
applying the pointwise AM–GM bound. -/
theorem sq_sum_pow_succ_le {ι : Type*} (s : Finset ι) (a : ι → ℕ) (k : ℕ) :
    (∑ i ∈ s, a i ^ (k + 1)) ^ 2 ≤ (∑ i ∈ s, a i ^ k) * (∑ i ∈ s, a i ^ (k + 2)) := by
  have expand : (∑ i ∈ s, a i ^ (k + 1)) ^ 2
      = ∑ i ∈ s, ∑ j ∈ s, a i ^ (k + 1) * a j ^ (k + 1) := by
    rw [sq, Finset.sum_mul_sum]
  have expandR : (∑ i ∈ s, a i ^ k) * (∑ i ∈ s, a i ^ (k + 2))
      = ∑ i ∈ s, ∑ j ∈ s, a i ^ k * a j ^ (k + 2) := by
    rw [Finset.sum_mul_sum]
  have swap : ∑ i ∈ s, ∑ j ∈ s, a i ^ k * a j ^ (k + 2)
      = ∑ i ∈ s, ∑ j ∈ s, a j ^ k * a i ^ (k + 2) := Finset.sum_comm
  have key : 2 * (∑ i ∈ s, ∑ j ∈ s, a i ^ (k + 1) * a j ^ (k + 1))
      ≤ 2 * (∑ i ∈ s, ∑ j ∈ s, a i ^ k * a j ^ (k + 2)) := by
    have h2 : 2 * (∑ i ∈ s, ∑ j ∈ s, a i ^ k * a j ^ (k + 2))
        = ∑ i ∈ s, ∑ j ∈ s, (a i ^ k * a j ^ (k + 2) + a j ^ k * a i ^ (k + 2)) := by
      simp only [Finset.sum_add_distrib, two_mul]
      rw [← swap]
    rw [h2, Finset.mul_sum]
    refine Finset.sum_le_sum fun i _ => ?_
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun j _ => two_mul_pow_succ_le (a i) (a j) k
  rw [expand, expandR]
  omega

end Inequalities

section Hierarchy

variable {G X : Type*} [Group G] [Fintype G] [MulAction G X] [Finite X]

/-- Abbreviation: `orbitCount G X k` is the number of orbits of `G` on `k`-tuples of
points of `X`. -/
noncomputable def orbitCount (G X : Type*) [Group G] [MulAction G X] (k : ℕ) : ℕ :=
  Nat.card (orbitRel.Quotient G (Fin k → X))

theorem card_group_mul_orbitCount (k : ℕ) :
    orbitCount G X k * Nat.card G = ∑ g : G, Nat.card (fixedBy X g) ^ k :=
  (sum_fixedPoints_pow_eq_orbits_mul_card k).symm

/-- `|G|` divides every moment of the fixed-point statistic. -/
theorem card_group_dvd_moment (k : ℕ) :
    Nat.card G ∣ ∑ g : G, Nat.card (fixedBy X g) ^ k :=
  ⟨orbitCount G X k, by rw [← card_group_mul_orbitCount (G := G) (X := X) k]; ring⟩


/-- **Moment (Markov) bound.** Elements with many fixed points are rare: the number of
`g ∈ G` with `|X^g| ≥ t` is at most `#((X^k)/G) · |G| / t^k` for every `k`. Applying this
with large `k` turns high levels of the hierarchy into strong bounds on the number of
group elements with many fixed points. -/
theorem card_filter_fixedPoints_ge_mul_pow_le (t k : ℕ) :
    (Finset.univ.filter (fun g : G => t ≤ Nat.card (fixedBy X g))).card * t ^ k
      ≤ orbitCount G X k * Nat.card G := by
  rw [card_group_mul_orbitCount (G := G) (X := X) k]
  calc (Finset.univ.filter (fun g : G => t ≤ Nat.card (fixedBy X g))).card * t ^ k
      = ∑ _g ∈ Finset.univ.filter (fun g : G => t ≤ Nat.card (fixedBy X g)), t ^ k := by
        rw [Finset.sum_const, smul_eq_mul]
    _ ≤ ∑ g ∈ Finset.univ.filter (fun g : G => t ≤ Nat.card (fixedBy X g)),
          Nat.card (fixedBy X g) ^ k := by
        refine Finset.sum_le_sum fun g hg => ?_
        exact Nat.pow_le_pow_left (Finset.mem_filter.1 hg).2 k
    _ ≤ ∑ g : G, Nat.card (fixedBy X g) ^ k :=
        Finset.sum_le_sum_of_subset (Finset.filter_subset _ _)

/-- The orbit counts are nondecreasing from `k = 1` on:
`#((X^k)/G) ≤ #((X^{k+1})/G)` for `k ≥ 1`. -/
theorem orbitCount_le_succ (k : ℕ) (hk : 1 ≤ k) :
    orbitCount G X k ≤ orbitCount G X (k + 1) := by
  have hmono : ∑ g : G, Nat.card (fixedBy X g) ^ k
      ≤ ∑ g : G, Nat.card (fixedBy X g) ^ (k + 1) := by
    refine Finset.sum_le_sum fun g _ => ?_
    rcases Nat.eq_zero_or_pos (Nat.card (fixedBy X g)) with h | h
    · rw [h, zero_pow (by omega), zero_pow (by omega)]
    · exact Nat.pow_le_pow_right h (by omega)
  have h1 := card_group_mul_orbitCount (G := G) (X := X) k
  have h2 := card_group_mul_orbitCount (G := G) (X := X) (k + 1)
  have hpos : 0 < Nat.card G := Nat.card_pos
  have : orbitCount G X k * Nat.card G ≤ orbitCount G X (k + 1) * Nat.card G := by
    rw [h1, h2]; exact hmono
  exact Nat.le_of_mul_le_mul_right this hpos

/-- **Log-convexity of the orbit hierarchy.** The sequence `k ↦ #((X^k)/G)` is
log-convex: `o(k+1)^2 ≤ o(k) · o(k+2)`. Equivalently the moments of the fixed-point
statistic satisfy the Cauchy–Schwarz inequality, and the factor `|G|^2` cancels. -/
theorem orbitCount_log_convex (k : ℕ) :
    orbitCount G X (k + 1) ^ 2 ≤ orbitCount G X k * orbitCount G X (k + 2) := by
  have hpos : 0 < Nat.card G := Nat.card_pos
  have cs := sq_sum_pow_succ_le (Finset.univ : Finset G) (fun g => Nat.card (fixedBy X g)) k
  have h0 := card_group_mul_orbitCount (G := G) (X := X) k
  have h1 := card_group_mul_orbitCount (G := G) (X := X) (k + 1)
  have h2 := card_group_mul_orbitCount (G := G) (X := X) (k + 2)
  have key : (orbitCount G X (k + 1) ^ 2) * (Nat.card G * Nat.card G)
      ≤ (orbitCount G X k * orbitCount G X (k + 2)) * (Nat.card G * Nat.card G) := by
    have lhs : (orbitCount G X (k + 1) ^ 2) * (Nat.card G * Nat.card G)
        = (∑ g : G, Nat.card (fixedBy X g) ^ (k + 1)) ^ 2 := by
      rw [← h1]; ring
    have rhs : (orbitCount G X k * orbitCount G X (k + 2)) * (Nat.card G * Nat.card G)
        = (∑ g : G, Nat.card (fixedBy X g) ^ k) * (∑ g : G, Nat.card (fixedBy X g) ^ (k + 2)) := by
      rw [← h0, ← h2]; ring
    rw [lhs, rhs]; exact cs
  exact Nat.le_of_mul_le_mul_right key (by positivity)

/-- Lower sandwich bound: `|X|^k ≤ |G| · #((X^k)/G)` (the identity element contributes
`|X|^k` to the moment). -/
theorem card_pow_le_card_group_mul_orbitCount (k : ℕ) :
    Nat.card X ^ k ≤ Nat.card G * orbitCount G X k := by
  have hid : Nat.card (fixedBy X (1 : G)) = Nat.card X := by
    simp [fixedBy]
  have hmem : (1 : G) ∈ (Finset.univ : Finset G) := Finset.mem_univ _
  have hle : Nat.card (fixedBy X (1 : G)) ^ k ≤ ∑ g : G, Nat.card (fixedBy X g) ^ k :=
    Finset.single_le_sum (f := fun g : G => Nat.card (fixedBy X g) ^ k)
      (fun g _ => Nat.zero_le _) hmem
  rw [hid, ← card_group_mul_orbitCount (G := G) (X := X) k] at hle
  rw [mul_comm]
  exact hle

/-- Upper sandwich bound: `#((X^k)/G) ≤ |X|^k`. -/
theorem orbitCount_le_card_pow (k : ℕ) : orbitCount G X k ≤ Nat.card X ^ k := by
  have hbd : ∀ g : G, Nat.card (fixedBy X g) ≤ Nat.card X := fun g =>
    Nat.card_le_card_of_injective _ Subtype.val_injective
  have hsum : ∑ g : G, Nat.card (fixedBy X g) ^ k ≤ ∑ _g : G, Nat.card X ^ k :=
    Finset.sum_le_sum fun g _ => Nat.pow_le_pow_left (hbd g) k
  have hcard : ∑ _g : G, Nat.card X ^ k = Nat.card G * Nat.card X ^ k := by
    simp [Finset.sum_const, Nat.card_eq_fintype_card]
  rw [hcard, ← card_group_mul_orbitCount (G := G) (X := X) k] at hsum
  have hpos : 0 < Nat.card G := Nat.card_pos
  have : orbitCount G X k * Nat.card G ≤ (Nat.card X ^ k) * Nat.card G := by
    rw [mul_comm (Nat.card X ^ k)]
    exact hsum
  exact Nat.le_of_mul_le_mul_right this hpos

/-- The zeroth orbit count is `1`: there is exactly one orbit on the empty tuple. -/
theorem orbitCount_zero : orbitCount G X 0 = 1 := by
  have hpos : 0 < Nat.card G := Nat.card_pos
  have : orbitCount G X 0 * Nat.card G = 1 * Nat.card G := by
    rw [card_group_mul_orbitCount (G := G) (X := X) 0]
    simp [Nat.card_eq_fintype_card]
  exact Nat.eq_of_mul_eq_mul_right hpos this

end Hierarchy


/-! ## Cycle 2: the rank layer, off-diagonal splitting and 2-transitivity

The second moment `∑ g, |X^g|^2` is the *rank* of the permutation action. We refine the
identity by splitting the `G`-set `X × X` into its diagonal (a copy of `X`) and its
off-diagonal part, obtaining `rank = #(X/G) + #(offDiag/G)`. This is the `k = 2` case of
the Stirling/Bell transform relating moments of the fixed-point statistic to orbit counts
on *distinct* tuples, and it yields a clean spectral criterion:
the action is transitive and 2-transitive **iff** the second moment equals `2 |G|`.
-/

section OffDiag

/-- The off-diagonal `{(x, y) : x ≠ y}` as a `G`-invariant sub-action of `X × X`. -/
def offDiagSub (G X : Type*) [Group G] [MulAction G X] : SubMulAction G (X × X) where
  carrier := {p : X × X | p.1 ≠ p.2}
  smul_mem' g p hp := by
    simp only [Set.mem_setOf_eq, Prod.smul_fst, Prod.smul_snd] at hp ⊢
    exact fun h => hp (smul_left_cancel g h)

variable {G X : Type*} [Group G] [MulAction G X]

/-- The number of ordered pairs of distinct elements of a finite type. -/
theorem card_ne_pairs_add (F : Type*) [Finite F] :
    Nat.card {q : F × F // q.1 ≠ q.2} + Nat.card F = Nat.card F ^ 2 := by
  classical
  have hdiag : Nat.card {q : F × F // q.1 = q.2} = Nat.card F :=
    Nat.card_congr
      { toFun := fun q => q.1.1
        invFun := fun x => ⟨(x, x), rfl⟩
        left_inv := fun q => Subtype.ext (Prod.ext rfl q.2)
        right_inv := fun _ => rfl }
  have h := Nat.card_congr (Equiv.sumCompl (fun q : F × F => q.1 = q.2))
  rw [Nat.card_sum, Nat.card_prod, hdiag] at h
  simp only [ne_eq, sq]
  omega

theorem mem_fixedBy_offDiag (g : G) (p : offDiagSub G X) :
    p ∈ fixedBy (offDiagSub G X) g ↔
      (p : X × X).1 ∈ fixedBy X g ∧ (p : X × X).2 ∈ fixedBy X g := by
  simp [mem_fixedBy, Subtype.ext_iff, Prod.ext_iff]

/-- The `g`-fixed off-diagonal pairs are the ordered pairs of distinct `g`-fixed points. -/
def fixedByOffDiagEquiv (g : G) :
    fixedBy (offDiagSub G X) g ≃ {q : (fixedBy X g) × (fixedBy X g) // q.1 ≠ q.2} where
  toFun p := ⟨(⟨(p.1 : X × X).1, ((mem_fixedBy_offDiag g p.1).1 p.2).1⟩,
               ⟨(p.1 : X × X).2, ((mem_fixedBy_offDiag g p.1).1 p.2).2⟩),
    fun h => p.1.2 (congrArg Subtype.val h)⟩
  invFun q := ⟨⟨((q.1.1 : X), (q.1.2 : X)), fun h => q.2 (Subtype.ext h)⟩, by
    rw [mem_fixedBy_offDiag]
    exact ⟨q.1.1.2, q.1.2.2⟩⟩
  left_inv p := by ext <;> rfl
  right_inv q := by ext <;> rfl

/-- `|offDiag^g| + |X^g| = |X^g|^2`. -/
theorem card_fixedBy_offDiag_add [Finite X] (g : G) :
    Nat.card (fixedBy (offDiagSub G X) g) + Nat.card (fixedBy X g)
      = Nat.card (fixedBy X g) ^ 2 := by
  rw [Nat.card_congr (fixedByOffDiagEquiv g)]
  exact card_ne_pairs_add (fixedBy X g)

end OffDiag

section Rank

variable {G X : Type*} [Group G] [Fintype G] [MulAction G X] [Finite X]

/-- **Rank splitting.** The number of orbits on ordered pairs is the number of orbits on
points plus the number of orbits on ordered pairs of *distinct* points:
`rank = #(X/G) + #(offDiag/G)`. -/
theorem orbits_prod_eq_orbits_add_orbits_offDiag :
    Nat.card (orbitRel.Quotient G (X × X))
      = Nat.card (orbitRel.Quotient G X)
        + Nat.card (orbitRel.Quotient G (offDiagSub G X)) := by
  have hpos : 0 < Nat.card G := Nat.card_pos
  have h2 : Nat.card (orbitRel.Quotient G (X × X)) * Nat.card G
      = ∑ g : G, Nat.card (fixedBy X g) ^ 2 := (moment_two (G := G) (X := X)).symm
  have h1 : Nat.card (orbitRel.Quotient G X) * Nat.card G
      = ∑ g : G, Nat.card (fixedBy X g) := (burnside_natCard (G := G) (X := X)).symm
  have hoff : Nat.card (orbitRel.Quotient G (offDiagSub G X)) * Nat.card G
      = ∑ g : G, Nat.card (fixedBy (offDiagSub G X) g) :=
    (burnside_natCard (G := G) (X := offDiagSub G X)).symm
  have hsum : ∑ g : G, Nat.card (fixedBy (offDiagSub G X) g)
      + ∑ g : G, Nat.card (fixedBy X g) = ∑ g : G, Nat.card (fixedBy X g) ^ 2 := by
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun g _ => card_fixedBy_offDiag_add g
  have key : Nat.card (orbitRel.Quotient G (X × X)) * Nat.card G
      = (Nat.card (orbitRel.Quotient G X)
          + Nat.card (orbitRel.Quotient G (offDiagSub G X))) * Nat.card G := by
    rw [add_mul, h1, hoff, h2]
    omega
  exact Nat.eq_of_mul_eq_mul_right hpos key

/-- If `X` has at least two points there is an off-diagonal orbit, hence the rank of a
transitive action is at least `2`: `∑ g, |X^g|^2 ≥ 2 |G|`. -/
theorem two_mul_card_le_second_moment [Nontrivial X] (htrans : IsPretransitive G X) :
    2 * Nat.card G ≤ ∑ g : G, Nat.card (fixedBy X g) ^ 2 := by
  have h1 : Nat.card (orbitRel.Quotient G X) = 1 := by
    have : Finite (orbitRel.Quotient G X) := Quotient.finite _
    have hsub : Subsingleton (orbitRel.Quotient G X) :=
      (pretransitive_iff_subsingleton_quotient G X).1 htrans
    exact Nat.card_eq_one_iff_unique.2 ⟨hsub, ⟨Quotient.mk _ (Classical.arbitrary X)⟩⟩
  obtain ⟨x, y, hxy⟩ := exists_pair_ne X
  have hne : Nonempty (orbitRel.Quotient G (offDiagSub G X)) :=
    ⟨Quotient.mk _ ⟨(x, y), hxy⟩⟩
  have hfin : Finite (orbitRel.Quotient G (offDiagSub G X)) := Quotient.finite _
  have hoffpos : 0 < Nat.card (orbitRel.Quotient G (offDiagSub G X)) := Nat.card_pos
  have hsplit := orbits_prod_eq_orbits_add_orbits_offDiag (G := G) (X := X)
  have h2 := moment_two (G := G) (X := X)
  rw [h2, hsplit, h1]
  have : 2 ≤ 1 + Nat.card (orbitRel.Quotient G (offDiagSub G X)) := by omega
  exact Nat.mul_le_mul_right _ this

/-- **Second-moment characterisation of 2-transitivity.** For a finite group acting on a
type with at least two elements, the action is transitive *and* transitive on ordered
pairs of distinct points iff `∑ g, |X^g|^2 = 2 |G|`; i.e. iff the permutation action has
rank exactly `2`. -/
theorem second_moment_eq_two_iff [Nontrivial X] :
    (IsPretransitive G X ∧ IsPretransitive G (offDiagSub G X))
      ↔ ∑ g : G, Nat.card (fixedBy X g) ^ 2 = 2 * Nat.card G := by
  have hfin1 : Finite (orbitRel.Quotient G X) := Quotient.finite _
  have hfin2 : Finite (orbitRel.Quotient G (offDiagSub G X)) := Quotient.finite _
  obtain ⟨x, y, hxy⟩ := exists_pair_ne X
  have hne1 : Nonempty (orbitRel.Quotient G X) := ⟨Quotient.mk _ x⟩
  have hne2 : Nonempty (orbitRel.Quotient G (offDiagSub G X)) :=
    ⟨Quotient.mk _ ⟨(x, y), hxy⟩⟩
  have hpos1 : 0 < Nat.card (orbitRel.Quotient G X) := Nat.card_pos
  have hpos2 : 0 < Nat.card (orbitRel.Quotient G (offDiagSub G X)) := Nat.card_pos
  have hGpos : 0 < Nat.card G := Nat.card_pos
  have h2 := moment_two (G := G) (X := X)
  have hsplit := orbits_prod_eq_orbits_add_orbits_offDiag (G := G) (X := X)
  rw [h2, hsplit]
  constructor
  · rintro ⟨ht, ht2⟩
    have e1 : Nat.card (orbitRel.Quotient G X) = 1 :=
      Nat.card_eq_one_iff_unique.2
        ⟨(pretransitive_iff_subsingleton_quotient G X).1 ht, hne1⟩
    have e2 : Nat.card (orbitRel.Quotient G (offDiagSub G X)) = 1 :=
      Nat.card_eq_one_iff_unique.2
        ⟨(pretransitive_iff_subsingleton_quotient G (offDiagSub G X)).1 ht2, hne2⟩
    rw [e1, e2]
  · intro h
    have hsum : Nat.card (orbitRel.Quotient G X)
        + Nat.card (orbitRel.Quotient G (offDiagSub G X)) = 2 :=
      Nat.eq_of_mul_eq_mul_right hGpos h
    have e1 : Nat.card (orbitRel.Quotient G X) = 1 := by omega
    have e2 : Nat.card (orbitRel.Quotient G (offDiagSub G X)) = 1 := by omega
    rw [Nat.card_eq_one_iff_unique] at e1 e2
    exact ⟨(pretransitive_iff_subsingleton_quotient G X).2 e1.1,
      (pretransitive_iff_subsingleton_quotient G (offDiagSub G X)).2 e2.1⟩

end Rank

section Regular

variable {G : Type*} [Group G] [Fintype G]

omit [Fintype G] in
/-- The identity fixes everything: `|X^1| = |X|`. -/
theorem card_fixedBy_one (X : Type*) [MulAction G X] :
    Nat.card (fixedBy X (1 : G)) = Nat.card X := by
  simp [fixedBy]

omit [Fintype G] in
/-- For the left regular action, a nonidentity element has no fixed points. -/
theorem card_fixedBy_regular_ne {g : G} (hg : g ≠ 1) : Nat.card (fixedBy G g) = 0 := by
  have : IsEmpty (fixedBy G g) := by
    constructor
    rintro ⟨x, hx⟩
    rw [mem_fixedBy] at hx
    exact hg (by
      have := congrArg (fun y => y * x⁻¹) hx
      simpa [mul_assoc] using this)
  simp [Nat.card_of_isEmpty]

/-- **Orbit counts of the regular action.** The diagonal left-translation action of `G`
on `G^k` has exactly `|G|^{k-1}` orbits for `k ≥ 1`: the moment collapses to the single
identity term `|G|^k`. -/
theorem orbitCount_regular (k : ℕ) (hk : 1 ≤ k) :
    orbitCount G G k * Nat.card G = Nat.card G ^ k := by
  rw [card_group_mul_orbitCount, Finset.sum_eq_single (1 : G)]
  · rw [card_fixedBy_one (G := G) G]
  · intro b _ hb
    rw [card_fixedBy_regular_ne hb, zero_pow (by omega : k ≠ 0)]
  · intro h
    exact absurd (Finset.mem_univ (1 : G)) h

/-- Explicit form for `k ≥ 1`: the regular action on `k`-tuples has `|G|^{k-1}` orbits. -/
theorem orbitCount_regular_eq (k : ℕ) (hk : 1 ≤ k) :
    orbitCount G G k = Nat.card G ^ (k - 1) := by
  have hpos : 0 < Nat.card G := Nat.card_pos
  have h := orbitCount_regular (G := G) k hk
  have hk' : Nat.card G ^ k = Nat.card G ^ (k - 1) * Nat.card G := by
    rw [← pow_succ]
    congr 1
    omega
  rw [hk'] at h
  exact Nat.eq_of_mul_eq_mul_right hpos h

end Regular


/-! ## Cycle 3: mixed moments, Cauchy–Schwarz geometry and superexponential growth

The moment identity is the diagonal case of a *mixed moment* identity valid for an
arbitrary finite family of `G`-sets: `∑ g ∏ i |X_i^g| = |G| · #((∏ i X_i)/G)`. Reading
`g ↦ |X^g|` as the permutation character of `X`, the mixed identity says that orbit
counts on products compute inner products of permutation characters. Cauchy–Schwarz for
this inner product then becomes a purely combinatorial statement about orbit counts, and
the log-convexity of the moment hierarchy upgrades to superexponential growth
`#(X/G)^k ≤ #((X^k)/G)`.
-/

section MixedMoments

variable {G : Type*} [Group G] [Fintype G]

omit [Fintype G] in
theorem mem_fixedBy_pi_family {ι : Type*} (X : ι → Type*) [∀ i, MulAction G (X i)] (g : G)
    (f : ∀ i, X i) : f ∈ fixedBy (∀ i, X i) g ↔ ∀ i, f i ∈ fixedBy (X i) g := by
  simp [mem_fixedBy, funext_iff]

/-- Fixed points of a product of `G`-sets are products of fixed points. -/
def fixedByPiFamilyEquiv {ι : Type*} (X : ι → Type*) [∀ i, MulAction G (X i)] (g : G) :
    fixedBy (∀ i, X i) g ≃ (∀ i, fixedBy (X i) g) where
  toFun f i := ⟨f.1 i, (mem_fixedBy_pi_family X g f.1).1 f.2 i⟩
  invFun F := ⟨fun i => (F i).1, (mem_fixedBy_pi_family X g _).2 fun i => (F i).2⟩
  left_inv f := by ext i; rfl
  right_inv F := by ext i; rfl

/-- **Mixed moment identity.** For any finite family `(X i)` of finite `G`-sets,
`∑_{g ∈ G} ∏_i |X_i^g| = #((∏ i, X i)/G) · |G|`. Taking all `X i = X` recovers the
`k`-th moment identity; taking two factors gives the inner product of two permutation
characters. -/
theorem sum_prod_fixedPoints_eq_orbits_mul_card {ι : Type*} [Fintype ι] (X : ι → Type*)
    [∀ i, MulAction G (X i)] [∀ i, Finite (X i)] :
    ∑ g : G, ∏ i, Nat.card (fixedBy (X i) g)
      = Nat.card (orbitRel.Quotient G (∀ i, X i)) * Nat.card G := by
  rw [← burnside_natCard (X := ∀ i, X i)]
  refine Finset.sum_congr rfl fun g _ => ?_
  rw [Nat.card_congr (fixedByPiFamilyEquiv X g), Nat.card_pi]

/-- **Cauchy–Schwarz for orbit counts.** For finite `G`-sets `X` and `Y`,
`#((X × Y)/G)^2 ≤ #((X × X)/G) · #((Y × Y)/G)`: the orbit-counting pairing is a
positive-semidefinite form on permutation characters. -/
theorem orbits_prod_sq_le {X Y : Type*} [MulAction G X] [MulAction G Y]
    [Finite X] [Finite Y] :
    Nat.card (orbitRel.Quotient G (X × Y)) ^ 2
      ≤ Nat.card (orbitRel.Quotient G (X × X)) * Nat.card (orbitRel.Quotient G (Y × Y)) := by
  have hGpos : 0 < Nat.card G := Nat.card_pos
  set a : G → ℕ := fun g => Nat.card (fixedBy X g)
  set b : G → ℕ := fun g => Nat.card (fixedBy Y g)
  have hxy : Nat.card (orbitRel.Quotient G (X × Y)) * Nat.card G = ∑ g : G, a g * b g :=
    (sum_fixedPoints_mul_eq_orbits_prod_mul_card (X := X) (Y := Y)).symm
  have hxx : Nat.card (orbitRel.Quotient G (X × X)) * Nat.card G = ∑ g : G, a g ^ 2 := by
    rw [← moment_two (G := G) (X := X)]
  have hyy : Nat.card (orbitRel.Quotient G (Y × Y)) * Nat.card G = ∑ g : G, b g ^ 2 := by
    rw [← moment_two (G := G) (X := Y)]
  have cs : (∑ g : G, a g * b g) ^ 2 ≤ (∑ g : G, a g ^ 2) * (∑ g : G, b g ^ 2) :=
    Finset.sum_mul_sq_le_sq_mul_sq Finset.univ a b
  have key : (Nat.card (orbitRel.Quotient G (X × Y)) ^ 2) * (Nat.card G * Nat.card G)
      ≤ (Nat.card (orbitRel.Quotient G (X × X)) * Nat.card (orbitRel.Quotient G (Y × Y)))
        * (Nat.card G * Nat.card G) := by
    have l : (Nat.card (orbitRel.Quotient G (X × Y)) ^ 2) * (Nat.card G * Nat.card G)
        = (∑ g : G, a g * b g) ^ 2 := by rw [← hxy]; ring
    have r : (Nat.card (orbitRel.Quotient G (X × X))
          * Nat.card (orbitRel.Quotient G (Y × Y))) * (Nat.card G * Nat.card G)
        = (∑ g : G, a g ^ 2) * (∑ g : G, b g ^ 2) := by rw [← hxx, ← hyy]; ring
    rw [l, r]; exact cs
  exact Nat.le_of_mul_le_mul_right key (by positivity)

end MixedMoments

section Growth

variable {G X : Type*} [Group G] [Fintype G] [MulAction G X] [Finite X] [Nonempty X]

omit [Fintype G] in
/-- Every level of the hierarchy has at least one orbit when `X` is nonempty. -/
theorem orbitCount_pos (k : ℕ) : 0 < orbitCount G X k := by
  have h1 : Nonempty (Fin k → X) := ⟨fun _ => Classical.arbitrary X⟩
  have h2 : Finite (orbitRel.Quotient G (Fin k → X)) := Quotient.finite _
  have h3 : Nonempty (orbitRel.Quotient G (Fin k → X)) :=
    ⟨Quotient.mk _ (Classical.arbitrary (Fin k → X))⟩
  exact Nat.card_pos

/-- The successive ratios of the orbit hierarchy dominate the first one:
`#(X/G) · o k ≤ o (k+1)`. This is log-convexity integrated once. -/
theorem orbitCount_one_mul_le_succ (k : ℕ) :
    orbitCount G X 1 * orbitCount G X k ≤ orbitCount G X (k + 1) := by
  induction k with
  | zero => simp [orbitCount_zero]
  | succ n ih =>
    have hlc := orbitCount_log_convex (G := G) (X := X) n
    have hpos := orbitCount_pos (G := G) (X := X) n
    have step : (orbitCount G X 1 * orbitCount G X (n + 1)) * orbitCount G X n
        ≤ orbitCount G X (n + 2) * orbitCount G X n := by
      calc (orbitCount G X 1 * orbitCount G X (n + 1)) * orbitCount G X n
          = (orbitCount G X 1 * orbitCount G X n) * orbitCount G X (n + 1) := by ring
        _ ≤ orbitCount G X (n + 1) * orbitCount G X (n + 1) :=
            Nat.mul_le_mul_right _ ih
        _ = orbitCount G X (n + 1) ^ 2 := (sq _).symm
        _ ≤ orbitCount G X n * orbitCount G X (n + 2) := hlc
        _ = orbitCount G X (n + 2) * orbitCount G X n := mul_comm _ _
    exact Nat.le_of_mul_le_mul_right step hpos

/-- **Superexponential growth of the orbit hierarchy.** `#(X/G)^k ≤ #((X^k)/G)`: the
number of orbits on `k`-tuples grows at least like the `k`-th power of the number of
orbits on points. -/
theorem orbitCount_one_pow_le (k : ℕ) : orbitCount G X 1 ^ k ≤ orbitCount G X k := by
  induction k with
  | zero => simp [orbitCount_zero]
  | succ n ih =>
    calc orbitCount G X 1 ^ (n + 1) = orbitCount G X 1 * orbitCount G X 1 ^ n := by ring
      _ ≤ orbitCount G X 1 * orbitCount G X n := Nat.mul_le_mul_left _ ih
      _ ≤ orbitCount G X (n + 1) := orbitCount_one_mul_le_succ n

end Growth


/-! ## Cycle 6: suborbits — the second moment of a transitive action

For a transitive action the second level of the hierarchy is a *local* invariant: the
orbits of `G` on `X × X` are in bijection with the orbits of a single point stabiliser
`H = Stab(x₀)` on `X` (the **suborbits**). The bijection sends the `H`-orbit of `y` to the
`G`-orbit of the pair `(x₀, y)`. Combined with the moment identity this evaluates the
second moment of a transitive action purely in terms of `H`. -/

section Suborbits

variable {G X : Type*} [Group G] [MulAction G X]

/-- **Rank equals the number of suborbits.** For a transitive action, the orbits of `G`
on ordered pairs correspond to the orbits of a point stabiliser on `X`. -/
theorem orbits_prod_eq_orbits_stabilizer (x0 : X) (htrans : IsPretransitive G X) :
    Nat.card (orbitRel.Quotient G (X × X))
      = Nat.card (orbitRel.Quotient (stabilizer G x0) X) := by
  classical
  have hwd : ∀ y y' : X, orbitRel (stabilizer G x0) X y y' →
      Quotient.mk (orbitRel G (X × X)) (x0, y) = Quotient.mk _ (x0, y') := by
    intro y y' h
    obtain ⟨h0, hh⟩ := MulAction.mem_orbit_iff.1 h
    have hx : (h0 : G) • x0 = x0 := h0.2
    exact Quotient.sound (show ((x0, y) : X × X) ∈ MulAction.orbit G (x0, y') from
      MulAction.mem_orbit_iff.2 ⟨(h0 : G), by simpa [Prod.ext_iff, hx] using hh⟩)
  refine (Nat.card_congr (Equiv.ofBijective
    (Quotient.lift (fun y : X => Quotient.mk (orbitRel G (X × X)) (x0, y)) hwd) ⟨?_, ?_⟩)).symm
  · refine Quotient.ind₂ ?_
    intro y y' h
    have h' : ((x0, y) : X × X) ∈ MulAction.orbit G (x0, y') :=
      Quotient.exact
        (show Quotient.mk (orbitRel G (X × X)) (x0, y) = Quotient.mk _ (x0, y') from h)
    obtain ⟨g, hg⟩ := MulAction.mem_orbit_iff.1 h'
    exact Quotient.sound (show y ∈ MulAction.orbit (stabilizer G x0) y' from
      MulAction.mem_orbit_iff.2 ⟨⟨g, congrArg Prod.fst hg⟩, congrArg Prod.snd hg⟩)
  · refine Quotient.ind ?_
    rintro ⟨x, y⟩
    obtain ⟨a, ha⟩ := htrans.exists_smul_eq x0 x
    exact ⟨Quotient.mk _ (a⁻¹ • y),
      Quotient.sound (show ((x0, a⁻¹ • y) : X × X) ∈ MulAction.orbit G (x, y) from
        MulAction.mem_orbit_iff.2 ⟨a⁻¹, by simp [← ha]⟩)⟩

variable [Fintype G] [Finite X]

/-- The second moment of a transitive action counts the suborbits:
`∑_{g ∈ G} |X^g|^2 = #(X / Stab(x₀)) · |G|`. -/
theorem sum_fixedPoints_sq_eq_suborbits (x0 : X) (htrans : IsPretransitive G X) :
    ∑ g : G, Nat.card (fixedBy X g) ^ 2
      = Nat.card (orbitRel.Quotient (stabilizer G x0) X) * Nat.card G := by
  rw [moment_two (G := G) (X := X), orbits_prod_eq_orbits_stabilizer x0 htrans]

/-- The suborbits of a transitive action on at least two points split as the fixed point
`x₀` together with the orbits of `G` on ordered pairs of distinct points. -/
theorem suborbits_eq_succ_orbits_offDiag [Nontrivial X] (x0 : X)
    (htrans : IsPretransitive G X) :
    Nat.card (orbitRel.Quotient (stabilizer G x0) X)
      = 1 + Nat.card (orbitRel.Quotient G (offDiagSub G X)) := by
  have h1 : Nat.card (orbitRel.Quotient G X) = 1 := by
    have : Finite (orbitRel.Quotient G X) := Quotient.finite _
    exact Nat.card_eq_one_iff_unique.2
      ⟨(pretransitive_iff_subsingleton_quotient G X).1 htrans, ⟨Quotient.mk _ x0⟩⟩
  rw [← orbits_prod_eq_orbits_stabilizer x0 htrans,
    orbits_prod_eq_orbits_add_orbits_offDiag (G := G) (X := X), h1]

end Suborbits

end MomentHierarchy