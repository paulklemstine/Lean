module

public import Catalog.Algebra.JigsawParsimony.Basic

/-!
# Polarity-mask symmetries force 2-adic divisibility of the assembly count

Global complementation is one element (the all-ones mask) of the elementary abelian
2-group `Cube n = (ZMod 2)^n` of polarity masks.  For a puzzle `P` we form its
*mask-symmetry group* `maskSymm P`: the masks `s` such that flipping the variable
pieces by `s` never changes whether the puzzle assembles.  It is an additive
subgroup of `(ZMod 2)^n`, so its order is a power of two, and it acts freely by
translation on the assembly space.

## Main results

* `card_dvd_card_of_stable` : (Lagrange for stable sets) a finite set stable under
  translation by a subgroup `H` of a finite abelian group is a union of cosets, so
  `|H|` divides its cardinality.
* `card_maskSymm_dvd_count` : `|maskSymm P|` divides the assembly count.
* `exists_two_pow_dvd_count` : that order is `2^k` with `k ≤ n`, so the assembly
  count is divisible by `2^k`.
* `selfDual_iff_one_mem_maskSymm` : a puzzle has the same assembly space as its
  complement iff the all-ones mask is a mask symmetry.
* `even_count_of_selfDual` : such self-dual puzzles on `n ≥ 1` variables have an
  even assembly count.
-/

@[expose] public section

namespace JigsawParsimony

open Finset

/-- **Lagrange for stable sets.**  If a finite set `S` in a finite abelian group is
stable under translation by the subgroup `H`, then `|H|` divides `|S|`: `S` is
partitioned into the cosets it meets, each of size `|H|`. -/
theorem card_dvd_card_of_stable {V : Type*} [AddCommGroup V] [Fintype V] [DecidableEq V]
    (H : AddSubgroup V) (S : Finset V) (hS : ∀ x ∈ S, ∀ h ∈ H, x + h ∈ S) :
    Nat.card H ∣ S.card := by
  classical
  let q : V → V ⧸ H := QuotientAddGroup.mk
  have hfib : ∀ b ∈ S.image q, (S.filter fun a => q a = b).card = Nat.card H := by
    intro b hb
    obtain ⟨x0, hx0, rfl⟩ := Finset.mem_image.1 hb
    have hset : (S.filter fun a => q a = q x0) =
        (univ.filter fun h => h ∈ H).image (fun h => x0 + h) := by
      ext a
      simp only [Finset.mem_filter, Finset.mem_image, Finset.mem_univ, true_and, q]
      constructor
      · rintro ⟨_, hq⟩
        have hmem : -a + x0 ∈ H := QuotientAddGroup.eq.1 hq
        refine ⟨-x0 + a, ?_, by abel⟩
        have := H.neg_mem hmem
        simpa [neg_add, add_comm] using this
      · rintro ⟨h, hh, rfl⟩
        refine ⟨hS x0 hx0 h hh, ?_⟩
        apply QuotientAddGroup.eq.2
        have : -(x0 + h) + x0 = -h := by abel
        rw [this]
        exact H.neg_mem hh
    rw [hset, Finset.card_image_of_injective _ (add_right_injective x0),
      Nat.card_eq_fintype_card, Fintype.card_subtype]
  rw [Finset.card_eq_sum_card_fiberwise (f := q) (t := S.image q)
      (fun x hx => Finset.mem_coe.2 (Finset.mem_image_of_mem q (Finset.mem_coe.1 hx))),
    Finset.sum_const_nat hfib]
  exact Dvd.intro_left _ rfl

variable {n : ℕ}

/-- The mask-symmetry group of a puzzle: polarity masks whose translation action
preserves assemblability. -/
def maskSymm (P : Puzzle n) : AddSubgroup (Cube n) where
  carrier := {s | ∀ a, Assembles P (a + s) ↔ Assembles P a}
  zero_mem' := by intro a; simp
  add_mem' := by
    intro s t hs ht a
    rw [← add_assoc]
    exact (ht (a + s)).trans (hs a)
  neg_mem' := by
    intro s hs a
    have := hs (a + -s)
    rw [neg_add_cancel_right] at this
    exact this.symm

theorem mem_maskSymm {P : Puzzle n} {s : Cube n} :
    s ∈ maskSymm P ↔ ∀ a, Assembles P (a + s) ↔ Assembles P a := Iff.rfl

/-- **Mask symmetries divide the count.** -/
theorem card_maskSymm_dvd_count (P : Puzzle n) : Nat.card (maskSymm P) ∣ count P := by
  apply card_dvd_card_of_stable
  intro x hx h hh
  rw [mem_assemblies] at hx ⊢
  exact (hh x).2 hx

/-- The mask-symmetry group is a 2-group of order `2^k`, `k ≤ n`. -/
theorem card_maskSymm_eq_two_pow (P : Puzzle n) :
    ∃ k ≤ n, Nat.card (maskSymm P) = 2 ^ k := by
  have hdvd : Nat.card (maskSymm P) ∣ 2 ^ n := by
    have := (maskSymm P).card_addSubgroup_dvd_card
    simpa [Nat.card_eq_fintype_card, ZMod.card] using this
  exact (Nat.dvd_prime_pow Nat.prime_two).1 hdvd

/-- **2-adic divisibility.**  The assembly count is divisible by the order `2^k` of
the mask-symmetry group. -/
theorem exists_two_pow_dvd_count (P : Puzzle n) :
    ∃ k ≤ n, Nat.card (maskSymm P) = 2 ^ k ∧ 2 ^ k ∣ count P := by
  obtain ⟨k, hk, hcard⟩ := card_maskSymm_eq_two_pow P
  exact ⟨k, hk, hcard, hcard ▸ card_maskSymm_dvd_count P⟩

/-- The all-ones mask, i.e. global complementation of variable pieces. -/
def onesMask (n : ℕ) : Cube n := fun _ => 1

theorem compCube_eq_add_ones (a : Cube n) : compCube a = a + onesMask n := rfl

/-- Assembling the complement at `a + 1` is assembling `P` at `a`. -/
theorem assembles_compPuzzle_add_ones (P : Puzzle n) (a : Cube n) :
    Assembles (compPuzzle P) (a + onesMask n) ↔ Assembles P a := by
  have := (compSigned n).assembles_act P a
  rw [← compPuzzle_eq_actPuzzle, ← compCube_eq_actCube] at this
  exact this

/-- **Self-duality as a mask symmetry.**  `P` and its complement have the same
assembly space iff the all-ones mask lies in `maskSymm P`. -/
theorem selfDual_iff_one_mem_maskSymm (P : Puzzle n) :
    assemblies (compPuzzle P) = assemblies P ↔ onesMask n ∈ maskSymm P := by
  constructor
  · intro h a
    have h1 : Assembles (compPuzzle P) (a + onesMask n) ↔ Assembles P (a + onesMask n) := by
      rw [← mem_assemblies, ← mem_assemblies, h]
    exact h1.symm.trans (assembles_compPuzzle_add_ones P a)
  · intro h
    ext b
    rw [mem_assemblies, mem_assemblies]
    have hb : b = (b + onesMask n) + onesMask n := by
      funext i; simp [onesMask, add_one_add_one_zmod2]
    rw [hb, assembles_compPuzzle_add_ones]
    exact (h (b + onesMask n)).symm

theorem onesMask_ne_zero (hn : 0 < n) : onesMask n ≠ 0 := by
  intro h
  have h1 : (1 : ZMod 2) = 0 := congrFun h ⟨0, hn⟩
  exact absurd h1 (by decide)

/-- **Self-dual puzzles have even count.**  Recovered here as the `k = 1` case of
2-adic divisibility by the mask-symmetry group. -/
theorem even_count_of_selfDual (hn : 0 < n) (P : Puzzle n)
    (h : assemblies (compPuzzle P) = assemblies P) : Even (count P) := by
  rw [selfDual_iff_one_mem_maskSymm] at h
  obtain ⟨k, -, hcard, hdvd⟩ := exists_two_pow_dvd_count P
  have htwo : 1 < Nat.card (maskSymm P) := by
    refine Finite.one_lt_card_iff_nontrivial.2 ⟨⟨0, (maskSymm P).zero_mem⟩, ⟨onesMask n, h⟩,
      fun e => onesMask_ne_zero hn (congrArg Subtype.val e).symm⟩
  have hk : 1 ≤ k := by
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · rw [pow_zero] at hcard; omega
    · exact hk
  exact even_iff_two_dvd.2 (dvd_trans (dvd_pow_self 2 (by omega)) hdvd)

/-- **Odd counts forbid polarity symmetry.**  A puzzle with an odd assembly count
has trivial mask-symmetry group. -/
theorem maskSymm_eq_bot_of_odd (P : Puzzle n) (h : Odd (count P)) : maskSymm P = ⊥ := by
  obtain ⟨k, -, hcard, hdvd⟩ := exists_two_pow_dvd_count P
  have hk : k = 0 := by
    by_contra hk
    have : 2 ∣ count P := dvd_trans (dvd_pow_self 2 hk) hdvd
    exact (Nat.not_even_iff_odd.2 h) (even_iff_two_dvd.2 this)
  subst hk
  rw [pow_zero] at hcard
  exact (AddSubgroup.card_eq_one).1 hcard

/-- Inverse transport of assemblability along a signed permutation. -/
theorem SignedPerm.assembles_actPuzzle_iff (g : SignedPerm n) (P : Puzzle n) (b : Cube n) :
    Assembles (g.actPuzzle P) b ↔ Assembles P (g.invCube b) := by
  conv_lhs => rw [← g.actCube_invCube b]
  exact g.assembles_act P _

theorem SignedPerm.invCube_add (g : SignedPerm n) (b s : Cube n) :
    g.invCube (b + s) = g.invCube b + s ∘ g.perm := by
  funext i
  simp only [SignedPerm.invCube, Pi.add_apply, Function.comp_apply]
  ring

/-- **Conjugation law.**  A mask `s` is a symmetry of `g • P` iff the relabelled mask
`s ∘ g.perm` is a symmetry of `P`. -/
theorem mem_maskSymm_actPuzzle (g : SignedPerm n) (P : Puzzle n) (s : Cube n) :
    s ∈ maskSymm (g.actPuzzle P) ↔ s ∘ g.perm ∈ maskSymm P := by
  simp only [mem_maskSymm, g.assembles_actPuzzle_iff, g.invCube_add]
  constructor
  · intro h a
    have := h (g.actCube a)
    rwa [g.invCube_actCube] at this
  · intro h b
    exact h (g.invCube b)

/-- **The order of the mask-symmetry group is a hyperoctahedral invariant**, so the
2-adic divisibility certificate of `count` is constant on orbits. -/
theorem card_maskSymm_actPuzzle (g : SignedPerm n) (P : Puzzle n) :
    Nat.card (maskSymm (g.actPuzzle P)) = Nat.card (maskSymm P) := by
  refine Nat.card_congr
    { toFun := fun s => ⟨s.1 ∘ g.perm, (mem_maskSymm_actPuzzle g P s.1).1 s.2⟩
      invFun := fun t => ⟨t.1 ∘ g.perm.symm, (mem_maskSymm_actPuzzle g P _).2 (by
        have : t.1 ∘ g.perm.symm ∘ g.perm = t.1 := by
          funext i; simp
        rw [Function.comp_assoc, this]; exact t.2)⟩
      left_inv := fun s => Subtype.ext (by funext i; simp)
      right_inv := fun t => Subtype.ext (by funext i; simp) }

/-- Complementation preserves the mask-symmetry group itself. -/
theorem maskSymm_compPuzzle (P : Puzzle n) : maskSymm (compPuzzle P) = maskSymm P := by
  ext s
  rw [compPuzzle_eq_actPuzzle, mem_maskSymm_actPuzzle]
  rfl

end JigsawParsimony